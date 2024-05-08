# Postgresql

## Objetivo
Documentar método de instalação para sistemas de produção, além de técnicas de otimização como tuning, particionamento e índices.


## Links
[1] Instalação: <https://www.postgresql.org/download/linux/debian/>  
[2] Tuning: <https://vladmihalcea.com/postgresql-performance-tuning-settings/>  
[3] Documentação de parâmetros: <https://postgresqlco.nf/doc/en/param/>  
[4] Upgrade cluster: <https://medium.com/@sozcandba/postgresql-version-upgrade-pg-upgradecluster-934dbdaecc76>  
[5] Indice outra particao: <https://www.postgresql.org/docs/current/manage-ag-tablespaces.html>  


## Dependências
[1] PostgresSQL, 16.0-0, Sistema de Gerênciamento de Banco de Dados 


## Instalação
Instale de acordo com sua distribuição na [documentação](https://www.postgresql.org/download/) ou execute em sistemas com apt
```bash
sudo apt-get install postgresql-16
```


## Gerenciar cluster
Para gerenciamento de clusters existem duas formas. Uma com systemctl e outra com os binários do postgres que vem na instalação.  
Para utilizar o systemctl é recomendado que sempre se utilize a versão junto ao nome do cluster como parâmetros pois assim o systemctl saberá com qual trabalhar. Caso não seja especificado pode ser que o comando não funcione **ou haverá algum desastre**.  
**OBS: Caso seja utilizado pg_ctlcluster para iniciar ou parar um cluster, o systemctl perderá o controle de gerenciar. Para resolver pare o cluster e inicie com systemctl**
```bash
# Check clusters state
pg_lsclusters
# Systemctl
systemctl start postgresql@16-main
systemctl stop postgresql@16-main
systemctl restart postgresql@16-main
# Postgres binaries
pg_ctlcluster 16 main start
pg_ctlcluster 16 main stop
pg_ctlcluster 16 main restart
```


## Cluster create
Para criar um novo cluster postgresql use `pg_createcluster` para especificar o diretório de dados e o local dos arquivos de configuração.  
Por default, os arquivos de configuração serão colocados em `/etc/postgresql/<versao>/<cluster_name>`.  
Exemplo para o diretório de dados `/home/postgres/16/main` e diretório de configuração `/etc/postgresql/16/main`  
```bash
# pg_createcluster <version> <cluster_name> --datadir=/this/is/some/datapath
pg_createcluster 16 main --datadir=/home/postgres/16/main
# Initialize with systemctl
systemctl start postgresql@16-main
```

Caso seja utilizado `initdb` para criar um novo cluster, não apenas não será visível ao `pg_lsclusters` como também todos os dados serão colocados dentro do mesmo diretório.


## Cluster delete
Para deletar um cluster verifique primeiro a versão junto com o nome do cluster com `pg_lsclusters` em seguida delete o cluster com `pg_dropcluster`  
```bash
# Check cluster version and name
pg_lsclusters
# Drop cluster
pg_dropcluster --stop 16 main
```


## Cluster upgrade
Para atualizar um cluster postgres para uma nova versão primeiramente instale os novos binários  
Ex:
```bash
sudo apt-get install postgresql-<numero da nova versão>
```

OBS: Para atualizações de minor releases apenas atualizar os binarios e reiniciar o server é o suficiente.

Caso queira mudar para uma nova versão, liste os clusters existentes com `pg_lsclusters`  
Ex:
```bash
postgres@c3sl:/root$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory         Log file
15  main    5432 online postgres /home/postgres/15/main /var/log/postgresql/postgresql-15-main.log
16  main    5433 online postgres /home/postgres/16/main /var/log/postgresql/postgresql-16-main.log
```

#### pg_upgradecluster
Uma forma de atualizar é utilizando os binarios pg_upgradecluster.  
Após instalar os novos binarios, delete o cluster criado automaticamente utilizando `pg_dropcluster --stop <nova_versao> <cluster_name>` e deixe apenas o que será atualizado em `pg_lsclusters`.
```bash
postgres@c3sl:/root$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory         Log file
15  main    5432 online postgres /home/postgres/15/main /var/log/postgresql/postgresql-15-main.log
```

Utilize `pg_upgradecluster` para atualizar.  
**ATENÇÃO: Durante o processo de upgrade o acesso externo do cluster será bloquado, sendo acessível apenas com `psql` na própria máquina, você foi avisado.**  
Ex:
```bash
pg_upgradecluster 15 main /home/postgres/16/main
```

Com isso, após a execução verificando com `pg_lsclusters` o cluster antigo aparecerá desligado e o novo ativo com a porta ja trocada. \
Caso queira deletar o antigo cluster use `pg_dropcluster <versao> main`

#### pg_dumpall
Outra opção é copiar todos os dados com os dois clusters online, ajeite os arquivos de configuração postgresql.conf e pg_hba.conf do novo cluster.

```bash
pg_dumpall -p 5432 | psql -d postgres -p 5433
```
Desligue o cluster antigo e altere a porta do novo cluster.


## Chamar comandos por bash
Para rodar comandos pelo utilitário `psql` é possivel chamar em linha de comando ou em arquivos.
```bash
# Linha de comando
psql -d <database> -U <user> -c "SELECT ...."
# Arquivos
psql -d <database> -U <user> < file.sql
```
Com isso, tanto por linha de comando como por arquivo serão executados no banco <database> com o usuário <user>


## Import/Export de dados
#### Import
Para importar...

#### Export
É possível exportar dados utilizando tanto o comando `\COPY` e especificar com `WITH`, como também com SQL.
```SQL
# Exporting all table
postgres=#\COPY customer TO '/my/file/location' WITH (FORMAT CSV, HEADER, DELIMITER ';');
# Export a SQL statement
postgres=#\COPY (SELECT count(*) FROM customer) TO '/my/file/location' WITH (FORMAT CSV, HEADER, DELIMITER ';');
```


## Tunning
Por padrão o postgres vem com uma configuração básica para funcionar com a maioria dos sistemas, o que não é ideal para produção.
Caso seja necessário, é possivel alterar parâmetros e padrões de comportamento que resultem em sua otimização.  
Para isso é possível alterar as configurações no arquivo `postgresql.conf` que pode ser localizado com `SHOW config_file`. Dependendo do parâmetro alterado pode-se atualizar o serviço sem a necessidade de reiniciar com o comando `SELECT pg_reload_conf()`.

#### max_connections
Configura o número máximo de conexões concorrentes que o servidor suporta.  
<Verificar os problemas com altos valores de max_connections>

#### shared_buffers
Configura a quantidade máxima de memória compartilhada que o servidor postgres utiliza. O aumento de shared_buffers também requer o aumento de max_wal_size.
- Recomendação: Configurar valor com 25% da memória disponível, pois para os outros 75% será utilizado para tarefas como cacheamento e conexões.

#### effective_cache_size
Retorna ao planer de consulta do postgres a quantidade de memória disponível para cacheamento tanto em shared_buffers quanto no filesystem. É utilizado para fazer estimativas, não faz alocações efetivamente.
- Recomendação: Configurar entre 50% e 75% da memória disponível.

#### work_mem
Configura a quantidade máxima de memoria que uma consulta pode usar em dados temporários como ORDER BY, Hash Joins, Hash Aggregate e Window Functions.
- Recomendação: Depende da complexidade das queries. Além disso work_mem multiplicado por max_connections resulta no uso máximo de memória transiente.

#### maintenance_work_mem
Configura a quantidade de memória disponível para operações de manutenção como VACUUM, criação de indices e etc.

#### wal_buffers

#### effective_io_concurrency

#### random_page_cost/seq_page_cost

#### log_min_duration_statement
Configura o tempo de execução mínimo para uma consulta ser registrada no log, util para debugging.
- Recomendação: Por default é desativado com -1. Entretanto é interessante para estudar consultas que consomem mais de 1000ms(1 segundo).


## Otimização em Sistemas Operacionais
Devido a dependência do Postgres ao sistema sobre o qual está funcionando, é possivel alterar comportamentos do SO para otimizar recursos.

#### Huge Pages
Huge pages é uma opção oferecida pelo SO...

#### Alocação de memoria
É possivel alterar a maneira como as alocações são realizadas...


## Particionamento de Tabelas
Em situações em que tabelas não possuem altas taxas de atualização de tuplas, mas sim de inserções ou deleções é possível realizar o particionamento de tais tabelas para aumento de performance.


## Indexes
Realizando alterações nos métodos de acesso aos dados das tabelas com a criação de índices, embora possa reduzir a velocidade de escrita, pode aumentar a performance da árvore de consulta do postgres.

### Tipo\Casos de uso
#### B-Tree
B-Tree serve para ...

#### Hash
Hash serve para ...

#### Gist
Gist serve para ...

#### SP-Gist
SP-Gist serve para ...

#### Gin
Gin serve para ...

#### Brin
Brin serve para ...

### Indices em partição separada
Para fins de aumento de performance, é possível alterar o local em que o postgres armazena seus objetos como índices em uma partição separada. Entretanto esse método apenas funciona de forma relevante se a velocidade de leitura e escrita for maior que a do diretório onde o cluster está.  
Uma solução mais interessante é cacheamento L2ARC com zfs de NVME ou SSD para todo o diretório do cluster.

Para gerar uma partição separada crie uma nova tablespace `fastspace`.
```sql
postgres=# CREATE TABLESPACE fastspace LOCATION '/home/postgres_indexes';
-- List tablespaces
postgres=# \db
```

Em seguida altere os indices do banco. **GARANTA QUE ESTEJA CONECTADO AO BANCO CORRETO**
```sql
-- Alter index
postgres=# ALTER INDEX ALL IN TABLESPACE pg_default SET TABLESPACE fastspace
-- Alter table
postgres=# ALTER TABLE ALL IN TABLESPACE pg_default SET TABLESPACE fastspace
```

Com isso, todos os indices ou tabelas do banco serão alocados no novo diretório em '/home/postgres_indexes'.

Para verificar os indices e os tablespaces:
```sql
SELECT tablename, indexname, tablespace FROM pg_indexes;
SELECT tablename FROM pg_tables WHERE tablespace = 'fastspace';
```

Caso queira restaurar os indices e tabelas para a tablespace original, utilize `ALTER INDEX ALL IN ...` e `ALTER TABLE ALL IN ...` para pg_defaul.  
Finalmente drope a tablespace com
```sql
DROP TABLESPACE fastspace;
```


## Citus - Compressão de dados
Utilizando a extensão Citus para o Postgres, mantida pela microsoft, é possivel além de alterar o método de acesso das tabelas para colunar como também realizar o sharding para consultas distribuidas. \
Uma grande vantagem de alterar o método de acesso para colunar é a compressão de dados. Normalmente tabelas que possuem centenas de gigas de dados podem ser reduzidas a algumas dezenas. Entretato **NÃO É POSSIVEL A CRIAÇÃO DE CONSTRAINTS**.
```sql
test_columnar=# create table funcionario(id serial primary key, nome text, empresa_id integer, CONSTRAINT funcionario_empresa FOREIGN KEY (empresa_id) REFERENCES empresa(id)) using columnar;
ERRO:  Foreign keys and AFTER ROW triggers are not supported for columnar tables
DICA:  Consider an AFTER STATEMENT trigger instead.
test_columnar=#
```

Além disso, embora o desempenho de consultas distribuidas no postgres seja possivel, soluções como replicação em clickhouse são mais manejaveis e possuem um desempenho superior.


## Simulação de streaming
Caso seja necessário testar um ambiente controlado de inserções é possível, além de utilizar soluções complexas como hammerdb, utilizar o comando `\watch` que repete o ultimo comando executado.

Exemplo:
```sql
CREATE TABLE public.goals (
        id bigint PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
        owned_user_id UUID,
        goal_title TEXT,
        goal_data JSON,
        enabled BOOL,
        ts timestamp default now()
);

-- Insert 5000 records at a time into goals table

INSERT INTO public.goals (owned_user_id, goal_title, goal_data, enabled)
SELECT gen_random_uuid(), 'tiTLE', '{"tags": ["tech", "news"]}', false
FROM generate_series(1, 5000) AS i;

/* Using psql's \watch keep insert 5000 records every 2 seconds */
postgres=> \watch
--INSERT 0 5000
--INSERT 0 5000
--INSERT 0 5000
```
