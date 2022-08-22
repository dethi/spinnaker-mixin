local hrm = import './http-request-metrics.jsonnet';
local jvm = import './jvm-metrics.jsonnet';
local kpm = import './kubernetes-pod-metrics.jsonnet';
local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.dashboard.new(
  'Rosco',
  editable=true,
  refresh='1m',
  time_from='now-1h',
  tags=['spinnaker'],
  uid='spinnaker-rosco',
)

// Links

.addLinks(
  [
    grafana.link.dashboards(
      icon='info',
      tags=[],
      title='GitHub',
      type='link',
      url='https://github.com/spinnaker/rosco',
    ),
  ]
)

// Templates

.addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    '',
  )
)
.addTemplate(
  grafana.template.custom(
    name='spinSvc',
    query='rosco',
    current='rosco',
    hide=2,
  )
)
.addTemplate(
  grafana.template.new(
    name='Component',
    datasource='$datasource',
    query='label_values(up{app_kubernetes_io_name=~".*$spinSvc.*"}, app_kubernetes_io_name)',
    current='All',
    refresh=1,
    includeAll=true,
  )
)
.addTemplate(
  grafana.template.new(
    name='Instance',
    datasource='$datasource',
    query='label_values(up{app_kubernetes_io_name=~"$Component"}, kubernetes_pod_name)',
    allValues='.*',
    current='All',
    refresh=1,
    includeAll=true,
    multi=true,
    sort=1,
  )
)

.addRow(
  grafana.row.new(
    title='Key Metrics',
  )
  .addPanel(
    grafana.text.new(
      title='Service Description',
      content="Rosco is Spinnaker's bakery, producing machine images with Hashicorp Packer and rendered manifests with templating engines Helm and Kustomize.",
      span=6,
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Active Bakes (rosco, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(bakesActive{kubernetes_pod_name=~"$Instance"}) by (kubernetes_pod_name)',
        legendFormat='Active/{{kubernetes_pod_name}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Bake Request Rate (rosco, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesRequested_total{kubernetes_pod_name=~"$Instance"}[$__rate_interval])) by (flavor)',
        legendFormat='{{flavor}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Bake Failure Rate (rosco, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesCompleted_seconds_count{kubernetes_pod_name=~"$Instance",success="false"}[$__rate_interval])) by (cause, region)',
        legendFormat='{{cause}}/{{region}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Bake Succees Rate (rosco, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesCompleted_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (region)',
        legendFormat='/{{region}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Bake Failure Duration (rosco, $Instance)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
      nullPointMode='null as zero',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesCompleted_seconds_sum{kubernetes_pod_name=~"$Instance",success="false"}[$__rate_interval])) by (cause,region)\n/\nsum(rate(bakesCompleted_seconds_count{kubernetes_pod_name=~"$Instance",success="false"}[$__rate_interval])) by (cause,region)',
        legendFormat='{{cause}}/{{region}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Bake Success Duration (rosco, $Instance)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
      nullPointMode='null as zero',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesCompleted_seconds_sum{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (region)\n/\nsum(rate(bakesCompleted_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (region)',
        legendFormat='{{region}}',
      )
    )
  )
)

.addRow(hrm)

.addRow(jvm)

.addRow(kpm)
