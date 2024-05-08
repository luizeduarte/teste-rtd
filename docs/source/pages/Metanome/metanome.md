# Metanome

Metanome é uma ferramenta de data profiling que realiza analise de um data set por meio de diferentes métodos.

## Instalação
Dependências:
* Java JDK 1.8 ou posterior
* Maven 3.1.0

Para subir a ferramenta do Metanome primeiro crie um diretório Metanome, baixe os arquivos dentro do diretório e os descomprima.
Arquivo zip:
<https://hpi.de/fileadmin/user_upload/fachgebiete/naumann/projekte/repeatability/DataProfiling/Metanome/deployment-1.2-SNAPSHOT-package_with_tomcat.zip>

Em seguida suba o serviço rodando o executável (obs: O terminal ficará travado)
``` bash
source run.sh
```
Por fim acesse a porta <http://localhost:8080/>

Para fechar a aplicação, mate o processo no terminal ou com o PID

## Adicionar Algoritmos
A lista de algoritmos que o Metanome disponibiliza está na seção Metanome Algorithms em
<https://hpi.de/naumann/projects/data-profiling-and-analytics/metanome-data-profiling/algorithms.html>
Baixe o arquivo .jar do algoritmo desejado e o coloque dentro do diretório:
Metanome/backend/WEB-INF/classes/algorithms/
Em seguinda, no frontend na porta 8080 adicione o algoritmo com o botão de soma no campo Choose Algorithm.
Dentro da janela que aparecer selecione o arquivo .jar, coloque um nome em Algorithm Name e salve.
Com isso o novo algoritmo aparecerá como um selecionável.

## Adicionar Dataset
Para adicionar os arquivos a serem trabalhados, coloque o arquivo em:
/Metanome/backend/WEB-INF/classes/inputData/
Acesse o frontend na porta 8080 e clique no botão de adicionar em Select Datasource.
Escolha o arquivo na caixa de seleção em file, configure os parametros conforme o arquivo e salve.

## Execução
Para Executar o Metanome simplesmente escolha o algoritmo a ser usado, o arquivo fonte a ser trabalhado e ajuste os parâmetros na janela Additional configuration, evite deixar o campo Memory (in MB) em branco.
Por fim os resultados serão escritos em
/Metanome/results/


