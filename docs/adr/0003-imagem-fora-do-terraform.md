# 0003. A imagem da aplicação é trocada fora do Terraform

**Status:** Aceita · **Data:** 2026-11-16

## Contexto
O Cloud Run e o Job de migrations precisam de uma imagem para existir, mas a imagem real muda a cada commit da aplicação, num ritmo bem diferente do da infraestrutura. Além disso, o Artifact Registry é criado pelo próprio Terraform, então não há imagem real disponível no primeiro `apply`.

## Decisão
- O Terraform cria o Cloud Run e o Job com uma imagem de exemplo (`us-docker.pkg.dev/cloudrun/container/hello`), definida por padrão na variável `container_image`.
- Os dois recursos têm `lifecycle { ignore_changes = [ ...image ] }`: o Terraform não tenta reverter a imagem que o pipeline publicou.
- O pipeline é quem builda, envia a imagem (tag igual ao SHA do commit) e a aplica no Job e no serviço.

## Alternativas consideradas
- **Terraform controlando a imagem:** cada deploy viraria um `terraform apply`, misturando infraestrutura com entrega da aplicação e exigindo ao pipeline permissões de Terraform. Descartada.
- **Sem valor padrão para a imagem:** um `apply` do zero (por exemplo, depois de um `destroy`) falharia, porque o registry recém-criado está vazio.

## Consequências
- **Bom:** um `apply` funciona do zero; infra e aplicação têm ciclos independentes; as tags imutáveis do registry (uma por commit) deixam cada deploy rastreável até o código.
- **Custo:** o estado real da imagem em execução não está no Terraform. Para saber qual versão roda, é preciso consultar o Cloud Run.
- **Atenção:** depois de um `destroy`, o registry volta vazio e a imagem precisa ser reenviada; basta disparar o workflow de deploy.
