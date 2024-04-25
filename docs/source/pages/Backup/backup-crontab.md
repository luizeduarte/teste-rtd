# Create backup procedure

Para criar um sistema basico de backup é necessario um script bash de backup e crontab.

O arquivo bash deverá executar um procedimento de dump com compactação e salva-lo em um diretorio.

Para o crontab, adicione a seguinte linha para executar todo sábado o script em /root/backup.

```
0 0 * * 6 /root/backup.sh
```
