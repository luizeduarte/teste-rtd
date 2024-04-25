# Superset

## Objetivo
Documentar método de instalação e conexão ao Clickhouse.

## Links
[1] Instalação e conexão: https://dianper.medium.com/embedding-superset-dashboards-with-clickhouse-data-into-net-web-application-a-step-by-step-guide-dcc1bb1c104b  
[2] Mudar senha: https://gist.github.com/morrismukiri/0a7017c6a40b986ef383eb7b18e60f05  
##  Dependências
[1] Docker, 26.0.0

##  Criar Conexão
```bash
docker network create --driver bridge local-network 
```
##  Superset
### Start
```bash
docker run -d -p 8088:8088 \
             -e "SUPERSET_SECRET_KEY=$(openssl rand -base64 42)" \
             -e "TALISMAN_ENABLED=False" \
             --network local-network \
             --name superset apache/superset:3.1.0
```
### Criar conta
(Atualizar dados conforme desejado)
```bash
docker exec -it superset superset fab create-admin \
              --username admin \
              --firstname Admin \
              --lastname Admin \
              --email admin@localhost \
              --password admin
```

### Configuração
```bash
# upgrade db
$ docker exec -it superset superset db upgrade

# optional(Carregar exemplos para teste)
$ docker exec -it superset superset load_examples

# initialize
$ docker exec -it superset superset init
```

### Login
Acessar Superset por localhost:8088 e conectar com usuário e senha definidos no passo Criar Conta

### Mudar senha de usuário
No docker do superset:  
```bash
flask fab reset-password --username user --password newPassword

or

superset fab reset-password --username user --password newPassword
```

##  Clickhouse
### Execução em Docker (única maneira que deu certo)
```bash
docker run -d -p 8123:8123 -p 9000:9000 \
                -e "CLICKHOUSE_USER=default" \
                -e "CLICKHOUSE_PASSWORD=admin" \
                --network local-network \
                --name my-clickhouse-server \
                --ulimit nofile=262144:262144 clickhouse/clickhouse-server
```
### Acesso ao Clickhouse
```bash
docker exec -it my-clickhouse-server /bin/bash
clickhouse client
```

##  Conexão do Clickhouse ao Superset
### Configuração
Para conectar o Clickhouse ao Superset você deve acessar o container do superset e instalar o conector e modificar(ou criar) o arquivo de requerimentos.
```bash
# access the container
$ docker exec -it superset /bin/bash

# write and create file
$ echo "clickhouse-connect>=0.6.8" >> ./requirements/local.txt

# check if it's right
$ cat requirements/local.txt

# install the connector
$ pip install -r ./requirements/local.txt
```
E então sair do container e reiniciar o superset
```
docker restart superset
```
### Conexão
1.  Procure onde criar uma nova conexão no Superset (no momento da escrita deste documento se encontrava em um símbolo "+" no canto superior direito)
2.  Em "SUPPORTED DATABASES" procure "Clickhouse Connect(Superset)" (ou algo próximo)
3.  Preencha os dados de acordo com as informações nos passos "Clickhouse/Execução em Docker (única maneira que deu certo)". Exemplo com os dados deste documento:
-   HOST = my-clickhouse-server (--name)
-   PORT = 8123 (-p 8123:8123, default do clickhouse)
-   DATABASE NAME = default (default do Clickhouse)
-   USERNAME = default (CLICKHOUSE_USER)
-   PASSWORD = admin (CLICKHOUSE_PASSWORD)
-   DISPLAY NAME = Clickhouse (Nome que irá aparecer no superset, fica a cargo do usuário)
4.  Caso ainda hajam dúvidas conferir as duas imagens neste mesmo diretório
5.  Clique em finalizar
