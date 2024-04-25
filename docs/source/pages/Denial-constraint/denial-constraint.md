<img src="https://wallpapercave.com/wp/wp8203288.jpg" width="800" height="300">

# Denial Constraints

Denial Constraints (DC) é um formalismo para a representação de restrições dentro da área de data cleaning. Cada DC representa uma combinação de predicados que, caso sejam verdadeiros simultaneamente, resultam em uma insonsistência dentro do contexto dos dados tratados.

## 1) Exemplificação
A tabela abaixo será usada para exemplificar conceitos e aplicações das Denial Constraints.

|     | Name      | Phone   | Position  | Salary | Hired |
| --- | --------- | ------- | --------- | ------ | ----- |
| t0  | W. Jones  | 202-222 | Developer | $2.000 | 2012  |
| t1  | W. Jones  | 202-222 | Developer | $3.000 | 2010  |
| t2  | J. Miller | 202-333 | Developer | $4.000 | 2010  |
| t3  | D. Miller | 202-333 | DBA       | $8.000 | 2010  |
| t4  | W. Jones  | 202-555 | DBA       | $7.000 | 2010  |
| t5  | W. Jones  | 202-222 | Developer | $1.000 | 2012  |

Dentro dessa base de dados, há duas relações importantes entre os atributos associados:
* As tuplas que possuem {Name, Phone} com mesmos valores também possuem mesmos valores para {Position}. A abstração da DC seria:
```
tx.Name = ty.Name E tx.Phone = ty.Phone E tx.Position != ty.Position é falso
```
* Se existem dois empregados que ocupam a mesma posição, o salário do mais novo não pode ser maior que o do mais antigo. A abstração da DC seria:
```
tx.Position = ty.Position E tx.Hired < ty.Hired E tx.Salary < ty.Hired é falso
```

As DCs acima satisfazem todos os dados da tabela e recebem o nome de **exact DCs**. Nos casos reais, diversas inconsistências são presentes nos dados pelas mais diversas razões, desde a importação dos dados até a transição de esquemas. Para contornar isso, é comum haver um relaxamento das restrições, que por sua vez recebem o nome de **approximate DCs**. Um exemplo para essa restrição relaxada é:
```
tx.Name = ty.Name E tx.Phone = ty.Phone é falso
```
Ou seja, não podem existir dois empregados com mesmos valores para {Name, Phone}. Essa restrição informa uma possível chave primária para a tabela e uma possível inconsistência violada.

## 2) Complexidade
DCs conseguem abranger diferentes tipos de restrições, como dependências funcionais ou de ordenação, o que demonstra ser um importante formalismo para representar o banco de dados.
A complexidade computacional na descoberta de Denial Constraints leva em consideração não só a quantidade de tuplas, mas também a quantidade de atributos. Como as DCs são relações entre dois atributos diferentes, podendo ser de diferentes tipos, como equações ou inequações, cada coluna a mais na tabela faz com que a complexidade aumente. Além disso, **approximate DCs** tem um custo maior que as **exact DCs**, pois é necessário acompanhar a quantidade de predicados que ferem as DCs para calcular a aceitação posteriormente.

## 3) Formalismo e definições
Considere a seguinte sintaxe:
* **r:** instância relacional com esquema R(A1, ..., An)
* **t:** tupla de r
* **O:** conjunto de relações (=, !=, <, ≤, >, ≥)
* **p:** predicado no formato t<sub>x</sub>.A<sub>i</sub> o t<sub>y</sub>.A<sub>j</sub> | A<sub>i</sub>, A<sub>j</sub> ∈ R; t<sub>x</sub>, t<sub>y</sub> ∈ r; o ∈ O
* **P:** conjunto do espaço dos predicados
* **e<sub>tx,ty</sub>:** evidence é o conjunto de predicados em que a dupla t<sub>x</sub>, t<sub>y</sub> satisfazem, ou seja, e<sub>tx,ty</sub> = {p \| p ∈ P, tx, ty \|= p}
* **E<sub>r</sub>:** conjunto das evidences de r, ou seja, E<sub>r</sub> = {e<sub>tx, ty</sub> \| ∀t<sub>x</sub>, t<sub>y</sub> ∈ r}

 
### 3.1) Definição 1 (Denial Constraints)
Uma denial constraint φ sobre a instância de relação r possui a seguinte declaração:

```
φ : ∀tx, ty ∈ r, ¬(p1 ∧ . . . ∧ pm)
```

onde φ é verdadeiro se e apenas se algum dos predicados p1, ..., pm é falso.

tx, ty |= φ é usado para dizer que o par tx, ty satisfazem φ, e tx, ty 6 |!= φ caso contrário.

### 3.2) DC mínima
Uma DC φ1 é mínima se não existir nenhum outro φ2 tal que ambos são satisfeitos por r e os predicados de φ2 for um subconjunto dos predicados de φ1.

### 3.3) DCs para os exemplos visto anteriormente
```
φ1 : ¬(tx.Name = ty.Name ∧ tx.Phone = ty .Phone ∧ tx.Position != ty .Position)
```
```
φ2 : ¬(tx.Position = ty.Position ∧ tx.Hired < ty .Hired ∧ tx.Salary < ty .Salary))
```

A restrição é construida no erro, e negar a restrição é satisfazer a denial constraint. Ou seja, nos exemplos acima, se existir duas tuplas com Name, Phone iguais e Position diferente, a DC será falsa ou não satisfeita. O mesmo vale para o φ2, em que se o salário de um funcionário ser maior que o outro, ser contratado mais recentemente e possuir posição igual ao outro, a DC não será satisfeita.

### 3.4) Quantificação das violações
É interessante saber quantificar o número de violações para melhor representar approximate constraints. Para isso, o cálculo da proporção entre a quantidade de violações entre um par de tuplas em relação ao total de pares possíveis pode servir para realizar essa quantificação.
```
g1(φ, r) = |{(tx, ty) ∈ r | (tx, ty) |!= φ}| / |r| · (|r| − 1)
```

### 3.5) Definição 2 (Approximate Denial Constraints)
Dado um erro ε, 0 ≤ ε < 1, uma denial constraint φ é ε-approximate em r se, e somente se, g1(φ,r) for menor que ε.


## 4. DCFinder
DCFinder é um algoritmo que busca encontrar approximate e exacts Denial Constraints a partir de um dataset de entrada. Resumidamente, o algoritmo realiza os seguintes passos:
1. Define-se o conjunto do espaço dos predicados a partir do esquema do dataset de entrada.
2. Define-se Position List Indexes (PLIs) a partir das tuplas do dataset de entrada. 
3. Define-se o conjunto de evidences a partir dos resultados dos passos 1 e 2.
4. Busca Em Profundidade no conjunto de evidences para encontrar as minimals DCs.

### 4.1 Espaço dos Predicados
Para cada par de atributos, são aplicadas todas as relações presentes em O. Para minizar custos computacionais e melhorar resultados, as seguintes restrições são consideradas nessa fase:
* As únicas relações aplicadas sobre strings são o subconjunto de O {=, !=}.
* Todas as relações presentes em O são aplicadas sobre atributos numéricos.
* Para dois atributos diferentes, apenas considera-se seus predicados se ao menos 30% de seus valores são mutuamente comuns.

Para exemplificar, segue P do exemplo anterior:

| PREDICADOS                                            |                                                  |
| ----------------------------------------------------- | ------------------------------------------------ |
| p<sub>1</sub>: t<sub>x</sub>.Name>.Name = t<sub>y</sub>.Name     | p<sub>y10</sub>: t<sub>x</sub>.Salary ≤ t<sub>y</sub>.Salary | 
| p<sub>2</sub>: t<sub>x</sub>.Name 6 = t<sub>y</sub>.Name         | p<sub>11</sub>: t<sub>x</sub>.Salary > t<sub>y</sub>.Salary |
| p<sub>3</sub>: t<sub>x</sub>.Phone = t<sub>y</sub>.Phone         | p<sub>12</sub>: t<sub>x</sub>.Salary ≥ t<sub>y</sub>.Salary |
| p<sub>4</sub>: t<sub>x</sub>.Phone 6 = t<sub>y</sub>.Phone       | p<sub>13</sub>: t<sub>x</sub>.Hired = t<sub>y</sub>.Hired   |
| p<sub>5</sub>: t<sub>x</sub>.Position = t<sub>y</sub>.Position   | p<sub>14</sub>: t<sub>x</sub>.Hired 6 = t<sub>y</sub>.Hired |
| p<sub>6</sub>: t<sub>x</sub>.Position 6 = t<sub>y</sub>.Position | p<sub>15</sub>: t<sub>x</sub>.Hired < tt<sub>y</sub>y.Hired |
| p<sub>7</sub>: t<sub>x</sub>.Salary = t<sub>y</sub>.Salary       | p<sub>16</sub>: t<sub>x</sub>.Hired ≤ t<sub>y</sub>.Hired   |
| p<sub>8</sub>: t<sub>x</sub>.Salary 6 = t<sub>y</sub>.Salary     | p<sub>17</sub>: t<sub>x</sub>.Hired > t<sub>y</sub>.Hired   |
| p<sub>9</sub>: t<sub>x</sub>.Salary < t<sub>y</sub>.Salary       | p<sub>18</sub>: t<sub>x</sub>.Hired ≥ t<sub>y</sub>.Hired   |

### 4.2 PLIs
PLIs são estruturas que, para cada atributo de um dataset, armazenam tuplas de valores em comuns. Considere o cluster c = 〈k, l〉, onde k é um valor para dado atributo da tabela e l uma lista das tuplas que possuem tal valor. A lista l mantém os elementos em ordem crescente. Por exemplo:
<img src="https://codimd.c3sl.ufpr.br/uploads/upload_a721d8a0d6e5a3819deb373f3a084501.png" width="500">

### 4.3. Conjunto Evidence
Como o evidence é um conjunto com todos os predicados de um par de tuplas, armazenar todos os evidences pode ser muito custoso computacionalmente. Além disso, diferentes evidences podem ter o mesmo conjunto de predicados, e guardá-los se torna uma redundância. Para reduzir os custos, DC Finder usa indexação de atributos e seleção de predicados.
Assuma que evidences são armazenados em um array virtual B, e seus índices são calculados pelas tuplas t<sub>x</sub>, t<sub>y</sub> e r. O índice de B[tpid] é:
```
tpid(tx, ty , r) = |r| x + y
```
Para preencher B com os evidences, poderia percorrer todas as tuplas e, para cada uma, associar uma outra tupla e calcular seus predicados. Essa é uma abordagem custosa e simplória. Para evitar a explosão desse processamento, DC Finder faz uso de PLIs para avaliar associações de valores dos atributos para o par de tuplas e seus predicados satisfeitos. Além disso, também usa o conceito de baixa seletividade de predicados, ou seja, se esses predicados são satisfeitos por várias tuplas.
DC Finder constrói o conjunto de evidences em três estágios: Inicialização, Reconstrução e Contagem.

