# MonetDB
MonetDB é um sistema de gerenciameno de banco de dados (SGDB) relacional colunar para consultas analiticas.

## Objetivo
Documentar tutorias para trabalhar com o SGDB MonetDB   

## Links
[1] Monetdb install: https://www.monetdb.org/documentation-Dec2023/admin-guide/installation/

## Dependências
[1] Monetdb, 11.49.1, SGDB colunar com processamento paralelo e distribuído

## Instalação
Para instalar o MonetDB em sistemas baseados em debia, adicione o seguinte conteúdo ao arquivo `/etc/apt/sources.list.d/monetdb.list` substituindo a palavra `suite` com a versão em `/etc/os-release`
```bash
deb https://dev.monetdb.org/downloads/deb/ suite monetdb
deb-src https://dev.monetdb.org/downloads/deb/ suite monetdb
```

Adicione a chave gpg
```bash
sudo wget --output-document=/etc/apt/trusted.gpg.d/monetdb.gpg https://dev.monetdb.org/downloads/MonetDB-GPG-KEY.gpg
sudo apt-key finger
sudo apt update
```

Finalmente instale com
```bash
sudo apt install monetdb5-sql monetdb-client
```

## Configuração de acesso
Caso queira definir um usuário padrão de acesso para não ter que colocar as credenciais toda vez que acessar o banco, crie na home o arquivo `~/.monetdb` com o seguinte conteúdo:
```
user=monetdb
password=monetdb
language=sql
```

## Server
Operações realizadas e mantidas pelo arquivo system do monetdbd, normalmente localizado em `/usr/local/systemd/system/monetdbd.service`

#### Localizar origem
É possível buscar a localização do server na coluna `Command` listando os processos em top ou htop.
Exemplo:
```
/usr/local/bin/mserver5 --dbpath=/home/dbfarm/banco
```
Onde `--dbpath` monstra o caminho absoluto para o diretorio do banco.

#### Operações
``` bash
~$: monetdbd create $directoryServer/
~$: monetdbd start $directoryServer/
~$: monetdbd stop $directoryServer/
```

## Database
É possivel listar todos os bancos com o comando `monetdb status` onde é apresentado os seguintes estados:
B - Booting
R - Running
S - Stopped
C - Crashed
L - Locked (Manutenção)

OBS: Ao se criar um banco, para acessá-lo deve retirá-lo do modo manutenção. \
OBS: Para destruir um banco, primeiro ele deve ser parado

#### Operações
```bash
~$: monetdb status
~$: monetdb create $databaseName
~$: monetdb release $databaseName # Remove banco de manutenção
~$: monetdb stop $databaseName
~$: monetdb destroy $databaseName
```


## Executar SQL em bash
Para executar comandos SQL utilizando a ferramenta `mclient` é possivel utilizar tanto a própria query, quanto um arquivo SQL.
``` bash
~$: mclient -d $database -s "SELECT * FROM table" 
~$: mclient -d $database < $file.sql
```

## Importação/Exportação de CSV's

#### Importar csv
Importar dados de um csv para tabela \
OBS: USING DELIMITERS utiliza uma sequencia de parâmetros posicionais sendo o primeiro o caractere separador, o segundo de nova linha e o terceiro o de string. \
Caso a string não seja especificada, haverá a inserção de quotes(") no conteúdo.
```sql
sql> COPY INTO <table> FROM '/tmp/file.csv' USING DELIMITERS '|', E'\n', '"' NULL AS '';
```

#### Exportar CSV's
Exportar apenas o esquema (arquivo com queries para recriar o banco)
``` bash
sql> COPY <query> INTO '/tmp/file.csv' USING DELIMITERS '|' NULL AS '';
~$: msqldump -D -d <database> > monetdb_dump.sql        -- Exporta apenas a criação do esquema das tabelas
```

#### Exemplos
**OBS**: Caso não seja colocado a opção `NULL AS` o arquivo csv exportado possuirá a string `null` nos campos vazios.
``` sql
sql> COPY INTO regiao FROM '/tmp/regiao.csv' USING DELIMITERS '|', E'\n', '"' NULL AS '';   --Importar dados
sql> COPY SELECT * FROM usuarios INTO '/tmp/users.csv' USING DELIMITERS '|' NULL AS '';     --Exportar dados
```


## Estatística de dados
Monetdb armazena estatísticas a respeito dos dados na "tabela" storage().
``` sql
sql> ANALYZE sys;                  -- Atualiza estatisticas
sql> SELECT * FROM storage();      -- Consulta todo o storage
```

## Comandos úteis
#### Tabelas, colunas e linhas
```sql
sql>　SELECT table, COUNT(table) AS columns_count, MAX(count) AS row_count FROM sys.storage GROUP BY table ORDER BY columns_count DESC, row_count DESC;
```
