# L2ARC para NVME

## Objetivo
Documentar processo de criação da configuração do L2ARC para cacheamento de NVME sobre RAID6 (Raidz2) de discos.

## Links
[1] C3root: https://root.docs.c3sl.ufpr.br/pt/latest/pages/concepts/zfs.html  
[2] ZFS storage pool: https://ubuntu.com/tutorials/setup-zfs-storage-pool#1-overview  
[3] L2ARC setup: https://linuxhint.com/configuring-zfs-cache/  

## Dependências
[1] PostgresSQL, 16.2-0, Sistema de Gerênciamento de Banco de Dados  
[2] zfs (zpool), 2.2.3-1, Utilitários do ZFS para criar pools de discos  

## Instalação
### Debian/Ubuntu
Em sistemas com apt
```bash
sudo apt install zfsutils-linux
```

### Arch
ZFS por problemas de licença não está disponivel no repositório oficial do arch, entretanto é possivel instalar com AUR
```bash
yay -S zfs-linux zfs-utils
```

## Gerenciamento
Verificar status e historico de alterações das pools
```bash
zpool status
zpool history
```

## Criação
Antes de criar uma nova pool é necessário verificar a WWN (World Wide Number) pois ela será utilizada pelo zpool para identificar os discos.  
Crie uma pool de Raidz2 com pelo menos 6 discos concatenando os numeros com a string "wwn-".  
Caso aconteçam erros como a ja existência de um filesystem nos discos, utilize a opção -f para sobreescrever os dados.  
```bash
# Check WWN
lsblk -o NAME,TYPE,SIZE,WWN
lsblk -o NAME,TYPE,SIZE,WWN | grep disk
# Create pool "tank"
zpool create tank raidz2 -f wwn-0x500a5008abcdef8 wwn-0x500b5008abcdef8 ...
```

Em seguida adicione as partições do NVME para o cacheamento de escritas e leituras. 
`nvme-eui.3535......0003` especifíca o nvme e `-part1` a partição (partição 1).   
```bash
zpool add tank log /dev/disk/nvme-eui.3535.......0003-part1
zpool add tank cache /dev/disk/nvme-eui.3535.......0003-part2
```

Com a pool `tank` criada, por default será criado um ponto de montagem na raiz `/tank`.  
Caso queria que outros diretórios utilizem a pool é possivel adicionar novos pontos de montagem.  
Por exemplo que o diretório `postgres` na `/home` utilize a pool.
```bash
zfs create -o recordsize=8k -o compression=off -o mountpoint=/home/postgres tank/postgres
```

## Parametros do zpool
É possivel configurar parametros para as pools, utilizando `get` e `set`.
```bash
zfs set quota=2T tank/postgres
zfs get compression tank
```


## Removendo discos\Destruindo pool
Caso queira remover os discos de uma pool utilize `remove`.  
Caso queira remover toda uma pool e liberar os discos utilize `destroy`
```bash
# Remove disk
zpool remove tank wwn-0x500a5008abcdef8
# Remove pool
zpool destroy tank
```



