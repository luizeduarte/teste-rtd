# Sistema de Replicação Postgresql do C3SL - Replication Failover
**Rejeitado devido ao patroni controlar o pg_hba.conf e postgresql.conf, aumentando em muito a complexidade de controle para futuros bolsistas**


## Objetivos
1 - Ter uma estrutura primary standby que realiza failover automático  
2 - Caso ocorra uma falha na primary, a standby deve virar new-primary que seja acessível por postgresql.c3sl.ufpr.br  
3 - Caso necessario, a primary original deve sincronizar os dados e a new primary deve virar a standby original  

## Links
[1] 

## Dependências
[1] PostgreSQL, 16.0-1, Sistema de Gerenciamento de Banco de Dados
[2] Patroni, 3.2.2, Sistema de gerenciamento de replicação de banco de dados

## Instalação

