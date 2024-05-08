# Uso do Superset

## Objetivo

Documentar criação de dashboards e gráficos sobre um banco de dados no Superset.

## Links

[1] Tutorial inicial: <https://superset.apache.org/docs/using-superset/creating-your-first-dashboard>  
[2] Lista de gráficos: <https://superset.datatest.ch/chart/list>  
[3] Tutorial sobre visualização de dados: <https://superset.apache.org/docs/using-superset/exploring-data>  

##  Dependências

[1] Superset, 3.1.0

## Criando um dashboard

Depois de ter conectado uma base de dados ao Superset (<https://documentation-db.docs.c3sl.ufpr.br/en/latest/pages/Superset/Superset.html>), crie um dashboard por meio do botão na página inicial ou o ícone "+" no canto superior direito e comece a preenchê-lo com gráficos (charts).

## Criando um gráfico

Para criar um gráfico precisamos de um dataset (uma tabela). Esse dataset pode ser uma das tabelas já existentes no banco de dados, ou pode ser criado a partir de uma query SQL no SQL Lab do Superset. Essa segunda opção nos permite fazer cruzamento de tabelas e obter relações mais complexas entre os dados do banco.

### SQL Lab e datasets

Para fazer uma query SQL personalizada, acesse o SQL Lab na barra de navegação do Superset. Escolha a database (ou cluster) conectada ao Superset que quer utilizar, e o schema (banco) dentro dessa database.

Use a caixa de texto para escrever uma query. É necessário prefixar todas as tabelas que referenciar na query com o nome do schema em que está localizada a tabela.

Depois de rodar a query, salve os resultados para um novo dataset no menu dropdown ao lado de "SAVE". Também é possível criar um novo gráfico diretamente ("CREATE CHART"), mas é necessário criar o dataset (mesmo que posteriormente) para usar as métricas associadas.

Em Datasets, você pode editar um dataset para definir algumas informações sobre ele; por exemplo, escolher quais colunas devem ser tratadas como dimensões do gráfico, quais são temporais etc.

### Customizando o gráfico

Com um dataset pronto, selecione o tipo de gráfico que quer usar. Cada tipo de gráfico usa uma ou mais colunas do dataset como dimensões e uma ou mais métricas. Veja em [[2]](#links) uma coleção de gráficos possíveis e seu uso na prática com alguns dataset pré-estabelecidos.

Na aba "CUSTOMIZE", várias informações sobre o gráfico podem ser personalizadas, incluindo: cores, etiquetas e suas orientações (ex. gráfico de barras), formatação de números, tamanho etc.

Veja em [[1]](#links) e [[3]](#links) mais detalhes sobre customização de um dashboard e criação e customização de um gráfico.
