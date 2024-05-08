# Sistema de Monitoramento de SGDB's

- [Prometheus-Grafana](#prometheus-grafana)
- [Alertas](#alertas-grafana-discord)
- [Dashboards](#dashboards-grafana)

## Objetivo
Criar um painel (dashboard) que apresente as métricas de vários servidores Postgresql, Clickhouse e que envie notificações de alerta para o discord ou telegram.

## Links
[1] Prometheus: <https://schh.medium.com/monitoring-postgresql-databases-using-postgres-exporter-along-with-prometheus-and-grafana-1d68209ca687> \
[2] Prometheus: <https://www.ashnik.com/monitoring-postgresql-with-prometheus-and-grafana/> \
[3] Postgres Dashboard: <https://grafana.com/grafana/dashboards/9628-postgresql-database/> \
[4] Clickhouse Dashboard: <https://grafana.com/grafana/dashboards/14192-clickhouse/> \
[5] Grafana alert template: <https://faun.pub/overview-of-grafana-alerting-and-message-templating-for-slack-6bb740ec44af>

## Dependências
[1] postgres_exporter, 0.15.0, conectar e selecionar as metricas a serem exportadas do cluster postgres. \
[2] promehteus, 2.48.1, receber dados de multiplas fontes como postgres_exporter e armazená-las em timeseries. \
[3] grafana, 10.2.3, receber dados do prometheus e criar dashboards de visualização e criação de alarmes.

## Casos de reporte
- Alto uso de CPU
- Alto uso de memória
- Alto tempo de consulta
- Alto uso de arquivos abertos
- Número de conexões

## Prometheus - Grafana

#### Info geral
- Use wget para fazer o download do github
- Descompacte
- Crie o arquivo de configuração
- Crie o arquivo service
- Inicie o server com systemctl

#### postgres_exporter

```bash
# Download binaries
cd /opt
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.15.0/postgres_exporter-0.15.0.linux-amd64.tar.gz
tar -xzf postgres_exporter-0.15.0.linux-amd64.tar.gz
mv postgres_exporter-0.15.0.linux-amd64/ postgres_exporter
# Change permissions
chown -R postgres:postgres postgres_exporter
cd postgres_exporter/
# Copy binaries
cp postgres_exporter /usr/local/bin
chown postgres:postgres /usr/local/bin/postgres_exporter
```

Crie o arquivo /opt/postgres_exporter/postgres_exporter.env para configurar o acesso ao banco (localhost no exemplo abaixo).

```env
DATA_SOURCE_NAME="postgresql://postgres:postgres@localhost:5432/?sslmode=disable"
```

Crie o arquivo /etc/systemd/system/postgres_exporter.service para o serviço.

```service
[Unit]
Description=Prometheus exporter for Postgresql
Wants=network-online.target
After=network-online.target
[Service]
User=postgres
Group=postgres
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter
Restart=always
[Install]
WantedBy=multi-user.target
```

Finalmente inicie o serviço:
```bash
systemctl daemon-reload
systemctl start postgres_exporter
```

#### Adicionar metricas postgres_exporter
Para adicionar mais metricas ao conjunto que é disponibilizado por padrão ao postgres_exporter, basta adicionar a flag da métrica que se deseja adicionar da lista em [Flags](https://github.com/prometheus-community/postgres_exporter?tab=readme-ov-file#flags) a variável `ExecStart` arquivo service do postgres_exporter.

Exemplo com postmaster:

```service
[Unit]
Description=Prometheus exporter for Postgresql
Wants=network-online.target
After=network-online.target
[Service]
User=postgres
Group=postgres
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter --collector.postmaster
Restart=always
[Install]
WantedBy=multi-user.target
```


#### prometheus
```bash
# Create prometheus user
useradd –-no-create-home –-shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus
# Download source
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
tar -xzf prometheus-2.48.1.linux-amd64.tar.gz
mv prometheus-2.48.1.linux-amd64 prometheus
cd prometheus
# Copy binaries
cp prometheus promtool /usr/local/bin
# Change permissions
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
```

Crie o arquivo /opt/prometheus/prometheus.yml
```yaml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "postgres_exporter"

    static_configs:
      - targets: ["localhost:9187"]
```

Crie o arquivo /etc/systemd/system/prometheus.service

```service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file /opt/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

Inicie o serviço

```bash
systemctl daemon-reload
systemctl start prometheus
```

#### Clickhouse
Para adicionar o clickhouse ao coletor de metricas do prometheus primeiro deve-se configurar o exportador de metricas do clickhouse. \
Acesse o arquivo de configuração `config.xml` e descomente a tag prometheus com a porta especificada e reinicie o serviço.

```xml
    <prometheus>
        <endpoint>/metrics</endpoint>
        <port>9363</port>

        <metrics>true</metrics>
        <events>true</events>
        <asynchronous_metrics>true</asynchronous_metrics>
    </prometheus>
```

Em seguida adicione as `scrape_configs` do prometheus o `job_name` conforme o host e a porta.

```conf
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "dbteam_pg_exporter"
    static_configs:
      - targets: ["dbteamvenv:9187"]

  - job_name: "hydra_pg_exporter"
    static_configs:
      - targets: ["hydrapostgres:9187"]

  - job_name: "dbteam_clickhouse"
    static_configs:
      - targets: ["localhost:9363"]

```

Finalmente reinicie o serviço do prometheus.

## Alertas - Grafana Discord
É possível configurar o grafana para enviar alertas a um canal no discord.

#### Contact points
Primeiro é necessario adicionar o discord como um dos pontos de notificação.

Acessando a aba `Alerting->Contact points` clique em `Add contact point`.

De um nome, selecione Discord como integração, adicione a URL do Webhook do canal de destino do Discord e clique em `Teste`.

Se uma notificação de teste for enviada ao Discord, clique em salvar.

#### Notification policies
Politicas de notificação determinam como os alertas interagem com contact points.

#### Alert rules
Para criar alertas acesse `Alerting->Alert Rules` e clique em `create alert rules`.

Coloque um nome no alerta, selecione o Data source (prometheus para este caso).

Perceba que a confuguração é baseada em blocos de entrada e saída, inicialmente há 3 blocos de nome `A`, `B` e `C` das quais é possível renomear.

Para o bloco A selecione a métrica a ser testada como `pg_up` para determinar se um banco postgres está rodando e selecione os filter labels de acordo.

Para o bloco B selecione uma função com base na métrica de saída do bloco A. Um exemplo é `Last` que representa o último valor lido.

Para o bloco C selecione o gatilho o alerta, ou seja, se o valor de saída de B for maior ou menor que alguma condição.

Configure o folder e o intervalo de tempo dos testes. Adicione também em `Description` e `Summary` informações adicionais que vão ser enviadas como parte da notificação do alerta e clique em salvar.

#### Templates

Para alterar o template padrão de notificação do grafana, acesse `Contact points` e clique em `Add template`. Adicione um nome e preencha o campo `Content` com o seguinte template:

```go
{{ define "alert_severity_prefix_emoji" -}}
	{{- if ne .Status "firing" -}}
		:white_check_mark:
	{{- else if eq .CommonLabels.severity "critical" -}}
		:red_circle:
	{{- else if eq .CommonLabels.severity "warning" -}}
		:warning:
	{{- end -}}
{{- end -}}


{{ define "slack.title" -}}
	{{ template "alert_severity_prefix_emoji" . }} 
	[{{- .Status | toUpper -}}{{- if eq .Status "firing" }} x {{ .Alerts.Firing | len -}}{{- end }}  | {{ .CommonLabels.env | toUpper -}} ] ||  {{ .CommonLabels.alertname -}}
{{- end -}}

{{- define "slack.text" -}}
{{- range .Alerts -}}
{{ if gt (len .Annotations) 0 }}
*Summary*: {{ .Annotations.summary}}
*Description*: {{ .Annotations.description }}
Labels: 
{{ range .Labels.SortedPairs }}{{ if or (eq .Name "env") (eq .Name "instance") }}• {{ .Name }}: `{{ .Value }}`
{{ end }}{{ end }}
{{ end }}
{{ end }}
{{ end }}
```

Por fim, os templates são configurados aos contact points, portanto edite o contact point do discord e no campo `Optional Discord settings` adicione em Title `{{ template "slack.title" . }}` e para Message content adicione `{{ template "slack.text" . }}`

## Dashboards - Grafana
Para criar dashboards e visualizar dados:

- Em `Data source` adicione a fonte dos dados
- Em `Dashboards` adicione dentro de um folder `new -> new dashboard` para criar um novo dashboard ou `new -> import` para importar um template pronto.
- Para importar, adicione a ID da biblioteca de templates do grafana (ou o JSON correspondente), os sources necessários e clique em load. Finalmente salve o dashboard.
