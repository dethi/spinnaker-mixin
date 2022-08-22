local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.row.new(
  title='Kubernetes Pod Metrics',
)
.addPanel(
  grafana.graphPanel.new(
    title='CPU',
    description='CPU Usage. Average is the average usage across all kubernetes_pod_names, max is the highest usage across all kubernetes_pod_names. As CPU Usage is a sampled metric it is best to view in relation to throttling percentage.',
    datasource='$datasource',
    span=3,
    fill=0,
    format='percentunit',
  )
  .addSeriesOverride({
    alias: '/avg|max/',
    fill: 1,
  })
  .addSeriesOverride({
    alias: 'Request',
    color: '#FF9830',
    dashes: true,
  })
  .addSeriesOverride({
    alias: 'Limit',
    color: '#F2495C',
    dashes: true,
  })
  .addTarget(
    grafana.prometheus.target(
      'avg(rate(container_cpu_usage_seconds_total{namespace="spinnaker", container=~"$Component"}[$__rate_interval]))',
      legendFormat='avg',
      interval='1m',
    )
  )
  .addTarget(
    grafana.prometheus.target(
      'max(rate(container_cpu_usage_seconds_total{namespace="spinnaker", container=~"$Component"}[$__rate_interval]))',
      legendFormat='max',
      interval='1m',
    )
  )
  .addTarget(
    grafana.prometheus.target(
      'avg(kube_pod_container_resource_limits_cpu_cores{namespace="spinnaker", container=~"$Component"})',
      legendFormat='Limit',
    )
  )
  .addTarget(
    grafana.prometheus.target(
      'avg(kube_pod_container_resource_requests_cpu_cores{namespace="spinnaker", container=~"$Component"})',
      legendFormat='Request',
    )
  )
)
.addPanel(
  grafana.graphPanel.new(
    title='CPU Throttling',
    description='Percent of the time that the CPU is being throttled. Application may be getting throttled during bursty tasks but overall be well below its CPU limit. Throttling may significantly impact application performance.',
    datasource='$datasource',
    span=3,
    format='percentunit',
    nullPointMode='connected',
  )
  .addTarget(
    grafana.prometheus.target(
      'rate(container_cpu_cfs_throttled_periods_total{namespace="spinnaker", container=~"$Component"}[$__rate_interval])\n/\nrate(container_cpu_cfs_periods_total{namespace="spinnaker", container=~"$Component"}[$__rate_interval])',
      legendFormat='{{pod}}',
      interval='1m',
    )
  )
)
.addPanel(
  grafana.graphPanel.new(
    title='Memory',
    description='Memory utilisation. Average is the average usage across all instaces, max is the highest usage across all kubernetes_pod_names.',
    datasource='$datasource',
    span=3,
    fill=0,
    format='decbytes',
  )
  .addSeriesOverride({
    alias: '/avg|max/',
    fill: 1,
  })
  .addSeriesOverride({
    alias: 'Request',
    color: '#FF9830',
    dashes: true,
  })
  .addSeriesOverride({
    alias: 'Limit',
    color: '#F2495C',
    dashes: true,
  })
  .addTarget(
    grafana.prometheus.target(
      'avg(avg_over_time(container_memory_working_set_bytes{namespace="spinnaker", container=~"$Component"}[$__interval]))',
      legendFormat='avg',
    )
  )
  .addTarget(
    grafana.prometheus.target(
      'max(max_over_time(container_memory_working_set_bytes{namespace="spinnaker", container=~"$Component"}[$__interval]))',
      legendFormat='max',
    )
  )
  .addTarget(
    grafana.prometheus.target(
      'avg(kube_pod_container_resource_limits_memory_bytes{namespace="spinnaker", container=~"$Component"})',
      legendFormat='Limit',
    )
  )
)
.addPanel(
  grafana.graphPanel.new(
    title='Network',
    description='Average network ingress/egress for the $spinSvc pods.',
    datasource='$datasource',
    span=3,
    nullPointMode='connected',
    format='Bps',
  )
  .addSeriesOverride({
    alias: 'transmit',
    transform: 'negative-Y',
  })
  .addTarget(
    grafana.prometheus.target(
      'avg(\n  sum without (interface) (\n    rate(container_network_receive_bytes_total{namespace="spinnaker", pod=~"spin-$Component-.*"}[$__rate_interval])\n  )\n)',
      legendFormat='receive',
    )
  )
  .addTarget(
    grafana.prometheus.target(
      'avg(\n  sum without (interface) (\n    rate(container_network_transmit_bytes_total{namespace="spinnaker", pod=~"spin-$Component-.*"}[$__rate_interval])\n  )\n)',
      legendFormat='transmit',
    )
  )
)
