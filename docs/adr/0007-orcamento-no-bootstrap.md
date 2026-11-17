# 0007. Orçamento de custos no `bootstrap`, com canal de e-mail próprio

**Status:** Aceita · **Data:** 2026-11-17

## Contexto
O Cloud SQL e o Cloud NAT cobram por hora enquanto existirem, e esquecer o ambiente ligado é a forma mais provável de gastar sem querer. Um alerta de orçamento já existia, criado à mão no console, sem nenhum registro no repositório.

## Decisão
- Um `google_billing_budget` no **`bootstrap`**, não no `dev`. O orçamento pertence à conta de billing, não ao ambiente: no `dev`, um `destroy` apagaria o alerta de custo justamente quando se quer proteção.
- **Valor:** R$ 50 por mês. A moeda do orçamento precisa ser a **mesma da conta de billing**, que é BRL: com `USD`, o Google respondeu `400 Request contains an invalid argument`, sem dizer qual argumento.
- **Regras:** aviso em 50% do gasto real e em 90% do gasto previsto.
- **Canal de e-mail próprio** no `bootstrap`, separado do canal do `dev` ([0006](0006-alertas-de-uptime-e-5xx-por-email.md)). Os states são separados, então o `bootstrap` não enxerga o canal do módulo `observability`, que sumiria no `destroy` do `dev`.
- **Cota da API:** o provider do `bootstrap` usa `user_project_override = true` e `billing_project = var.project_id`. A API de budgets exige um projeto de cota, e com credenciais de usuário (ADC) o padrão cai num projeto do Google em que a API está desligada (erro 403 `SERVICE_DISABLED`).
- **APIs no `bootstrap`:** `billingbudgets`, `monitoring`, e também `cloudresourcemanager` e `serviceusage`, porque com o override de cota o Terraform passou a exigi-las ligadas no nosso projeto.

## Alternativas consideradas
- **Budget dentro do `dev`:** some junto com o ambiente. Descartada.
- **Budget só no console:** funciona, mas não é reproduzível nem aparece no repositório.
- **Reutilizar o canal do `dev` por `terraform_remote_state`:** o `dev` depende do `bootstrap`, não o contrário, e o canal não sobreviveria ao `destroy`.
- **Resolver a cota só com `gcloud auth application-default set-quota-project`:** resolve na máquina de quem rodou, mas não deixa nada no código.

## Consequências
- **Bom:** o orçamento e o canal sobrevivem ao `destroy` do `dev`, e tudo fica versionado.
- **Limitação:** o orçamento **só avisa**, não bloqueia o gasto. Os dados de custo podem chegar com atraso, então o aviso não é em tempo real.
- **Limitação:** não há regra de 100% do gasto real, só 50% do gasto real e 90% da previsão.
- **Ovo e galinha:** as APIs `cloudresourcemanager` e `serviceusage` tiveram de ser ligadas pelo `gcloud` na primeira vez, porque o próprio `google_project_service` depende delas. Só depois foram adotadas no state.
- **Custo:** dois canais de e-mail para o mesmo endereço (um no `bootstrap`, outro no `dev`).
