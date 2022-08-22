local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.row.new(
  title='JVM Metrics',
)

.addPanel(
  grafana.graphPanel.new(
    title='JVM Memory Usage',
    datasource='$datasource',
    span=3,
    format='decbytes',
  )
  .addTarget(
    grafana.prometheus.target(
      'sum(jvm_memory_used_bytes{job=~"$job", kubernetes_pod_name=~"$Instance", area="heap"}) by (id)',
      legendFormat='{{id}}',
    )
  )
)

.addPanel(
  grafana.graphPanel.new(
    title='JVM GC Average Pause Seconds',
    datasource='$datasource',
    span=3,
    format='dtdurations',
  )
  .addTarget(
    grafana.prometheus.target(
      'sum by (kubernetes_pod_name) (jvm_gc_pause_seconds_sum{job=~"$job", kubernetes_pod_name=~"$Instance"}) \n / \n sum by (kubernetes_pod_name) (jvm_gc_pause_seconds_count{job=~"$job", kubernetes_pod_name=~"$Instance"})',
      legendFormat='{{kubernetes_pod_name}}',
    )
  )
)

.addPanel(
  grafana.graphPanel.new(
    title='JVM GC Maximum Pause Seconds',
    datasource='$datasource',
    span=3,
    format='dtdurations',
  )
  .addTarget(
    grafana.prometheus.target(
      'max by (kubernetes_pod_name) (jvm_gc_pause_seconds_max{job=~"$job", kubernetes_pod_name=~"$Instance"})',
      legendFormat='{{kubernetes_pod_name}}',
    )
  )
)

.addPanel(
  grafana.graphPanel.new(
    title='JVM Threads',
    datasource='$datasource',
    span=3,
    fill=0,
  )
  .addTarget(
    grafana.prometheus.target(
      'max_over_time(jvm_threads_live_threads{job=~"$job", kubernetes_pod_name=~"$Instance"}[$__rate_interval])',
      legendFormat='{{kubernetes_pod_name}}',
      interval='1m',
    )
  )
)
