# 0001. Cloud SQL só com IP privado, acessado por Direct VPC egress

**Status:** Aceita · **Data:** 2026-11-16

## Contexto
A API (Cloud Run) precisa falar com um Postgres. O banco guarda dados de usuários e pedidos e não deve ficar exposto à internet.

## Decisão
- O Cloud SQL é criado com `ipv4_enabled = false`, só com IP privado, ligado à VPC por **Private Service Access** (um bloco de IPs reservado e uma conexão com o `servicenetworking`).
- O Cloud Run entra na VPC por **Direct VPC egress**, com `egress = PRIVATE_RANGES_ONLY`: só o tráfego para IPs privados vai pela VPC; o resto sai pelo caminho normal.
- Um Cloud NAT cobre o tráfego de saída de recursos que precisem da internet.

## Alternativas consideradas
- **IP público com redes autorizadas e Cloud SQL Auth Proxy:** mais simples, mas o banco passa a ter um endereço alcançável da internet. Descartada pela exposição.
- **Serverless VPC Access connector:** o mesmo resultado, mas com um recurso extra e custo fixo por instâncias do conector. O Direct VPC egress dispensa o conector.
- **Private Service Connect (PSC) em vez de PSA:** também resulta em IP privado dentro da VPC, mas não traz ganho aqui (rede pequena, um único consumidor) e acrescenta complexidade. Descartada por ora.

## Consequências
- **Bom:** o banco não é alcançável de fora; a única porta de entrada é a VPC.
- **Custo:** o Cloud SQL e o NAT cobram por hora enquanto existirem.
- **Limitação:** nem o notebook de quem desenvolve alcança o banco. Tarefas como migrations precisam rodar dentro da VPC (ver [0002](0002-migrations-por-cloud-run-job.md)) e consultas manuais exigiriam um bastion com túnel IAP, ainda não implementado.
- **`destroy`:** o Google libera com atraso o endereço reservado pelo Direct VPC egress e a conexão privada; o `destroy` pode precisar ser repetido.
