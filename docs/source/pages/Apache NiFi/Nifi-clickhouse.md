# Nifi -> Clickhouse

## Objetivo
Relizar uma conexão entre Apache Nifi e Clickhouse, montanto um fluxo de dados simples e salvando em clickhouse.

## Links
[1] Connect Nifi Clickhouse: https://clickhouse.com/docs/en/integrations/nifi

## Dependências
[1] Clickhouse, v24.1.5.6-stable, Sistema de Gerênciamento de Banco de Dados colunar
[2] Nifi, 1.25.0, Controle de fluxo de dados

## Setup
Baixe o conector do clickhouse para nifi `clickhouse-jdbc-0.5.0-all.jar` em [Clickhouse-java](https://github.com/ClickHouse/clickhouse-java/releases).  
Foi testado com novas versões, entretando apenas a 0.5.0 funcionou.
```bash
wget https://github.com/ClickHouse/clickhouse-java/releases/download/v0.5.0/clickhouse-jdbc-0.5.0-all.jar
```

Dentro da aba `operate` acesse as configurações (ícone de engrenagem), vá para a aba `controller services` e adicione `DBCPConnectionPool` buscando a partir de um novo controle (ícone `+`).  
Acesse as configurações do novo serviço de controle (icone de engrenagem ao final) e adidcione os seguintes parâmetros na aba `properties`. 

| Campo | Conteúdo |
| ---   | ---      |
| Database Connection URL     | jdbc:ch:https://hydrapostgres.c3sl.ufpr.br:8123/default?ssl=false |
| Database Driver Class Name  | com.clickhouse.jdbc.ClickHouseDriver |
| Database Driver Location(s) | /opt/nifi/nifi-current/extensions/clickhouse-jdbc-0.5.0-all.jar |
| Database User               | default |
| Password                    | <Senha> |

Renomeie o nome em `settings` para Clickhouse JDBC e clique em aplicar.  
Finalmente clique no simbolo de raio para dar enable.  
Caso tenha ocorrido algum erro aparecerá um ícone laranja entre o ícone de livro e o nome.

