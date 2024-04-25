# Sistema Distribuido com Clickhouse (Cluster)

## Objetivo
Criar um sistema clickhouse que faça a disribuição de consulta em tabelas entre diferentes máquinas para aumento de performance em consulta. Ao contrário de possuir um único processador carregando páginas de uma grande tabela em memória, uma por uma sequencialmente, o objetivo é que multiplos processadores possam trabalhar independentemente e paralelamente com sua fração de tabela, podendo assim diminuir o gargalo de page fault.

## Links
[1] Clickhouse install: https://clickhouse.com/docs/en/install#available-installation-options \
[2] Clickhouse scaling out: https://clickhouse.com/docs/en/architecture/horizontal-scaling \
[3] Clickhouse keeper: https://clickhouse.com/docs/en/guides/sre/keeper/clickhouse-keeper \
[4] Distributed Table: https://clickhouse.com/docs/en/engines/table-engines/special/distributed#distributed-writing-data \
[5] Distributed and Replicated Clickhouse Configuration: https://medium.com/@merticariug/distributed-clickhouse-configuration-d412c211687c \
[6] Postgres Sharded table: https://clickhouse.com/docs/en/engines/table-engines/integrations/ExternalDistributed \
[7] ON CLUSTER statement: https://clickhouse.com/docs/en/sql-reference/distributed-ddl \
[8] Cluster 3S 1R: https://clickhouse.com/docs/en/architecture/cluster-deployment

## Dependências
[1] Clickhouse, v24.1.5.6-stable, SGDB colunar com paralelismo e distribuido.

## Setup inicial de 3 nodes
Configure cada uma das máquinas com um hostname próprio e com devido acesso a portas no firewall. \
Instale e configure um servidor de clickhouse conforme a [documentação](https://clickhouse.com/docs/en/install#available-installation-options). Em seguida, altere o arquivo de configuração EM TODOS OS HOSTS normalmente localizado em `/etc/clickhouse-server/config.xml` para a configuração dos nodes. \
OBS: Neste tutorial não será necessário editar os arquivos em `/etc/clickhouse-keeper/*` e `/etc/clickhouse-client/*`

#### Configurar nodes
Descomente a tag `<listen_host>::</listen_host>`.

Descomente também a tag do zookeeper para que o clickhouse-keeper possa usá-lo:
```xml
    <zookeeper>
        <node>
            <host>chnode1.domain.com</host>
            <port>9181</port>
        </node>
        <node>
            <host>chnode2.domain.com</host>
            <port>9181</port>
        </node>
        <node>
            <host>chnode3.domain.com</host>
            <port>9181</port>
        </node>
    </zookeeper>
```

Finalmente, adicione a tag `<keeper_server>` para que o clickhouse suba internamente um server do clickhouse-keeper (gerenciador). \
IMPORTANTE: Além de alterar o hostname conforme o domínio, altere a tag `<server_id>` conforme a numeração em `raft_configuration`.
```xml
<keeper_server>
    <tcp_port>9181</tcp_port>
    <server_id>1</server_id>
    <log_storage_path>/var/lib/clickhouse/coordination/log</log_storage_path>
    <snapshot_storage_path>/var/lib/clickhouse/coordination/snapshots</snapshot_storage_path>

    <coordination_settings>
        <operation_timeout_ms>10000</operation_timeout_ms>
        <session_timeout_ms>30000</session_timeout_ms>
        <raft_logs_level>warning</raft_logs_level>
    </coordination_settings>

    <raft_configuration>
        <server>
            <id>1</id>
            <hostname>chnode1.domain.com</hostname>
            <port>9234</port>
        </server>
        <server>
            <id>2</id>
            <hostname>chnode2.domain.com</hostname>
            <port>9234</port>
        </server>
        <server>
            <id>3</id>
            <hostname>chnode3.domain.com</hostname>
            <port>9234</port>
        </server>
    </raft_configuration>
</keeper_server>
```

#### Testando
Após configurar todos os arquivos de configuração e reiniciar o serviço com `systemctl restart clickhouse-server` é possível testar a conexão entre os nodes com o client do keeper `clickhouse-keeper-client`. Ao rodar o comando uma nova interface será aberta, entre com `ruok` para realizar a verificação, se retornar `imok` então significa que está tudo certo.

Outra opção é acessar o client do servidor com `clickhouse-client` e mandar o comando `SELECT * FROM system.zookeeper WHERE path IN ('/', '/clickhouse')`. Caso retorne uma tabela com `Clickhouse`, `task_queue` e `tables` então está tudo certo, caso haja um erro de configuração haverá uma mensagem de erro de conexão.

## Arquiteturas
É possível realizar consultas distribuídas no clickhouse com a engine `ENGINE = Distributed(cluster, database, table[, sharding_key[, policy_name]])`. Porém existem diferentes maneiras de inserir dados em cada node configurado.

#### Table Replication
Realizando uma cópia completa da tabela original em cada um dos nodes, com a engine de distribuição o próprio clickhouse se da o trabalho de distribuir e orquestrar a consulta. \
Embora essa seja uma opção interessante devido a alta tolerância a falhas entre os nodes (falhas de disco e conexão), possui um alto consumo de disco sendo o total de armazenamento utilizado a multiplicação entre o número de replicas e o tamanho da tabela original.

Utilizando `MaterializedPostgreSQL ON CLUSTER` APENAS UMA VEZ EM UM DOS HOSTS é possível criar uma replica completa de um banco em postgres para cada um dos nodes, ao rodar o comando automaticamente todos os nodes recebem e executam o mesmo comando de criação do banco portanto todos os hosts também devem possuir acesso a máquina com postgres.

Para configurar replicações em cada node adicione a seguinte configuração ao `config.xml`
```xml
<remote_servers>
    ...
    <cluster_1S_3R>
        <shard>
            <replica>
                <host>chnode1.domain.com</host>
                <port>9000</port>
             </replica>
             <replica>
                <host>chnode2.domain.com</host>
                <port>9000</port>
             </replica>
             <replica>
                <host>chnode3.domain.com</host>
                <port>9000</port>
             </replica>
        </shard>
    </cluster_1S_3R>
</remote_servers>
```

!!Documentar como distribuir uma query em replicações!!

#### Table Sharding
Utilizando uma função hash, é possivel "quebrar" a tabela original em diferentes fragmentos (shards) e separá-los um para cada node do cluster. \
Por conta da possível falha de um dos nodes levar a impossibilidade de consulta da tabela, esta não é uma opção viável para armazenamento de dados. Entretanto, caso os dados estejam protegidos por outro SGDB como PostgreSQL e backups frequentes, esse é um caminho interessante para processamento de dados analíticos (possivelmente um datawarehouse).

Para configurar um cluster de 3 nodos como shards adicione a seguinte configuração ao `config.xml`
```xml
<remote_servers>
    <cluster_3S_1R>
        <shard>
            <replica>
                <host>chnode1.domain.com</host>
                <port>9000</port>
            </replica>
        </shard>
        <shard>
            <replica>
                <host>chnode2.domain.com</host>
                <port>9000</port>
            </replica>
        </shard>
        <shard>
            <replica>
                <host>chnode3.domain.com</host>
                <port>9000</port>
            </replica>
        </shard>
    </cluster_3S_1R>
</remote_servers>
```

Reinicie os servidores, acesse o client e verifique com `SHOW CLUSTERS` se está tudo funcionando. \
Se estiver tudo conforme, aparecerá um registro com o nome do cluster `cluster_3S_1R`

Finalmente para a distribuição será necessário a criação da tabela com a engine `MergeTree` (obrigatoriamente MergeTree) e a criação da mesma tabela com a engine `Distributed`. Tabelas `MergeTree` serão utilizadas para o armazenamento dos dados e as `Distributed`, que **não armazenam dados** apenas interligam tabelas `MergeTree`, para a distribuição tanto na inserção de dados como na consulta. Além disso, para que não seja necessário acessar todos os nodes, um a um, para a criação da tabela, é possivel utilizar a cláusula `ON CLUSTER 'cluster_3S_1R'` para que os comandos sejam mandados a todos os nodes.

Criação da tabela `MergeTree`:
```SQL
CREATE TABLE pg_test.lineitem ON CLUSTER 'cluster_3S_1R' (
 l_shipdate      timestamp,
 l_orderkey      numeric,
 l_discount      numeric,
 l_extendedprice numeric,
 l_suppkey       numeric,
 l_quantity      numeric,
 l_returnflag    character(1),
 l_partkey       numeric,
 l_linestatus    character(1),
 l_tax           numeric,
 l_commitdate    timestamp,
 l_receiptdate   timestamp,
 l_shipmode      character(10),
 l_linenumber    numeric,
 l_shipinstruct  character(25),
 l_comment       character varying(44) )
 ENGINE = MergeTree()
 ORDER BY (l_linenumber, l_orderkey)
```

Criação da tabela `Distributed` com chave hash `rand()`:
```SQL
CREATE TABLE pg_test.lineitem_distrib ON CLUSTER 'cluster_3S_1R' AS pg_test.lineitem 
ENGINE = Distributed(cluster_3S_1R, pg_test, lineitem, rand());
```

Inserção na tabela distribuida:
```SQL
INSERT INTO pg_test.lineitem_distrib SELECT * FROM postgresql('host:port', 'database', 'table', 'user', 'password')
```

Ao fim da inserção, os dados serão distribuidos entre os nodes nas tabelas `MergeTree`. Para realizar consultas distribuidas simplesmente realize a consulta nas tabelas `Distributed` e o clickhouse se encarregará do resto.

# IN/JOIN Distribuido
Para realizar JOIN's distribuidos será necessário setar a opção `distributed_product_mode` com:
```sql
SET distributed_product_mode = 'allow'
```

## Adicionar novos hosts
Caso seja adicionado novos hosts e reconfigurado a arquitetura na tag `<remote_servers>` será necessário **refazer a base inteira**, uma vez que o clickhouse apenas redireciona o mesmo comando para todos os hosts no cluster especificado.
