# Sistema de Replicação do C3SL - Replication Failover
**Rejeitado devido a inumeros problemas de conexão e restauração**  
**Teoricamente funcionou até o failover, após isso não foi obtido sucesso ao tentar performar rewind e switchover**

## Objetivos
1 - Ter uma estrutura primary standby que realiza failover automático\
2 - Caso ocorra uma falha na primary, a standby deve virar new-primary que seja acessível por postgresql.c3sl.ufpr.br \
3 - Caso necessario, a primary original deve sincronizar os dados e a new primary deve virar a standby original

## Links
[1] https://www.enterprisedb.com/postgres-tutorials/how-implement-repmgr-postgresql-automatic-failover  
[2] https://www.repmgr.org/docs/4.3/index.html  
[3] https://www.repmgr.org/docs/4.3/repmgr-command-reference.html (comandos do repmgr)  
[4] https://raw.githubusercontent.com/2ndQuadrant/repmgr/master/repmgr.conf.sample (explicação de todas as possíveis configurações do repmgr.conf)  
[5] Setup completo: https://medium.com/@victor.boissiere/how-to-setup-postgresql-cluster-with-repmgr-febc2f10c243

## Dependências
[1] PostgreSQL, 16.0-1, Sistema de Gerenciamento de Banco de Dados  
[2] Repmgr , 5.4.1-1.pgdg120+1, Sistema de gerenciamento de replicação de banco de dados

##  Instalação e Configuração
1.  Instalar repmgr tanto no server primary quanto no server standby
    ```bash
    apt-get install repmgr
    ```
2.  Adicione as seguintes linhas a postgresql.conf nos dois servers(por padrão de instação se encontra em /etc/postgresql/16/main):
    ```bash
    max_wal_senders = 10
    max_replication_slots = 10
    wal_level = 'logical'
    hot_standby = on
    archive_mode = on
    archive_command = '/bin/true'
    shared_preload_libraries = 'repmgr'
    ```
3. Crie o usuário repmgr e a database repmgr no banco primary:
    ```bash
    create user repmgr;
    create database repmgr with owner repmgr;   
    ```
4. Dê permissão de superusuario e Replicação para o user repmgr:
    ```bash
    alter role repmgr with superuser;
    alter role repmgr with replication;
    ```
5.  Configure pg_hba.conf nos dois servers(por padrão de instação se encontra em /etc/postgresql/16/main) adicionando as seguintes linhas:
    ```bash
    host    repmgr      repmgr          dbteamvenv.c3sl.ufpr.br     trust
    host    replication repmgr          dbteamvenv.c3sl.ufpr.br     trust
    host    repmgr      repmgr          hydrapostgres.c3sl.ufpr.br	trust
    host	replication repmgr          hydrapostgres.c3sl.ufpr.br	trust
    ```
    dbteamvenv.c3sl.ufpr.br e hydrapostgres.c3sl.ufpr.br foram os servidores usados para teste e escrita desta documentação.  
    dbteamvenv é o server primary e hydrapostgres é o server standby.  
    As duas entradas devem ser alteradas para os servidores que estiverem em uso.  

6.  Mude para o usuário postgres
    ```bash
    su postgres
    ```
7.  Crie um arquivo repmgr.conf nos dois servidores (local a critério do usuário(talvez tenha que estar em algum lugar específico para rodar, mudar no futuro)) com as seguintes linhas:
    ```bash
    node_id=1
    node_name=nodePrimary
    conninfo='host=[hostname do servidor primário] user=repmgr dbname=repmgr connect_timeout=2'
    data_directory='[adicionar diretório de dados do postgres]'
    failover=automatic
    promote_command='/usr/bin/repmgr(*) standby promote -f ./repmgr.conf(**) --log-to-file'
    follow_command='/usr/bin/repmgr(*) standby follow -f ./repmgr.conf(**) --log-to-file --upstream-node-id=%n'
    ```
    ```bash
    node_id=2
    node_name=nodeStandby
    conninfo='host=[hostname do servidor standby] user=repmgr dbname=repmgr connect_timeout=2'
    data_directory='[adicionar diretório de dados do postgres]'
    failover=automatic
    promote_command='/usr/bin/repmgr(*) standby promote -f ./repmgr.conf(**) --log-to-file'
    follow_command='/usr/bin/repmgr(*) standby follow -f ./repmgr.conf(**) --log-to-file --upstream-node-id=%n'
    ```
    
    *:  Conferir onde de fato o script do repmgr foi instalado, no caso de teste em ambos os servidores ele estava em /usr/bin  
    **: Local de repmgr.conf

8.  Registre o nodo primário:
    ```bash
    /usr/bin/repmgr -f ./repmgr.conf primary register
    ```

9.  Clone o servidor primário no servidor standby:
    ```bash
    /usr/bin/repmgr -h [ip do servidor primário] -U repmgr -d repmgr -f ./repmgr.conf standby clone --dry-run
    ```
    A opção --dry-run serve para impedir que o comando seja de fato rodado e te avisa caso haja algum erro ou se tudo está ok.  
    Em caso de sucesso rode novamente sem essa opção.

10. Registre o servidor standby
    ```bash
    /usr/bin/repmgr -f ./repmgr.conf standby register
    ```
11. Rode cluster show em ambos os servidores para visualizar os status de cada um e conferir se todo o processo de instalação correu sem problemas:
    ```bash
    /usr/bin/repmgr -f ./repmgr.conf cluster show
    ```
    Exemplo de saída:
    ```bash
    ID | Name  | Role    | Status    | Upstream | Location | Priority | Timeline | Connection string                                              
    ----+-------+---------+-----------+----------+----------+----------+----------+-----------------------------------------------------------------
    1  | node1 | primary | * running |          | default  | 100      | 1        | host=dbteamvenv user=repmgr dbname=repmgr connect_timeout=10   
    2  | node2 | standby |   running | node1    | default  | 100      | 1        | host=hydrapostgres user=repmgr dbname=repmgr connect_timeout=10
    ```
##Inicialização do serviço de monitoramento
1.  Altere o arquivo /etc/default/repmgrd da seguinte forma(com os seus dados):
    ```bash
    # default settings for repmgrd. This file is source by /bin/sh from
    # /etc/init.d/repmgrd

    # disable repmgrd by default so it won't get started upon installation
    # valid values: yes/no
    REPMGRD_ENABLED=yes

    # configuration file (required)
    REPMGRD_CONF="/path/to/repmgr.conf"

    # additional options
    REPMGRD_OPTS="--monitoring-history"

    # user to run repmgrd as
    REPMGRD_USER=postgres

    # repmgrd binary
    REPMGRD_BIN=/usr/bin/repmgrd

    # pid file
    REPMGRD_PIDFILE=/var/run/repmgrd.pid
    
    #log file
    REPMGRD_LOGFILE=/var/log/repmgrd.log
    ```
2.  Configure o arquivo de log alterando o arquivo /etc/init.d/repmgrd com a seguinte linha:
    ```bash
    start-stop-daemon --start --quiet --background --chuid "$REPMGRD_USER" --make-pidfile --pidfile "$REPMGRD_PIDFILE" --exec "$REPMGRD_BIN" --no-close --      --config-file "$REPMGRD_CONF" $REPMGRD_OPTS >"$REPMGRD_LOGFILE" 2>&1
    ```
3.  Rode a seguinte linha no servidor standby para iniciar o monitoramento automático de failover:
    ```bash
    repmgrd -f /home/postgres/repmgr/repmgr.conf
    ```
