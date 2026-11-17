# 0006. Alertas de uptime e de erros 5xx, avisados por e-mail

**Status:** Aceita · **Data:** 2026-11-17

## Contexto
Sem monitoramento, só se descobre que a API caiu quando alguém reclama. O Cloud Run já gera métricas sozinho (contagem de requisições por classe de resposta), e o Cloud Monitoring pode chamar a API de fora e registrar se ela respondeu. Faltava transformar isso em aviso.

## Decisão
Um módulo `observability`, chamado pelo ambiente `dev`, com:

- **Canal de notificação por e-mail.** O endereço é uma variável (`alert_email`) no `terraform.tfvars`, fora do Git.
- **Uptime check** em `GET /health`, por HTTPS na porta 443, no intervalo padrão do provider (5 minutos). O Google chama a API de vários locais do mundo. O `/health` responde sem consultar o banco, de propósito: uma falha momentânea do banco não deve contar como "a API caiu".
- **Alerta de uptime:** dispara quando **mais de um local** falha (`COMPARISON_GT` 1 sobre a contagem de locais com falha), por pelo menos 60 segundos.
- **Alerta de 5xx:** dispara quando a **soma de respostas 5xx** do serviço, numa janela de 5 minutos, é **maior que 0** (`ALIGN_DELTA` + `REDUCE_SUM`, sem espera extra).

O critério de cada limite foi perguntar qual erro custa mais: um e-mail à toa ou um problema que passa despercebido.

- No **uptime**, exigir 2 ou mais locais evita alarme falso por falha de rede de um único local.
- No **5xx**, qualquer erro conta: um 5xx significa que o servidor falhou (código ou banco), ao contrário de um 4xx, que pode ser só um usuário digitando a senha errada. Num projeto de pouco tráfego, um e-mail à toa custa quase nada.

## Alternativas consideradas
- **Alertar com 1 local falhando:** mais rápido, mas um problema de rede de um só local gera aviso falso.
- **Limite alto para 5xx (por exemplo, 5 erros em 5 minutos):** com pouco tráfego, um erro real pode nunca atingir o limite.
- **Métricas baseadas em logs:** possível, mas as métricas do Cloud Run já cobrem o caso. Fica para quando houver erro que só aparece em log.
- **Outros canais (Slack, PagerDuty):** mais ruído de configuração do que ganho para um projeto individual.

## Consequências
- **Bom:** a queda da API gera um e-mail sem ninguém precisar olhar. O alerta de uptime foi testado: removi o acesso público do Cloud Run, os locais passaram a falhar (4 dos 6 apareciam em vermelho no console) e o e-mail chegou. Restaurei com um `terraform apply`, o que também exercitou o drift (ver o README).
- **Não testado:** o alerta de 5xx só foi validado pelo `apply` aceitar a configuração. Não provoquei erros 5xx de propósito.
- **Não medido:** o tempo entre a falha e o e-mail. O `alignment_period` do alerta de uptime (1200s) veio de um exemplo da documentação do Terraform e pode deixar o aviso mais lento do que o necessário.
- **Limitação:** o `/health` não consulta o banco, então uma queda do banco não derruba o uptime check. Ela só aparece como 5xx nas rotas que dependem do banco.
- **Limitação:** o check não valida o certificado TLS (o padrão do provider).
- **Ciclo de vida:** o módulo vive no `dev` e é destruído junto com ele. Sem ambiente, não há o que monitorar.
