# 0004. CI/CD com Workload Identity Federation, sem chave de service account

**Status:** Aceita · **Data:** 2026-11-16

## Contexto
O GitHub Actions precisa de permissão no GCP para enviar imagens e fazer deploy. A forma comum é criar uma chave JSON de service account e guardá-la como secret do GitHub. Essa chave é uma credencial de longa duração: se vazar, vale até alguém revogá-la.

## Decisão
Usar **Workload Identity Federation (WIF)**:
1. A cada execução, o GitHub emite um token OIDC temporário que identifica o repositório.
2. Um **provider** no GCP confia no emissor do GitHub e só aceita tokens com `repository == K1dou/gcp-serverless-api-terraform` e `repository_owner_id` igual ao da conta. É ele quem decide **quem entra**.
3. Um **binding** `roles/iam.workloadIdentityUser`, concedido a esse repositório sobre a `deploy-sa`, decide **o que quem entrou pode usar**: assumir essa service account.
4. A `deploy-sa` tem só o necessário: `artifactregistry.writer` no repositório de imagens, `run.developer` no serviço e no job, e `iam.serviceAccountUser` na `api-sa` (o Cloud Run roda como ela).

Os valores do pipeline (projeto, região, nome do provider, e-mail da SA) ficam em **Variables** do repositório: não são segredos e não há nenhum secret.

## Alternativas consideradas
- **Chave JSON de service account em um secret do GitHub:** funciona, mas é uma credencial de longa duração. Descartada.
- **Workflow rodando com a conta de um usuário:** não é auditável como identidade de máquina e dá mais permissão do que o pipeline precisa.

## Consequências
- **Bom:** não existe segredo para vazar; os tokens do GCP são de curta duração; um repositório alheio é barrado pela condição do provider.
- **Limitação conhecida:** a condição não restringe a branch. Qualquer branch do repositório que rode um workflow com `id-token: write` consegue assumir a `deploy-sa`. Restringir a `main` (`assertion.ref`) ou usar Environments com aprovação é uma melhoria planejada.
- **Escopo:** o pipeline cobre o deploy da aplicação. O Terraform ainda é aplicado à mão; um pipeline de `plan`/`apply` exigiria uma service account separada, com permissões mais amplas.
