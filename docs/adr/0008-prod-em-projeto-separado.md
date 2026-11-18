# 0008. Produção em projeto GCP separado, com deploy manual por GitHub Environment

**Status:** Aceita · **Data:** 2026-11-18

## Contexto
O ambiente `dev` existe e o objetivo da fase 7 era criar o `prod` reaproveitando os mesmos módulos. Dois problemas apareceram:

- Os módulos têm **nomes fixos** (`api-sa`, `deploy-sa`, `auth-secret`, `migrate-database`, `psa-ip-ranger`, `api_user`...). No mesmo projeto, um segundo ambiente colidiria nesses nomes.
- O pipeline de deploy do `dev` lê o projeto, o provider do WIF e a service account de variáveis do repositório. Com um único conjunto de variáveis, ele só sabe apontar para um lugar.

## Decisão
- **Projeto GCP separado para o `prod`**, com faturamento ligado. Os módulos não mudaram uma linha: os nomes fixos não colidem porque cada projeto tem o seu próprio espaço de nomes. Só os valores passados em `envs/prod/main.tf` ganharam o sufixo `prod` (`vpc-prod`, `prod-instance`, `api-prod-repository`...), para o console não confundir.
- **State no mesmo bucket**, com `prefix = "envs/prod"`. O bucket continua no projeto do `bootstrap`; o prefixo separa o state de cada ambiente.
- **Pool e provider do WIF continuam no `bootstrap`**, um só para os dois ambientes ([0005](0005-pool-do-wif-no-bootstrap.md)). O `prod` lê o nome do pool por `terraform_remote_state`, e a `deploy-sa` do projeto novo aceita tokens desse pool. O `apply` criou o vínculo sem erro, e o primeiro deploy mostrou que a troca de token funciona entre os projetos.
- **Deploy do `prod` por um workflow próprio** (`deploy-prod.yml`), só com `workflow_dispatch` (nunca sai sozinho num push) e com `environment: prod`. O **GitHub Environment `prod`** guarda as quatro variáveis do projeto novo (`GCP_PROJECT_ID`, `GCP_REGION`, `WIF_PROVIDER`, `DEPLOY_SA_EMAIL`) e restringe o ambiente ao branch `main`. As variáveis de um ambiente valem mais que as do repositório quando o job declara o ambiente; o `dev` segue com as variáveis do repositório.
- **Alertas próprios do `prod`:** o módulo `observability` é chamado de novo, então o `prod` ganha canal, uptime check e alertas dentro do seu projeto.

## Alternativas consideradas
- **Mesmo projeto, nomes com sufixo de ambiente:** exigiria parametrizar todos os nomes fixos dos módulos. Menos isolamento: um erro de IAM ou de cota no `dev` poderia atingir o `prod`, e o custo de cada ambiente se misturaria na mesma fatura sem separação.
- **Um bucket de state por ambiente:** isola mais, mas é mais um recurso para manter e o bucket do `bootstrap` já tem versionamento e proteção.
- **Um pool de WIF por projeto:** isola mais, mas duplica o que já funciona e reabre o problema do ID de pool reservado por cerca de 30 dias após apagar.
- **Um workflow só, com escolha de ambiente:** é o desenho mais enxuto e fica como melhoria. Pediria um parâmetro de entrada no `workflow_dispatch` e um `dev` também como Environment; para esta fase, um arquivo separado é mais fácil de ler.
- **Aprovação de revisor no Environment:** é o jeito de mercado de proteger produção, mas a tela do Environment, neste repositório privado, não ofereceu essa regra. Provavelmente é limite do plano do GitHub; não confirmei na documentação.

## Consequências
- **Bom:** o `prod` foi criado com `46 to add, 0 to change, 0 to destroy` e o primeiro deploy pelo pipeline funcionou, com `/health` respondendo `{"status":"ok"}`. Módulos reaproveitados sem alteração.
- **Proteção do `prod`:** só o `main` pode usar o Environment, e o deploy exige um clique. Sem revisor obrigatório, quem tem acesso de escrita ao repositório pode disparar o deploy do `prod`.
- **Mesmo pool de WIF para os dois projetos:** o provider decide quem entra (este repositório); o binding da `deploy-sa` de cada projeto decide o que entra pode usar. Restringir o `prod` a um `assertion.environment` ou ao `ref` do `main` continua como melhoria.
- **Custo:** dois ambientes com Cloud SQL e NAT cobram o dobro por hora enquanto estiverem de pé. O combinado é criar, demonstrar e destruir no mesmo dia.
- **Limitação:** o módulo `observability` tem o nome do canal fixo ("Alertas API dev"), que aparece também no `prod`. É só texto, mas é enganoso.
- **Limitação:** o `terraform apply` do `prod` continua manual, e os dois ambientes compartilham o mesmo bucket de state, então quem lê o state do `dev` também lê o do `prod`.
- **Operação:** a imagem inicial do `prod` é a de exemplo do Google (`hello`) até o primeiro deploy, como no `dev` ([0003](0003-imagem-fora-do-terraform.md)).
