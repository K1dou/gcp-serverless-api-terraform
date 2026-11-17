# Registros de decisão de arquitetura (ADRs)

Cada ADR responde a uma pergunta: **por que fizemos assim?** Ele guarda o contexto, a decisão, as alternativas descartadas e o que a escolha custa.

| # | Decisão | Status |
|---|---|---|
| [0001](0001-banco-privado-e-direct-vpc-egress.md) | Cloud SQL só com IP privado, acessado por Direct VPC egress | Aceita |
| [0002](0002-migrations-por-cloud-run-job.md) | Migrations por Cloud Run Job dentro da VPC | Aceita |
| [0003](0003-imagem-fora-do-terraform.md) | A imagem da aplicação é trocada fora do Terraform | Aceita |
| [0004](0004-ci-cd-com-workload-identity-federation.md) | CI/CD com Workload Identity Federation, sem chave de service account | Aceita |
| [0005](0005-pool-do-wif-no-bootstrap.md) | Pool e provider do WIF no `bootstrap` | Aceita |
| [0006](0006-alertas-de-uptime-e-5xx-por-email.md) | Alertas de uptime e de erros 5xx, avisados por e-mail | Aceita |
| [0007](0007-orcamento-no-bootstrap.md) | Orçamento de custos no `bootstrap`, com canal de e-mail próprio | Aceita |

## Formato

Cada arquivo segue: **Status**, **Contexto**, **Decisão**, **Alternativas consideradas** e **Consequências**. Uma decisão revista não é apagada: ganha um ADR novo que a substitui, e o antigo passa a "Substituída".
