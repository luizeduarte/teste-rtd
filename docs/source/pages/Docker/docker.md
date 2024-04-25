# Docker

## Objetivo
Documentar método de instalação, além de tutorial de uso.

## Links
[1] Instalação e tutorial: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-pt#passo-4-trabalhando-com-imagens-do-docker  
[2] Mudar diretório: https://www.ibm.com/docs/en/z-logdata-analytics/5.1.0?topic=software-relocating-docker-root-directory  

## Dependências
[1] Docker, 25.0.3

## Instalação

- Primeiro, instale alguns pacotes necessários
```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

- Em seguida, adicione a chave GPG do repositório oficial do Docker ao seu sistema
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
- Adicione o repositório do Docker
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```
- Por fim, instale o Docker
```bash
sudo apt install docker-ce
```
- Opcionalmente, é possível adicionar o seu usuário ao grupo do Docker, para que não seja necessário digitar sudo no início de todos os comandos do Docker
```bash
sudo usermod -aG docker ${USER}
su - ${USER}
sudo usermod -aG docker username
```

## Mudança de diretório raiz
Para mudar o diretório raiz seguir os seguintes passos:\\
1.  Pare os processos:
```bash
sudo systemctl stop docker
sudo systemctl stop docker.socket
sudo systemctl stop containerd
```
2.  Transfira o diretório do Docker:
```bash
rsync -a -H /var/lib/docker /home
```
3.  Edite o arquivo de configuração do Docker:
```bash
sudo vim /etc/docker/daemon.json
Adicionando:
{
  "data-root": "/home/docker"
}
```
4. Reinicie os processos:
```bash
sudo systemctl start docker
```
5.  Confira se deu certo (irá retornar o diretório raiz atual do Docker):
```bash
docker info -f '{{ .DockerRootDir}}'
```

## Criando Containers
Para criar um container a uma aplicação primeiro importe a imagem da aplicação caso não exista.  
Todas as imagens disponíveis em docker podem ser vistas em [Docker HUB](https://hub.docker.com/)
```bash
# List docker images
docker image ls
# Import docker image
docker pull <aplication>
# Example
docker pull postgres
```

Em seguida, para criar e logo em seguida executar um novo container execute:
```bash
# Create and run container
docker run --name <container_name> <parameters> <docker_image>
# Example
docker run --name pg_container1 -e POSTGRES_PASSWORD=mysecretpassword -d postgres
# Check running containers
docker ps
```

Finalmente, conecte ao docker
```bash
# Connect to the docker system as root
docker exec --user=root -it <container_name> /bin/bash
```

Para parar/destruir o container execute:
```bash
docker stop <container_name>
docker rm <container_name>
```

## Importar/Exportar arquivos
Para importar ou exportar arquivos em um container funcionando use o comando `docker cp`
```bash
# Importanto
docker cp local_file.txt <container_name>:/path
# Exportando
docker cp <container_name>:/path/to/file.txt /path/local
```


