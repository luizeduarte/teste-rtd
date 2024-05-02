# Replicação PostgreSQL para Clickhouse

## Objetivo
Documentar passo a passo para realizar a replicação de um banco em PostgreSQl para Clickhouse.

## Links
[1] Connecting ClickHouse to PostgreSQL: https://clickhouse.com/docs/en/integrations/postgresql \
[2] [experimental] MaterializedPostgreSQL: https://clickhouse.com/docs/en/engines/database-engines/materialized-postgresql

## Dependências
[1] PostgresSQL, 16.0-1, Sistema de Gerênciamento de Banco de Dados  \
[2] Clickhouse, v24.1.5.6-stable, Sistema de Gerênciamento de Banco de Dados colunar

## Observações
É obrigatório que todas as tabelas do banco em postgres possuam identificador primário; caso contrário o Clickhouse não será capaz de replicar as tabelas, as ignorando.

## Postgres config
Altere as configurações em postgresql.conf conforme seguinte para replicações (OBS: é necessário reiniciar o postgres para que essas alterações tenham efeito):
```conf
listen_addresses = '*'
max_replication_slots = 10
wal_level = logical
```

## Usuário de replicação
Crie um usuário no banco postgres para que o clickhouse possa realizar cópias:
```bash
CREATE ROLE clickhouse_user SUPERUSER LOGIN PASSWORD 'ClickHouse_123';
```

## Permissao de acesso
Adicione ao arquivo de permissão pg_hba.conf para que o usuário de replicação possa acessar e recarregue as configurações:
```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    db1             clickhouse_user 192.168.1.0/24          password
```

## Replicar banco
Acesse o client do clickhouse com `clickhouse-client`.

#### Permitir materialized postgres
Devido a replicação de postgres a clickhouse ainda estar em testes, é necessário setar a permissão com:
```bash
SET allow_experimental_database_materialized_postgresql=1
```

Finalmente é possivel realizar a cópia e replicação do banco de postgres para clickhouse com:
```sql
CREATE DATABASE db1_postgres
ENGINE = MaterializedPostgreSQL('<postgres_host>:5432', '<db_name>', 'clickhouse_user', 'ClickHouse_123') SETTINGS materialized_postgresql_schema = 'public';
```
