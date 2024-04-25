# Clickhouse
SGDB colunar open source de consultas analíticas.

## Objetivo
Documentar instalação e formas de configurar um sistema de produção em clickhouse

## Links
[1] Install Clickhouse: https://clickhouse.com/docs/en/install \
[2] Alterar diretório de dados: https://stackoverflow.com/questions/69371385/change-source-directory-in-clickhouse \
[3] Clickhouse Keeper: https://clickhouse.com/blog/clickhouse-keeper-a-zookeeper-alternative-written-in-cpp?loc=keeper-hero

## Dependências
[1] Clickhouse, v24.1.5.6-stable, Sistema de Gerênciamento de Banco de Dados colunar


## Instalação (Debian/Ubuntu)
Seguir os passos conforme [Setup the Debian repository](https://clickhouse.com/docs/en/install#available-installation-options) para adicionar o source ao apt.

Adicione a versão stable aos pacotes do apt.
```bash
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
GNUPGHOME=$(mktemp -d)
sudo GNUPGHOME="$GNUPGHOME" gpg --no-default-keyring --keyring /usr/share/keyrings/clickhouse-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8919F6BD2B48D754
sudo rm -rf "$GNUPGHOME"
sudo chmod +r /usr/share/keyrings/clickhouse-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee     /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
```

Instale usando o apt.
```bash
sudo apt-get install -y clickhouse-server clickhouse-client
```

Finalmente inicie o serviço e acesse o prompt com:
```bash
systemctl start clickhouse-server
clickhouse-client
```

## Mudar diretório de dados
Caso queira alterar o local onde o clickhouse armazena seus dados:
1. Desligue o cluster
```bash
systemctl stop clickhouse-server
```

2. copie os dados da instalação padrão em `/var/lib/clickhouse` para o diretório destino.
```bash
rsync -a -H /var/lib/clickhouse /home/
```

3. Atualize no arquivo de configuração em `/etc/clickhouse-server/config.xml` os locais onde possuir `/var/lib/clickhouse/` para o novo local de instalação.

Para verificar o local de instalação execute: `SELECT * FROM system.databases`

## Importar/Exportar CSV
**OBS: Tabelas no clickhouse são criadas por default como não nulaveis, ou seja, caso seus dados possuam NULL's deve-se especificar como 'Nullable' as colunas na criação da tabela**  

#### Importar
Primeiro crie as tabelas no banco.  
Caso as tabelas estejam em um arquivo, é possível as criar com
```bash
clickhouse-client -d <database> --queries-file create_table_file.sql
```

Para importar um csv, seguindo com base na (documentação)[https://clickhouse.com/docs/en/interfaces/formats#csv], utilizando o client:
```bash
clickhouse-client -d <database> --format_csv_delimiter="|" --query="INSERT INTO test FORMAT CSV" < data.csv
```

Caso queira adicionar outras configrações ao formato do csv, adicione elas após a statement do `clickhouse-client`

#### Exportar
Para exportar dados de uma query em um arquivo CSV utilizando o utilitário `clickhouse-client`
```bash
clickhouse-client -d <database> --query "SELECT <coluna1>, <coluna2> FROM <tabela>" --format CSV
```
