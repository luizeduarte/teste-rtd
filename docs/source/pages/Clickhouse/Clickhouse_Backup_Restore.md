# Clickhouse Backup e Restore  
Tutorial para efetuar Backup e Restore do Clickhouse

## Links
[1] <https://clickhouse.com/docs/en/operations/backup>

## Dependências
[1] Clickhouse, v24.1.5.6-stable, Sistema de Gerênciamento de Banco de Dados colunar (TESTADO NA VERSÃO 24,VERSÕES ANTERIORES PODEM NÃO FUNCIONAR)

##  Configuração
Crie um arquivo chamado /etc/clickhouse-server/config.d/backup_disk.xml com as seguintes informações:
```bash
    <clickhouse>
    <storage_configuration>
        <disks>
            <backups>
                <type>local</type>
                <path>/home/clickhouse/backups/</path>
            </backups>
        </disks>
    </storage_configuration>
    <backups>
        <allowed_disk>backups</allowed_disk>
        <allowed_path>/home/clickhouse/backups/</allowed_path>
    </backups>
</clickhouse>
<clickhouse>
    <storage_configuration>
        <disks>
            <backups>
                <type>local</type>
                <path>/home/clickhouse/backups/</path>
            </backups>
        </disks>
    </storage_configuration>
    <backups>
        <allowed_disk>backups</allowed_disk>
        <allowed_path>/home/clickhouse/backups/</allowed_path>
    </backups>
    </clickhouse>
```

##  Exemplos de uso
Estes são exemplos básicos de uso, para exemplos mais complexos favor consultar a documentação citada na seção Links
1.  Backup Database:
```bash
    BACKUP DATABASE dbName TO Disk('backups', 'filename.zip') SETTINGS compression_method='lzma'
```
2.  Restore Database:
```bash
    RESTORE DATABASE dbName from Disk('backups', 'filename.zip')
```
3. Restore Database com novo nome
```bash
    RESTORE DATABASE dbName as newdbName. from Disk('backups', 'filename.zip')
```
4.  Backup Table:
```bash
    BACKUP TABLE dbName.tableName TO Disk('backups', 'filename.zip') SETTINGS compression_method='lzma'
```
5.  Restore Table:
```bash
    RESTORE Table dbName.tableName from Disk('backups', 'filename.zip')
```
6. Restore Table com novo nome
```bash
    RESTORE Table dbName as dbName.newTableName from Disk('backups', 'filename.zip')
```
##  DETALHES IMPORTANTES
1.  Quando foram efetuados testes com um restore de um banco maior(10 GB), houve uma situação adversa em relação a timeout ao ser executado o Backup da Database: Independente do timeout definido, o clickhouse retornou a seguinte mensagem 
``` bash 
    Timeout exceeded while receiving data from server. Waited for 10 seconds, timeout is 10 seconds.
    Cancelling query.
```
Este cancelamento de query levou uma hora para ser finalizado ,logo nos próximos testes foi-se pressionado Ctrl+C para não precissar esperar todo este tempo. No entanto, foi notado que o arquivo zip do backup continuava aumentando de tamanho como se o backup ainda estivesse vivo e após decorrido o tempo do backup, o arquivo .lock (que impede que qualquer outro processo interfira com o arquivo zip no meio do backup) sumiu e o tamanho parou de aumentar. O restore foi testado e foi obtido sucesso.

Ao permitir que o cancelamento de query fosse até o fim de maneira natural também houve sucesso no Backup e no Restore.

**CONCLUSÃO**: Até o momento da escrita deste relatório e pelos testes efetuados e resultados obtidos, o Timeout pareceu ser irrelevante para o Backup e pode ser tratado da maneira que o usuário preferir.



2.  Como alterar o timeout (há outras maneiras mais permanentes porém não foram testadas):
```bash
    clickhouse-client --receive-timeout=(tempo em segundos) --send_timeout=(tempo em segundos)
```
Para conferir o timeout atual rode dentro do clickhouse:
```bash
    select * from system.settings where name in ('send_timeout','receive_timeout')
``` 

3.  Caso haja erro de experimental_object_type, rodar set allow_experimental_object_type = 1 no clickhouse que o problema se resolve
