# 0002. Migrations por Cloud Run Job dentro da VPC

**Status:** Aceita · **Data:** 2026-11-16

## Contexto
O banco só tem IP privado ([0001](0001-banco-privado-e-direct-vpc-egress.md)). As tabelas precisam ser criadas por `prisma migrate deploy`, e esse comando precisa alcançar o banco. Um runner do GitHub Actions e o notebook de desenvolvimento estão fora da VPC.

## Decisão
Um **Cloud Run Job** (`migrate-database`) roda a mesma imagem da API, na mesma VPC, com a mesma service account e o mesmo segredo `DATABASE_URL`, executando `node_modules/.bin/prisma migrate deploy` e terminando. O pipeline apenas **dispara** o job (`gcloud run jobs execute --wait`) antes do deploy da API: se as migrations falham, o deploy não acontece.

## Alternativas consideradas
- **Migrar no startup do container:** várias instâncias subindo ao mesmo tempo competem pelas mesmas migrations. Descartada.
- **Rodar a partir do runner do CI com Cloud SQL Auth Proxy:** exigiria IP público no banco, o que contraria [0001](0001-banco-privado-e-direct-vpc-egress.md).
- **Runner self-hosted dentro da VPC:** funciona, mas é mais caro e dá mais trabalho de manter.
- **Rodar à mão a partir de um bastion:** não é repetível nem auditável.

## Consequências
- **Bom:** as migrations rodam dentro da rede privada, de forma repetível e antes de cada deploy, reaproveitando a imagem que já existe (ela já tem o Prisma, as migrations e o `prisma.config.ts`).
- **Custo:** um recurso a mais no Terraform e o job precisa ter a imagem atualizada pelo pipeline (ver [0003](0003-imagem-fora-do-terraform.md)).
- **Limitação:** o job reutiliza a `api-sa`, que então tem a mesma permissão de leitura do segredo do banco para migrar e para servir. O ideal em produção é uma service account própria para migrations.
