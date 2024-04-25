# Benchmark de Banco de Dados com HammerDB

## Objetivo
Documentar uso e explicação das métricas utilizadas para realizar benchmarks de banco de dados utilizando a ferramenta HammerDB reconhecido pelo TPC, conselho que define as regras para benchmarks. Realizar benchmarks oficiais é extremamente trabalhoso e custoso, assim o conselho disponibiliza o HammerDB como uma opção não oficial, mas que tenta seguir ao máximo as especificações definidas em cada teste.


## Links
[1] Download: https://www.hammerdb.com/download.html \
[2] OLTP metrics: https://www.hammerdb.com/blog/uncategorized/why-both-tpm-and-nopm-performance-metrics/


## Dependências
[1] HammerDB, 4.10, Ferramenta para benchmarks de Banco de Dados.


## Instalação HammerDB
É possivel instalar e utilizar o HammerDB tanto pela interface gráfica como pela linha de comando.

Utilizando o comando wget para baixar o source e descompactando:
```bash
wget https://github.com/TPC-Council/HammerDB/releases/download/v4.10/HammerDB-4.10-Linux.tar.gz
tar -xxzf HammerDB-4.10-Linux.tar.gz
```

Com isso tanto os binários para executar por interface gráfica, como por linha de comando, estarão disponíveis. Além disso, dentro da pasta `scripts` existem executáveis prontos de exemplo em python ou em tcl para testar.

## OLTP
Devido as razões especificadas em Links[2] existem basicamente duas métricas para benchmark, NOPM (New Orders Per Minute) e TPM (Transactions Per Minute). De maneira resumida, quando for realizado a comparação entre bancos iguais, utiliza-se a métrica TPM, enquanto que para bancos distintos utiliza-se NOPM.

#### Execução
Utilizando o executável pronto em `scripts/tcl/postgres/tprocc/pg_tprocc.sh` para testar performance no PostgreSQL.

## OLAP
Para OLAP...
