local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.dashboard.new(
  'Spinnaker Kubernetes Platform',
  editable=true,
  refresh='1m',
  time_from='now-1h',
  graphTooltip='shared_crosshair',
  tags=['spinnaker'],
  uid='spinnaker-kubernetes-platform',
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
    query='clouddriver',
    current='clouddriver',
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
.addTemplate(
  grafana.template.new(
    name='KubernetesAccount',
    datasource='$datasource',
    query='label_values(kubernetes_api_seconds_count, account)',
    allValues='.*',
    current='All',
    refresh=1,
    includeAll=true,
    sort=1,
  )
)
.addTemplate(
  grafana.template.new(
    name='KubernetesNamespace',
    datasource='$datasource',
    query='label_values(kubernetes_api_seconds_count, exported_namespace)',
    allValues='.*',
    current='All',
    refresh=1,
    includeAll=true,
    sort=1,
  )
)

.addRow(
  grafana.row.new(
    title='Kubernetes',
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Success for "$KubernetesAccount" in "$KubernetesNamespace" (clouddriver)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",exported_namespace=~"$KubernetesNamespace",account=~"$KubernetesAccount",success="true"}[$__rate_interval])) by (action)',
        legendFormat='{{action}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Latency for "$KubernetesAccount" in "$KubernetesNamespace" (clouddriver)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_sum{kubernetes_pod_name=~"$Instance",exported_namespace=~"$KubernetesNamespace",success="true",account=~"$KubernetesAccount"}[$__rate_interval])) by (action)\n/\nsum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",exported_namespace=~"$KubernetesNamespace",account=~"$KubernetesAccount",success="true"}[$__rate_interval])) by (action)',
        legendFormat='{{action}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Failure for "$KubernetesAccount" in "$KubernetesNamespace" (clouddriver)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",exported_namespace=~"$KubernetesNamespace",account=~"$KubernetesAccount",success!="true"}[$__rate_interval])) by (action, reason)',
        legendFormat='{{action}}/{{reason}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Failure Latency for "$KubernetesAccount" in "$KubernetesNamespace" (clouddriver)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_sum{kubernetes_pod_name=~"$Instance",exported_namespace=~"$KubernetesNamespace",success!="true",account=~"$KubernetesAccount"}[$__rate_interval])) by (action, reason)\n/\nsum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",exported_namespace=~"$KubernetesNamespace",account=~"$KubernetesAccount",success!="true"}[$__rate_interval])) by (action)',
        legendFormat='{{action}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Success by Kind (clouddriver, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (kinds)',
        legendFormat='{{kinds}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Success by Account (clouddriver, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (account)',
        legendFormat='{{account}} ',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Success by Namespace (clouddriver, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (exported_namespace)',
        legendFormat='{{exported_namespace}} ',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Latency by Kind (clouddriver)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_sum{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (kinds)\n/\nsum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (kinds)',
        legendFormat='{{kinds}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Latency by Account (clouddriver)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_sum{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (account)\n/\nsum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (account)',
        legendFormat='{{account}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Latency by Namespace (clouddriver)',
      datasource='$datasource',
      span=3,
      format='dtdurations',
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_sum{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (exported_namespace) / sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success="true"}[$__rate_interval])) by (exported_namespace)',
        legendFormat='{{exported_namespace}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Failure by Kind (clouddriver, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success!="true"}[$__rate_interval])) by (kinds)',
        legendFormat='{{kinds}} ',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Failure by Account (clouddriver, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success!="true"}[$__rate_interval])) by (account)',
        legendFormat='{{account}} ',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Kubernetes Failure by Namespace (clouddriver, $Instance)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(kubernetes_api_seconds_count{kubernetes_pod_name=~"$Instance",success!="true"}[$__rate_interval])) by (exported_namespace)',
        legendFormat='{{exported_namespace}} ',
      )
    )
  )
)
