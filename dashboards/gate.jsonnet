local hrm = import './http-request-metrics.jsonnet';
local jvm = import './jvm-metrics.jsonnet';
local kpm = import './kubernetes-pod-metrics.jsonnet';
local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.dashboard.new(
  'Gate',
  editable=true,
  refresh='1m',
  time_from='now-6h',
  graphTooltip='shared_crosshair',
  tags=['spinnaker'],
  uid='spinnaker-gate',
)

// Links

.addLinks(
  [
    grafana.link.dashboards(
      icon='info',
      tags=[],
      title='GitHub',
      type='link',
      url='https://github.com/spinnaker/gate',
    ),
  ]
)

// Templates

.addTemplate(
  grafana.template.datasource(
    name='datasource',
    label='Datasource',
    query='prometheus',
    current='cv-infra',
  )
)
.addTemplate(
  grafana.template.custom(
    name='spinSvc',
    query='gate',
    current='gate',
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
      content='This service provides the Spinnaker REST API, servicing scripting clients as well as all actions from Deck. The REST API fronts the following services:\n\n- Clouddriver\n-Front50\n-Igor\n-Orca',
      span=3,
    )
  )
)

.addRow(
  grafana.row.new(
    title='Additional Metrics',
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Resilience4J Open (gate, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(resilience4j_circuitbreaker_state{app_kubernetes_io_name=~"$Component", state=~".*open", kubernetes_pod_name=~"$Instance"}) by (name)',
        legendFormat='{{name}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Resilience4J Failure Rate (gate, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(resilience4j_circuitbreaker_failure_rate{app_kubernetes_io_name=~"$Component", kubernetes_pod_name=~"$Instance"}[$__rate_interval])) by (name)',
        legendFormat='{{ name }}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Resilience4J Half-Open (gate, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(resilience4j_circuitbreaker_state{app_kubernetes_io_name=~"$Component", state="half_open", kubernetes_pod_name=~"$Instance"}) by (name)',
        legendFormat='{{name}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Rate Limit Throttling (gate, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'rate(rateLimitThrottling_total{kubernetes_pod_name=~"$Instance"}[$__rate_interval])',
        legendFormat='',
      )
    )
  )
)

.addRow(hrm)

.addRow(jvm)

.addRow(kpm)
