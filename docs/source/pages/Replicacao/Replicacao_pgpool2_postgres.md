# Sistema de Replicação do C3SL - Replication Failover
MAIS TESTES NECESSÁRIOS PARA ESCRITA DA DOCUMENTAÇÃO
## Objetivo
1 - Ter uma estrutura primary standby que realiza failover automático  
2 - Caso ocorra uma falha na primary, a standby deve virar new-primary que seja acessível por postgresql.c3sl.ufpr.br  
3 - Caso necessario, a primary original deve sincronizar os dados e a new primary deve virar a standby original  

## Links
[1] <https://www.pgpool.net/pgpool-web/contrib_docs/watchdog_master_slave_3.3/en.html>  
[2] pgpool setup: <https://b-peng.blogspot.com/2022/03/pgpool-debian.html>  
[3] auto failback: <https://b-peng.blogspot.com/2022/02/auto-failback.html>  
[4] GOAT: <https://tatsuo-ishii.github.io/pgpool-II/current/example-cluster.html>  
[5] Mesmo de cima atualizado: <https://www.pgpool.net/docs/latest/en/html/example-cluster.html>  
[6] Possiveis erros: <https://klouddb.io/pgpool-issues/>  

## Dependências
[1] PostgreSQL, 16.0-1, Sistema de Gerenciamento de Banco de Dados  
[2] pgpool2, 4.3.7, Sistema de gerenciamento de replicação de banco de dados  

## Instalação
Sistemas baseado em Debian com APT
```bash
apt install pgpool2
apt install postgresql-16-pgpool2
```
## Configuração

