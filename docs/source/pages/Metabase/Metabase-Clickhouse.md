# Metabase
Ferramenta open-source para visualização e análise de dados por meio de interface gráfica

## Objetivo
Documentar instalação e como conectar ao Clickhouse

## Links
[1] Instalar Metabase e Conectar ao clickhouse: https://github.com/ClickHouse/metabase-clickhouse-driver \
[2] Adicionar base de dados : https://www.metabase.com/docs/latest/databases/connecting 

## Dependências
[1] Clickhouse, v24.1.5.6-stable, Sistema de Gerênciamento de Banco de Dados colunar (TESTADO NA VERSÃO 24,VERSÕES ANTERIORES PODEM NÃO FUNCIONAR)


## Instalação (Debian/Ubuntu)
1.  Faça o download da verção mais recente do Metabase em https://www.metabase.com/start/oss/jar
2.  Crie um diretório para o metabase e coloque metabase.jar dentro dele
3.  Crie um sub-diretório chamado plugins
4.  Faça o download do driver do clickhouse para o Metabase em https://github.com/ClickHouse/metabase-clickhouse-driver/releases
5.  Dentro do diretório base do metabase rode
    ```bash
    MB_PLUGINS_DIR=./plugins; java -jar metabase.jar
    ```
6. Mesma coisa dos últimos tópicos mas em bash, (METABASE_VERSION e METABASE_CLICKHOUSE_DRIVER_VERSION se referem às mais atuais no momento da escrita deste tutorial):
    ```bash
    export METABASE_VERSION=v0.47.2
    export METABASE_CLICKHOUSE_DRIVER_VERSION=1.2.2

    mkdir -p mb/plugins && cd mb
    curl -o metabase.jar https://downloads.metabase.com/$METABASE_VERSION/metabase.jar
    curl -L -o plugins/ch.jar https://github.com/ClickHouse/metabase-clickhouse-driver/releases/download/$METABASE_CLICKHOUSE_DRIVER_VERSION/clickhouse.metabase-driver.jar
    MB_PLUGINS_DIR=./plugins; java -jar metabase.jar
    ```

## Conexão ao Clickhouse
1.  Acesse o Metabase em localhost:3000
2.  Siga a sequência de criação de conta
3.  No passo de conexão ao BD escolha clickhouse
4.  Preencha o formulário com os dados do seu banco (Usuário padrão é default e port padrão é 8123)

## Adicionar nova base de dados
1. Vá em settings -> Admin settings -> Setup -> Add a database

## Criar uma imagem de Docker do Metabase com o driver do Clickhouse
1.  Para criar uma imagem Docker do Metabase siga o seguinte script:
    ```bash
    git clone https://github.com/ClickHouse/metabase-clickhouse-driver.git
    cd metabase-clickhouse-driver 
    ./build_docker_image.sh v0.47.2 1.2.2 my-metabase-with-clickhouse:v0.0.1
    docker run -d -p 3000:3000 --name my-metabase my-metabase-with-clickhouse:v0.0.1
    ```
No qual v0.47.2 é a versão do Metabase, 1.2.2 é a versão do driver do Clickhouse e my-metabase-with-clickhouse:v0.0.1 é a tag do Docker

##  Detalhes importantes:
    Ao rodar o Metabase pela primeira vez ele irá criar uma conta,não foi descoberto como mudar a senha LEMBRE-A.
    Caso estiver rodando em docker, é possível matar o docker e ao dar run novamente será criado uma nova conta.
    
