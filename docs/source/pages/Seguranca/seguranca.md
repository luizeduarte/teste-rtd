# Segurança em SGBDs

***O texto abaixo foi retirado da pesquisa publicada nesta [página](https://cds.cern.ch/record/2878285/files/summer_report_Guilherme.pdf) em 29/09/2023.***

Este relatório apresenta uma avaliação preliminar das ameaças e vulnerabilidades encontradas na tecnologia de banco de dados, com foco nas soluções de criptografia disponíveis para MySQL, PostgreSQL e Oracle. Especificamente, esta pesquisa investiga a criptografia em repouso e a criptografia transparente. O objetivo principal é fornecer informações sobre as diversas opções de criptografia e estratégias de atenuação oferecidas por esses sistemas de gerenciamento de banco de dados (DBMS). O documento detalha os experimentos realizados para comparar a eficácia dessas soluções.

## Conteúdo
- [Introdução](#Introdução)
- [Ameaças e abordagens de mitigação](#Ameaças-e-abordagens-de-mitigação)
- [Criptografia de dados](#Criptografia-de-dados)
   - [Tipos de dados](#Tipos-de-dados)
      - [Dados em repouso](#Dados-em-repouso)
      - [Dados em movimento](#Dados-em-movimento)
   - [Criptografia transparente de dados](#Criptografia-transparente-de-dados)
- [Arquitetura de criptografia](#Arquitetura-de-criptografia)
   - [Modelo de criptografia](#Modelo-de-criptografia)
      - [Abordagem de 1 nível](#Abordagem-de-1-nível)
      - [Abordagem de 2 níveis](#Abordagem-de-2-níveis)
   - [Gerenciamento de chaves](#Gerenciamento-de-chaves)
   - [Rotação da chave mestra](#Rotação-da-chave-mestra)
   - [Alvos de criptografia](#Alvos-de-criptografia)
      - [Criptografia de tablespace e coluna](#Criptografia-de-tablespace-e-coluna)
- [Métodos de criptografia de dados](#Métodos-de-criptografia-de-dados)
   - [Criptografia online versus offline](#Criptografia-online-versus-offline)
- [Implementações de criptografia disponíveis](#Implementações-de-criptografia-disponíveis)
   - [Opções de criptografia do MySQL](#Opções-de-criptografia-do-MySQL)
      - [MySQL InnoDB](#MySQL-InnoDB)
      - [MySQL Enterprise Edition](#MySQL-Enterprise-Edition)
   - [Opções de criptografia do PostgreSQL](#Opções-de-criptografia-do-PostgreSQL)
      - [Pgsql-hackers TDE](#Pgsql-hackers-TDE)
      - [Cybertech Postgres TDE](#Cybertech-Postgres-TDE)
      - [EnterpriseDB Postgres TDE](#EnterpriseDB-Postgres-TDE)
   - [Opções de criptografia do Oracle](#Opções-de-criptografia-do-Oracle)
      - [Oracle TDE](#Oracle-TDE)
- [Comparação de desempenho](#Comparação-de-desempenho)
- [Conclusões](#Conclusões)
   - [Apêndice](#Apêndice)


## Ameaças e abordagens de mitigação

No campo da segurança de dados, nossa pesquisa identificou três áreas principais de preocupação: o **dispositivo de armazenamento**, os **aplicativos clientes** e os **bancos de dados**. Cada uma dessas partes enfrenta várias ameaças e riscos associados. O dispositivo de armazenamento, por exemplo, pode ser roubado, o que resultaria em uma possível exposição de dados. Os aplicativos clientes podem estar em risco devido a problemas como malware, que pode infectar dispositivos e comprometer os dados, phishing, em que táticas enganosas são usadas para roubar informações confidenciais, e ransomware, um tipo de software malicioso que pode bloquear os usuários de seus próprios sistemas até que um resgate seja pago. Os bancos de dados, por sua vez, podem ser vulneráveis a problemas como exposição de backups, em que o acesso não autorizado a backups pode levar a violações de dados, roubo de credenciais, que envolve alguém que obtém credenciais de login sem permissão, injeção de SQL, um tipo de ataque cibernético que pode comprometer a segurança do banco de dados e ataques de negação de serviço (DoS) que podem interromper a disponibilidade do banco de dados. Para lidar com esses riscos, usamos métodos diferentes. A criptografia de disco protege o dispositivo de armazenamento, enquanto a proteção contra spam ajuda a combater ameaças de phishing e malware. A criptografia de rede aumenta a segurança dos aplicativos clientes, tornando a transferência de dados mais segura. A TDE (Transparent Data Encryption) e a criptografia de dados em repouso reforçam a segurança do banco de dados. O uso de backups criptografados armazenados em um storage imutável pode evitar a exposição de backups, e a filtragem de tráfego pode ajudar a reduzir os ataques de DoS. No entanto, nossa pesquisa se concentra principalmente nos bancos de dados como alvo principal, explorando os riscos e as soluções associados, com ênfase específica nos dados em repouso e na TDE (Transparent Data Encryption, criptografia transparente de dados).

![Figura 1: Ameaças e abordagens de mitigação](https://codimd.c3sl.ufpr.br/uploads/upload_e6739d46ca3c644ac28a2be6c79977b9.png)
*Figura 1: Ameaças e abordagens de mitigação*

## Criptografia de dados

### Tipos de dados

Antes de mergulhar nos detalhes da criptografia de dados, é essencial entender a natureza dos dados que pretendemos proteger. Os dados podem ser categorizados em dois tipos principais:


#### Dados em repouso

Dados em repouso referem-se a informações armazenadas em um dispositivo de armazenamento e que não estão sendo acessadas ou usadas no momento. Esse tipo de informação pode enfrentar riscos de criminosos cibernéticos e outras atividades prejudiciais que visam invadir digitalmente os dados ou roubar fisicamente os dispositivos de armazenamento que os contêm. A criptografia de dados em repouso, portanto, é uma medida de segurança que pode atenuar as ameaças em caso de roubo de dados.

#### Dados em movimento
Os dados em movimento, por outro lado, são dados que estão ativamente em movimento ou sendo enviados por uma rede. São os dados em trânsito, incluindo informações enviadas ou recebidas por vários aplicativos e serviços. A criptografia de dados em movimento garante que os dados sejam protegidos enquanto estiverem viajando de um lugar para outro, para que não possam ser vistos ou interceptados por pessoas não autorizadas. As formas comuns de criptografar dados em movimento incluem o uso de SSL/TLS para conexões seguras na Web e VPNs para comunicação segura em rede.

Embora a criptografia de dados em movimento seja certamente importante, neste relatório daremos a maior parte de nossa atenção à criptografia de dados em repouso. Ao nos concentrarmos na criptografia de dados em repouso, estamos abordando o aspecto fundamental da segurança de dados, criando uma base sólida para a proteção geral contra acesso não autorizado e possíveis violações de dados.

### Criptografia transparente de dados

O TDE é uma estrutura para criptografar dados em repouso. Ele criptografa bancos de dados no disco rígido e, consequentemente, na mídia de backup. É transparente, pois o usuário não percebe a criptografia. Os dados são armazenados criptografados e descriptografados automaticamente pelo TDE para usuários e aplicativos autorizados. Portanto, não são necessárias alterações no aplicativo. O TDE garante que os dados confidenciais sejam criptografados, atende aos requisitos de conformidade e fornece funcionalidade que simplifica as operações de criptografia.

## Arquitetura de criptografia

A estrutura da criptografia de dados desempenha um papel fundamental para garantir a segurança e a capacidade de gerenciamento dos dados. Ela envolve vários aspectos, como a forma como as chaves de criptografia são organizadas, onde são armazenadas e como a criptografia é aplicada a diferentes partes de um banco de dados.

### Modelo de criptografia

As arquiteturas de criptografia são geralmente categorizadas em dois modelos principais: a abordagem de 1 camada e a abordagem de 2 camadas.

#### Abordagem de 1 nível

Em um modelo de criptografia de 1 camada, uma única chave de criptografia é empregada para criptografar todos os dados. Essa abordagem é relativamente simples e adequada a cenários em que a simplicidade e a facilidade de gerenciamento são prioridades.

#### Abordagem de 2 níveis

A abordagem de duas camadas envolve uma clara separação de tarefas entre dois tipos de chaves de criptografia: a chave mestra de criptografia e as chaves de criptografia de dados. Nesse modelo, a chave mestra de criptografia é responsável por criptografar e descriptografar as chaves de criptografia de dados. Por outro lado, as chaves de criptografia de dados são usadas para criptografar e descriptografar os dados reais. Essa segregação aumenta significativamente a segurança. Mesmo que um invasor obtenha acesso a uma chave de criptografia de dados, como a usada para descriptografar uma tabela específica, sem acesso à chave mestra, ele não poderá descriptografar a própria chave de criptografia de dados. Como resultado, a chave de criptografia de dados se torna inútil para o invasor, impedindo o acesso aos dados.

### Gerenciamento de chaves

As chaves de criptografia devem ser armazenadas de forma segura para evitar o acesso não autorizado. O armazenamento da chave mestra pode ser gerenciado interna ou externamente, dependendo da solução de criptografia escolhida.

![Figura 2: Implementação da chave mestra](https://codimd.c3sl.ufpr.br/uploads/upload_90c272686c5bce8c190a747c0b46e2fd.png)
*Figura 2: Implementação da chave mestra*

- **Armazenamento interno de chaves:** Algumas soluções de criptografia armazenam chaves dentro do próprio sistema de banco de dados. Embora essa abordagem simplifique o gerenciamento de chaves, ela pode representar riscos de segurança se o sistema de banco de dados for comprometido.
- **Armazenamento externo de chaves:** Como alternativa, as organizações podem optar por soluções de gerenciamento de chaves externas. Essas soluções armazenam chaves fora do sistema de banco de dados, geralmente em hardware especializado ou plataformas dedicadas de gerenciamento de chaves, como Oracle Key Vault, Thales CipherTrust Manager, Fornetix VaultCore, Google Cloud Key Management Service e outros. O armazenamento externo de chaves aumenta a segurança ao isolar as chaves de possíveis violações do banco de dados.

### Rotação da chave mestra

A rotação de chaves é uma prática de segurança que envolve a alteração periódica das chaves de criptografia. Ela é particularmente relevante para as chaves mestras de criptografia no modelo de criptografia de duas camadas. A rotação regular das chaves mestras fortalece a segurança, limitando a exposição das chaves e evitando vulnerabilidades de longo prazo.

### Alvos de criptografia

A criptografia pode ser aplicada a vários componentes de um banco de dados. Os alvos comuns de criptografia incluem:

- **Cluster** : A criptografia no nível do cluster oferece segurança abrangente para todo o cluster de banco de dados, garantindo que todos os dados nele contidos estejam protegidos.


- **Banco de dados** : A criptografia no nível do banco de dados estende a segurança a todo o banco de dados, abrangendo todas as tabelas, tablespaces e dados.
- **Espaços de tabela** : A criptografia pode ser aplicada seletivamente aos tablespaces, que são contêineres de armazenamento lógico em um banco de dados.
- **Tabelas** : As organizações podem optar por criptografar tabelas específicas que contenham dados altamente confidenciais.
- **Colunas** : Para um controle mais refinado, a criptografia pode ser aplicada no nível da coluna, permitindo que colunas individuais dentro de tabelas sejam criptografadas.

#### Criptografia de tablespace e coluna

As diferenças na implementação da criptografia nos níveis de tablespace e coluna podem causar um impacto no desempenho. Abaixo, a Tabela 1 compara as duas implementações.


| Tablespace                                                                                                                                  | Coluna                                                                                         |
|:------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Criptografar todos os arquivos de dados pertencentes ao tablespace                                                                          | Criptografar colunas individuais                                                               |
| Chave do tablespace (a mesma para todos os arquivos de dados em um tablespace)                                                              | Chave da tabela (a mesma para todas as colunas em uma tabela)                                  |
| Algoritmo padrão: AES 128                                                                                                                   | Algoritmo padrão: AES 192                                                                      |
| Os dados são descriptografados à medida que são lidos dos arquivos de dados para o cache do buffer ou por meio de leitura de caminho direto | Os dados permanecem criptografados no cache do buffer                                          |
| O impacto no desempenho tende a ser consistente e não altera o plano de execução das consultas                                              | O impacto no desempenho tende a ser consistente e não altera o plano de execução das consultas |

*Tabela 1: Comparação de criptografia de tablespace e coluna*

O cache do buffer do banco de dados lida com a maioria das tarefas de consulta. Como os dados no cache do buffer já estão descriptografados com a criptografia de tablespace, geralmente não há necessidade de descriptografia adicional durante as operações de consulta. Por outro lado, com a criptografia de coluna, os dados são criptografados dentro do cache do buffer. Isso significa que cada solicitação de dados exige a descriptografia, aumentando a sobrecarga de desempenho.

## Métodos de criptografia de dados

Trabalhar com grandes quantidades de dados requer técnicas para migrar os dados de um lugar para outro. Podemos ter dois casos principais ao criptografar nossos dados:

* **Reorganização de dados em uma instância criptografada:** Ao implementar a criptografia de dados em repouso, uma abordagem comum é reorganizar os dados existentes em uma instância criptografada. Nesse caso, os dados são inicialmente armazenados sem criptografia e, em seguida, são transformados em um estado criptografado em uma instância dedicada.
    * **Dump and Restore (despejar e restaurar):** Essa abordagem envolve a exportação dos dados não criptografados de sua origem e, em seguida, sua importação para a instância criptografada de destino. Ferramentas como pg dump para PostgreSQL ou mysqldump para MySQL podem ser usadas para essa finalidade. Os dados são efetivamente convertidos em um formato criptografado durante esse processo.
    * **Replicação lógica:** Outro método é utilizar a replicação lógica, que é um recurso fornecido por alguns sistemas de gerenciamento de banco de dados, como o PostgreSQL. A replicação lógica permite replicar dados de um banco de dados de origem para um banco de dados de destino enquanto aplica transformações de criptografia conforme necessário. Isso pode ser particularmente útil para a replicação de dados em tempo real com criptografia.
* **Conversão de uma instância existente:** Quando você já tiver uma instância de banco de dados não criptografada e quiser ativar a criptografia para ela, poderá usar uma das seguintes abordagens:
    * **Conversão offline:** Esse método envolve colocar o banco de dados ou o tablespace offline e executar a operação de criptografia. Essa abordagem normalmente requer algum tempo de inatividade, pois o banco de dados precisa ser colocado offline para que a conversão ocorra.
    * **Conversão online:** Ao contrário da conversão offline, a conversão online permite que você ative a criptografia para um banco de dados ou espaço de tabela existente sem a necessidade de tempo de inatividade significativo. O processo de criptografia ocorre em segundo plano enquanto o banco de dados permanece operacional no modo de leitura e gravação. Esse método pode ser mais conveniente para ambientes em que a disponibilidade contínua é crucial.

### Criptografia online vs offline


Ao escolher entre conversão de criptografia offline ou online, é preciso considerar vários
fatores críticos.

| Offline                                                 | Online                                                                     |
|:------------------------------------------------------- | -------------------------------------------------------------------------- |
| É necessário colocar a instância offline                | Criptografa a instância em segundo plano, sem tempo de inatividade         |
| Não há necessidade de espaço de armazenamento adicional | A sobrecarga de armazenamento é igual ao tamanho do maior arquivo de dados |
| A chave mestra não pode ser girada                      | Suporte à rotação de chaves de dados em tempo real                         |
| Conversão mais rápida                                   | Conversão mais lenta                                                       |

*Tabela 2: Comparação de criptografia offline e online*

Portanto, a criptografia offline oferece uma conversão mais rápida e não requer espaço de armazenamento adicional. No entanto, ela tem o custo do tempo de inatividade, que pode interromper as operações. Por outro lado, a criptografia online, embora evite o tempo de inatividade, introduz a necessidade de armazenamento adicional e possíveis impactos no desempenho.

## Implementações de criptografia disponíveis

### Opções de criptografia do MySQL

Há duas possibilidades de uso de criptografia em bancos de dados MySQL: MySQL InnoDB e MySQL Enterprise Edition.

#### MySQL InnoDB

O MySQL InnoDB oferece uma solução gratuita e robusta de criptografia de dados em repouso. Os principais destaques dessa opção incluem:

- Suporte para criptografia de dados em repouso.
- Implementação de um modelo de criptografia de duas camadas.
- Não há sobrecarga perceptível de desempenho.
- O usuário precisa contar com um plug-in de chaveiro para o gerenciamento de chaves.
- Armazenamento de dados do chaveiro em um arquivo local no host do servidor.
- Recursos de criptografia nos níveis da tabela e do tablespace.
- Suporte para rotação de chave mestra.
- Use o algoritmo de criptografia AES-256.

#### MySQL Enterprise Edition

O MySQL Enterprise Edition é uma solução paga que oferece segurança aprimorada e recursos avançados de criptografia. Os principais aspectos dessa opção incluem:

- Implementação de um modelo de criptografia de duas camadas.
- Utiliza uma solução centralizada de gerenciamento de chaves, suportando vários cofres de chaves.
- Não há sobrecarga perceptível de desempenho.
- Oferece suporte à criptografia de dados em repouso nos níveis da tabela e do tablespace.
- Oferece rotação da chave mestra.
- Utiliza o algoritmo de criptografia AES-256.

### Opções de criptografia do PostgreSQL

Para o PostgreSQL, as opções disponíveis são o pgsql-hackers TDE, o Cybertec PostgreSQL TDE e o EnterpriseDB PostgreSQL TDE.

#### Pgsql-hackers TDE
A comunidade PostgreSQL, muitas vezes chamada de pgsql-hackers, desenvolveu dois patches de soluções TDE, sendo o último lançado em 2019. Essa opção é uma solução gratuita e de código aberto com vários recursos notáveis:

- Suporte a vários comprimentos de chave de criptografia AES, incluindo 128 bits, 192 bits e 256 bits.
- Oferece opções de arquitetura de chave única e de duas camadas para criptografia.
- Oferece o recurso de criptografia nos níveis de cluster, tablespace e tabela.
- Suporta rotação de teclas.
- Emprega um sistema interno de gerenciamento de chaves que armazena chaves de criptografia no banco de dados.
- Permite a comunicação com sistemas externos de gerenciamento de chaves para aumentar ainda mais a segurança das chaves.

#### Cybertech Postgres TDE

A Cybertech oferece uma solução PostgreSQL TDE, que está disponível como uma ferramenta paga, embora versões mais antigas possam estar disponíveis gratuitamente.

Alguns dos principais aspectos dessa ferramenta incluem:

- Fornece criptografia em nível de cluster para proteger todo o seu cluster PostgreSQL.
- Utiliza o algoritmo de criptografia AES-128 para proteção de dados.
- Adota uma arquitetura de chave única para criptografia.
- Não impõe nenhuma sobrecarga de desempenho perceptível.
- Os usuários precisam implementar um armazenamento de chaves criptografadas e gerenciar a rotação da chave mestra.

#### EnterpriseDB Postgres TDE

A EnterpriseDB também oferece uma ferramenta paga para o PostgreSQL TDE. Os principais recursos dessa solução incluem:

- Emprega um modelo de criptografia de duas camadas.
- Oferece criptografia no nível do banco de dados.
- Fornece suporte para soluções de gerenciamento de chaves externas, suportando vários cofres de chaves.
- Não impõe nenhuma sobrecarga significativa de desempenho.
- Utiliza o algoritmo de criptografia AES-128.
- Suporta rotação de teclas.

### Opções de criptografia do Oracle

A Oracle oferece a ferramenta integrada Oracle TDE.

#### Oracle TDE

- O Oracle TDE é uma solução paga.
- Ele emprega um modelo de criptografia de duas camadas.
- A implementação do Oracle TDE não apresenta nenhuma sobrecarga de desempenho perceptível.
- Ele oferece recursos de criptografia nos níveis de tablespace e coluna.
- Oferece suporte à rotação de chaves mestras.

- Opções externas de gerenciamento de chaves, incluindo apenas produtos Oracle, como o Oracle Key Vault.
- Oferece suporte a vários algoritmos de criptografia, como AES-128, AES-192 e AES-256.
- O Oracle TDE oferece uma escolha entre opções de criptografia online e offline.
- Oferece recursos como caminho direto e paralelismo para carregamento eficiente de dados.

## Comparação de desempenho

Uma tabela de 21 GB foi usada para testar a criptografia no MySQL InnoDB, Cybertech, PostgreSQL e Oracle TDE. A tabela foi carregada em instâncias criptografadas e o tempo para a criptografia  foi medido e é mostrado abaixo.

- **MySQL** : Demorou 1 hora e 19 minutos, velocidade de 4,4 MB/s.
- **PostgreSQL** : Demorou 1,5 horas, velocidade de 4 MB/s.
- **Oracle** : Demorou 1 hora e 21 minutos, com velocidade de 4,2 MB/s.

Usando as opções de caminho direto e paralelo para carregar dados no Oracle, o tempo diminui consideravelmente. A mesma tabela levou 13 minutos para ser carregada, uma velocidade de aproximadamente 27 MB/s.

## Conclusões

No escopo da criptografia de banco de dados, exploramos as ofertas de três sistemas de gerenciamento de banco de dados: MySQL, PostgreSQL e Oracle.

**O MySQL** apresenta duas opções de chave. O MySQL InnoDB, uma solução gratuita, depende de plug-ins de chaveiro para o gerenciamento de chaves. A MySQL Enterprise Edition, uma ferramenta paga mais robusta, oferece segurança aprimorada por meio de soluções de gerenciamento de chaves centralizadas que suportam vários cofres de chaves.

**O PostgreSQL** não oferece TDE embutido como o MySQL e o Oracle. Em vez disso, os usuários podem usar vários plug-ins e soluções, como o pgsql-hackers TDE, o que pode gerar trabalho adicional, pois o usuário é responsável pela manutenção. O Cybertech TDE e o EnterpriseDB TDE são opções pagas que oferecem gerenciamento de chaves externas, suportando vários cofres de chaves e mais confiabilidade a longo prazo.

**A Oracle**, uma solução paga, fornece recursos robustos com TDE. Ela oferece gerenciamento centralizado de chaves, mas suporta apenas produtos Oracle para armazenamento de chaves. O Oracle TDE também oferece métodos de criptografia online e offline, além de recursos como caminho direto e carregamento paralelo. Por outro lado, geralmente é mais caro.

Conseguimos observar pequenas diferenças de desempenho com o teste de carregamento simples, entre as três opções, em nossa configuração, que depende muito da virtualização. Maior confiabilidade e segurança exigem soluções pagas para todos os três DBMS. Cada opção tem seus pontos fortes e pode ser adaptada para atender às demandas de segurança.

## Apêndice

Neste Apêndice, especificamos a configuração relevante aplicada para definir a criptografia no MySQL, PostgreSQL e Oracle e os detalhes usados em nossos experimentos.

### Configuração do sistema

#### MySQL InnoDB

```
Arquitetura: x 86 _ 64
CPU(s): 16
Sistema operacional: Red Hat Enterprise Linux versão 8.8 (Ootpa)
Nome do modelo: Processador Intel Core (Broadwell, IBRS)
Modelo do BIOSnome: RHEL-8.6.0PC (Q35 + ICH9, 2009)
RAM: 30 GB
```

#### Cybertech PostgreSQL

```
Arquitetura: x 86 _ 64
CPU(s): 4
Sistema operacional: Red Hat Enterprise Linux versão 8.8 (Ootpa)
Nome do modelo: Processador Intel Xeon (Skylake, IBRS)
Modelo do BIOSnome: RHEL-8.6.0PC (Q35 + ICH9, 2009)
RAM: 7,3 GB
```
#### Oracle

```
Arquitetura: x 86 _ 64
CPU(s): 48
Sistema operacional: Red Hat Enterprise Linux Server 7.9 (Maipo)
Nome do modelo: Intel(R) Xeon(R) CPU E5-2650 v4 @ 2.20GHz
RAM: 528 GB
```
### Arquivo CSV

O arquivo _csv_ contém 4 campos, separados por vírgulas. Um exemplo de uma linha do arquivo está abaixo:

```
created updated id json version_id
2018-08-16 17:34:44.65323, 2023-03-04 17:49:02.059818, 6550 f 68 a- 9 e 89 - 44f5-a
c31-a776e9f268f8, "{"url": "", "code": "1F31NS043897-01", "title": "Estorgen Effect
s on Place Cells and Navigation Strategy", "funder":{"$ref": "http://dx.doi.org/10.
13039/100000002"}, "$schema": "HTTP://zenodo.org/schemas/grants/grant-v1.0.0.json", 
"acronym": "","enddate":"", "program": NATIONAL_INSTITUTE_OF_NEUROLOGICAL_DISORDERS
_AND_STROKE", "startdate": "2002-06-20", "identifiers": {"oaf": "nih ::f 80 a d5bab
6c366b291f2baadca524691", "purl": nulo, "eurepo": "info:eurepo/grantAgreemen/NIH/NA
TIONAL_INSTITUTE_OF_NEUROLOGICAL_DISORDERS_AND_STROKE/1F31NS043897-01/"}, "internal
_id": " 10. 13039 /100000002 :: 1 F 31 NS 043897-01", "remote_modified": "2021-04-2
7"}", 2
```


### Descrição da tabela

#### MySQL InnoDB



| Field      | Type       | Null | Key | Default | Extra |
| ---------- | ---------- | ---- | --- |:------- | ----- |
| created    | timestamp  | YES  |     | NULL    |       |
| updated    | timestamp  | YES  |     | NULL    |       |
| id         | binary(16) | YES  |     | NULL    |       |
| json_data  | json       | YES  |     | NULL    |       |
| version_id | int        | YES  |     | NULL    |       |


#### Cybertec PostgreSQL

| Column     | Type                        | Nullable | Storage  |
| ---------- | --------------------------- | -------- |:-------- |
| created    | timestamp without time zone | NOT NULL | plain    |
| updated    | timestamp without time zone | NOT NULL | plain    |
| id         | uuid                        | NOT NULL | plain    |
| json_data  | jsonb                       |          | extended |
| version_id | integer                     | NOT NULL | plain    |


#### Oracle

| Name       | Null?    | Type         |
| ---------- | -------- |:------------ |
| created    | NOT NULL | TIMESTAMP(6) |
| updated    | NOT NULL | TIMESTAMP(6) |
| id         | NOT NULL | VARCHAR(36)  |
| json_data  | NOT NULL | CLOB         |
| version_id | NOT NULL | NUMBER(38)   |

### Comandos de carga

Abaixo, os comandos para carregar a tabela em cada tecnologia.

#### MySQL InnoDB


```
LOAD DATA LOCAL INFILE ’/path/to/records_metadata.csv’
INTO TABLE records_metadata
FIELDS TERMINATED BY ’,’
OPTIONALLY ENCLOSED BY ’"’
ESCAPED BY ’"’
LINES TERMINATED BY ’\n’
IGNORE 1 LINES
(created, updated, id, @json_data, version_id)
SET json_data = NULLIF(@json_data, ’’);
```
#### Cybertec PostgreSQL

```
\copy records_metadata(created, updated, id, json, version_id) from
’/path/to/records_metadata.csv’ delimiter ’,’ csv header;
```
#### Oracle

```
$ cat records_metadata.ctl
OPTIONS (SKIP=1, readsize=200000000, bindsize=200000000, DIRECT=true,
PARALLEL=true)
LOAD DATA
INFILE ’records_metadata.csv’ -- Path to your CSV file
APPEND INTO TABLE records_metadata -- Target table name
FIELDS TERMINATED BY ’,’ -- Field delimiter in the CSV
TRAILING NULLCOLS
(
created TIMESTAMP "YYYY-MM-DD HH24:MI:SS.FF6",
updated TIMESTAMP "YYYY-MM-DD HH24:MI:SS.FF6",
id,
json_data CHAR(4196000) OPTIONALLY ENCLOSED BY ’"’ AND ’"’ NULLIF js
on_data=’’,
version_id
)
\$ sqlldr userid=\’/ as sysdba\’ control=/ORA/dbs01/oracle/home/record
s_metadata.ctl
```


## Referências

1. Advanced Security Guide — docs.oracle.com. <https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/introduction-to-transparent-data-encryption>. [Accessed 04-10-2023].
2. Advanced Security Guide — docs.oracle.com. <https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/introduction-to-transparent-data-encryption.html#GUID-B0870B12-E6AD-4254-B4B3-D6A15A637975>. [Accessed 04-10-2023].
3. Chapter 31. Logical Replication — postgresql.org. <https://www.postgresql.org/docs/current/logical-replication.html>. [Accessed 04-10-2023].
4. Data at rest - Wikipedia — en.wikipedia.org. <https://en.wikipedia.or/wiki/Data_at_rest>. [Accessed 04-10-2023].
5. Data Protection: Data In transit vs. Data At Rest — digitalguardian.com. <https://www.digitalguardian.com/blog/data-protection-data-in-transit-vs-data-at-rest#:~:text=Data%20at%20rest%20is%20safely,while%20it%20is%20being%20transmitted>. [Accessed 04-10-2023].
6. Locked Up: Advances in Postgres Data Encryption - Vibhor Kumar — youtube.com. <https://www.youtube.com/watch?v=X5Vfi6qqyHk>. [Accessed 04-10-2023].
7. MySQL :: MySQL 8.0 Reference Manual :: 15.13 InnoDB Data-at-Rest Encryption — dev.mysql.com. <https://dev.mysql.com/doc/refman/8.0/en/innodb-data-encryption.html>. [Accessed 04-10-2023].
8. MySQL :: MySQL Enterprise Transparent Data Encryption (TDE) — mysql.com. <https://www.mysql.com/products/enterprise/tde.html>. [Accessed 04-10-2023].
9. Transparent Data Encryption — enterprisedb.com. <https://www.enterprisedb.com/docs/tde/latest/>. [Accessed 04-10-2023].
10. Transparent Data Encryption - PostgreSQL wiki — wiki.postgresql.org. <https://wiki.postgresql.org/wiki/Transparent_Data_Encryption>. [Accessed 04-10-2023].
11. Transparent data encryption - Wikipedia — en.wikipedia.org. <https://en.wikipedia.org/wiki/Transparent_data_encryption>. [Accessed 04-10-2023].
12. Transparent Data Encryption for PostgreSQL — CYBERTEC — cybertec-postgresql.com. <https://www.cybertec-postgresql.com/en/products/postgresql-transparent-data-encryption/>. [Accessed 04-10-2023].
13. What is Data at Rest? — techtarget.com. <https://www.techtarget.com/searchstorage/definition/data-atrest#:~:text=Data%20at%20rest%20is%20data,to%20be%20read%20or%20updated>. [Accessed 04-10-2023].
14. What is TDE? — docs.delphix.com. <https://docs.delphix.com/docs609/datasets/oracle-environments-and-data-sources/what-is-tde>. [Accessed 04-10-2023].
15. Anirban Ghoshal. EnterpriseDB adds Transparent Data Encryption to PostgreSQL — infoworld.com. <https://www.infoworld.com/article/3687813/enterprisedb-adds-transparent-data-encryption-to-postgresql.html>. [Accessed 04-10-2023].
16. Masahiko Sawada. Re: [Proposal] Table-level Transparent Data Encryption (TDE) and Key Management Service (KMS) — postgresql.org. <https://www.postgresql.org/messageidCAD21AoBjrbxvaMpTApX1cEsO%3D8N%3Dnc2xVZPB0d9e-VjJ%3DYaRnw%40mail.gmail.com>. [Accessed 04-10-2023].
