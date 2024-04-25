# Apache NiFi

O Apache NiFi é uma plataforma que permite a automação do fluxo de dados entre sistemas de software.

A ideia principal por trás do Apache NiFi é simplificar o fluxo de dados entre diferentes fontes e destinos. Isso é feito através de uma interface de usuário baseada em navegador que permite “arrastar e soltar” componentes de processamento de dados em uma tela de design [[1]](https://blog.dsacademy.com.br/automacao-do-fluxo-de-dados-com-apache-nifi/).

## Links
[1] Descrição: https://blog.dsacademy.com.br/automacao-do-fluxo-de-dados-com-apache-nifi/  
[2] Instalação: https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html  
[3] Repositório: https://nifi.apache.org/download/  
[4] Documentação: https://nifi.apache.org/documentation/v1/  
[5] Tutorial de instalação: https://www.youtube.com/watch?v=dYFOluBIMMs  
[6] Instalação do Docker NiFi: https://github.com/noharm-ai/nifi-docker  
[7] Tutorial de uso: https://nifi.apache.org/docs/nifi-docs/html/getting-started.html  
[8] Tutorial para fazer merge de dois arquivos csv: https://medium.com/@surajnagendra/merge-csv-files-apache-nifi-21ba44e1b719  

## Dependências
[1] Apache Nifi 1.25.0  
[2] Java 21.0.2

## Requisitos
- Java > versão 8 ou 11
```
java --version
sudo apt install default-jdk
```

- Encontre o caminho de instalação do Java. Por default: `/usr/lib/jvm/java-11-openjdk-amd64`
```
export JAVA_HOME=/path/to/your/java/installation
echo 'export JAVA_HOME=/path/to/your/java/installation' >> ~/.bashrc
source ~/.bashrc
echo $JAVA_HOME
```

## Instalação
Há duas possibilidades de se instalar o Apache NiFi:
1. [Diretamente na máquina local](#instalação-local)
2. [Utilizando docker](#instalação-com-docker)

#### Instalação local
- Mova-o para o diretório de instalação que desejar e extraia o arquivo comprimido
```
mv nifi-1.25.0-bin.zip /usr/local/bin
cd /usr/local/bin
unzip nifi-1.25.0-bin.zip
rm nifi-1.25.0-bin.zip
sudo ./bin/nifi.sh set-single-user-credentials <usuario> <senha>
```

- Abra https://localhost:8443/nifi/ no navegador
- Faça login

_É possível configurar a porta em que o Apache NiFi é executado no arquivo `conf/nifi.properties`_


#### Instalação com docker
- Instale a última versão do Apache Nifi Docker
```
docker pull apache/nifi:1.25.0
```

- Execute o serviço. Você pode configurar as portas como desejar
```
docker run --name nifi -e NIFI_WEB_HTTP_PORT='8443' -p 8443:8443 -d apache/nifi:1.25.0 --restart=always
```

- É possível habilitar a autenticação, como abaixo
```
docker run --name nifi -e NIFI_WEB_HTTPS_PORT='8443' -p 8443:8443 -d -e SINGLE_USER_CREDENTIALS_USERNAME=nifi_user -e SINGLE_USER_CREDENTIALS_PASSWORD=nifi_pass apache/nifi:1.25.0 --restart=always
```

- Abra a URL https://localhost:8443/nifi no navegador (_*pode demorar uns minutinhos para subir*_).
