# 0005. Pool e provider do WIF no `bootstrap`

**Status:** Aceita · **Data:** 2026-11-16

## Contexto
O pool e o provider do Workload Identity Federation ([0004](0004-ci-cd-com-workload-identity-federation.md)) poderiam ficar no ambiente `dev`, junto com o resto. Mas o `dev` é destruído e recriado com frequência para controlar o custo do Cloud SQL e do NAT.

Segundo a documentação do Google, um pool apagado entra em exclusão suave por cerca de 30 dias, durante os quais o ID não pode ser reutilizado (os providers do pool seguem a mesma regra). Recriar o `dev` com o mesmo `github-pool` poderia, então, falhar.

## Decisão
- O **pool e o provider** ficam no `bootstrap`, que roda uma vez e nunca é destruído, junto com o bucket do state. Isso também faz o pool e o provider nascerem uma só vez, independentemente do `dev`.
- As APIs `iam`, `iamcredentials` e `sts` são habilitadas no `bootstrap`, que vem antes do `dev`.
- A **`deploy-sa`, as permissões e o binding** `workloadIdentityUser` ficam no `dev` (módulo `cicd`), porque dependem de recursos do `dev` (serviço, job, repositório, `api-sa`) que são destruídos e recriados.
- O `dev` lê o nome completo do pool por `terraform_remote_state`, a partir dos outputs do `bootstrap`.

## Alternativas consideradas
- **Tudo no `dev`:** mais simples, mas sujeita o pool à regra de 30 dias a cada `destroy`.
- **Pool e provider em uma raiz própria, além de `bootstrap` e `envs`:** isola ainda mais, mas acrescenta mais uma pasta para um único recurso. O `bootstrap` já tem o papel de "infraestrutura que vive fora do ciclo dos ambientes".
- **Data source `google_iam_workload_identity_pool` no lugar do remote state:** consulta a API em vez do state do bootstrap. Mais simples, mas o `terraform_remote_state` é o padrão para compartilhar valores entre states e deixa explícita a dependência.

## Consequências
- **Bom:** o `destroy` do `dev` não toca no pool; o ID nunca precisa ser recriado.
- **Custo:** o `dev` passa a depender do state do bootstrap: o bootstrap precisa ter sido aplicado antes, e quem roda o `dev` precisa ler o bucket de state.
- **Atenção:** o binding exige o nome **completo** do pool (`projects/NÚMERO/locations/global/workloadIdentityPools/github-pool`), não só o ID.
