# Sistema de Replicação do C3SL - Replication Failover

## Objetivos
1 - Ter uma estrutura master slave \
2 - Caso ocorra uma falha na master, a slave deve virar new-master que seja acessível por postgresql.c3sl.ufpr.br \
3 - Caso necessario, a master original deve sincronizar os dados e a new master deve virar a slave original

## Links
[1] Master Slave Replication: https://www.highgo.ca/2023/04/03/setting-up-a-postgresql-replica-server-locally/ \
[2] Replication Failover: https://www.highgo.ca/2023/04/10/setting-up-postgresql-failover-and-failback-the-right-way/ \
[3] Log Shipping Standby Servers: https://www.postgresql.org/docs/current/warm-standby.html \
[4] EnterpriseDB log shipping: https://www.enterprisedb.com/blog/how-set-streaming-replication-keep-your-postgresql-database-performant-and-date

## Dependências
[1] PostgreSQL, 16.0-1, Sistema de Gerenciamento de Banco de Dados

## Métodos
Existem diferentes formas de montar um serviço de replicação, cada uma delas com seu caso de uso. Inicialmente os métodos são divididos em replicação física e replicação lógica.

#### Replicação Física
Para a replicação física as alterações são feitas a nivel de armazenamento. Mudanças são replicadas por cópia do WAL do servidor principal para os servidores em standby. Com isso as servidoras em standby oferecem uma cópia exata do servidor principal. Além disso, possui baixo overhead por realizar as operações em baixo nivel. Normalmente utilizado para casos de desastre.

#### Replicação Lógica
Para a replicação lógica as alterações funcionam com base em detectar alterações utilizando mecanismos como triggers ou recursos de decodificação de logica interna. Normalmente utilizado para casos como integração de dados ou datawarehousing.


## Replicação Física (Streaming/Log Shipping)
Para casos de recuperação a desastres será utilizado a replicação física, das quais possui tanto replicação por streaming quanto por log shipping. Por streaming as copias dos arquivos WAL são contínuas, enquanto que por log shipping as copias são realizadas periódicamente por lotes. Devido ao menor estresse de rede, maior controle e do servidor primário não precisar esperar os servidores em standby para realizar commits nas transações será utilizado log shipping.

#### Configuração
Duas máquinas distintas host1 (primario) e host2 (standby), uma instância do postgres na porta 5432 na host1 e conexão com rsync do host1 para o host2 sem senha.

#### Usuário de replicação
Criar um usuário de replicação no host1:
```sql
CREATE ROLE replic_user WITH REPLICATION LOGIN PASSWORD 'rep_password';
``` 

#### Configuração de acesso
Adicionar acesso do usuário rep_user ao arquivo pg_hba.conf no host1:
```conf
host  replication   replic_user  host2.c3sl.ufpr.br   md5
```

#### Configurações do servidor primario (postgresql.conf)
Adicione as seguintes configurações ao arquivo de configuração no host1:
```conf
# Replication
primary_conninfo = 'host=postgres.c3sl.ufpr.br port=5432 user=rep_user password=rep_password'
wal_level = logical #logical works with both physical and logical replications
archive_mode = on

# Replication WAL setup
max_wal_senders = 10
max_wal_size = 10GB
hot_standby = on
hot_standby_feedback = on

# Replication commands
archive_command = 'rsync -a %p host2.c3sl.ufpr.br:/home/postgres/archive/%f'
#restore_command = 'cp /home/postgres/archive/%f %p'
```

#### Cópia do cluster (host2)
Acesse a maquina de replicação (host2) e utilize pg_basebackup para criar uma cópia do cluster. \
Observe que a opção -X está como `fetch`, ou seja, log shipping. Caso fosse streaming seria `-X stream`.
```bash
pg_basebackup -h host1.c3sl.ufpr.br -U replic_user -X fetch -v -R -W -D /home/postgres/16/main
```
Ao finalizar o clone da instância do postgres do host1, comente nas configurações `archive_command` e descomente `restore_command` nas configurações da instância do postgres no host2. \
Crie o arquivo `standby.signal` no host2.
```
touch /home/postgres/16/main/standby.signal
```
E finalmente inicie a instância no host2. \
Com isso o host2 deverá estar bloqueado a escritas e devidamente copiando os arquivos WAL do host1.

#### Consistência do pg_hba (Assunto a pesquisar!!!)
Conforme novos acessos são adicionados no pg_hba da servidora principal, os mesmos acessos precisam ser atualizados no pg_hba das servidoras em standby. Pesquisar métodos.

## Promote do servidor standby


## Restauração do servidor primário


