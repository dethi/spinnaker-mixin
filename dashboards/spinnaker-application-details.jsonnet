local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.dashboard.new(
  'Spinnaker Application Details',
  editable=true,
  refresh='1m',
  time_from='now-6h',
  graphTooltip='shared_crosshair',
  tags=['spinnaker'],
  uid='spinnaker-application-details',
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
  grafana.template.new(
    name='Application',
    datasource='$datasource',
    query='label_values(stage_invocations_total{app_kubernetes_io_name=".*orca.*"}, application)',
    allValues='.*',
    current='All',
    refresh=2,
    includeAll=true,
    multi=true,
    sort=1,
  )
)

.addRow(
  grafana.row.new()
  .addPanel(
    grafana.graphPanel.new(
      title='Active Stages by Application (orca, $Application)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(stage_invocations_total{app_kubernetes_io_name=~".*orca.*", application=~"$Application"}[$__rate_interval])) by (application, type)',
        legendFormat='{{application}}/{{type}}',
      )
    )
  )

  .addPanel(
    grafana.graphPanel.new(
      title='$Application Pipelines Triggered (echo, $Application)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(pipelines_triggered_total{app_kubernetes_io_name=~".*echo.*", application=~"$Application"}[$__rate_interval])) by (application)',
        legendFormat='{{application}}',
      )
    )
  )

  .addPanel(
    grafana.graphPanel.new(
      title='Bakes Active and Requested (rosco)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(bakesActive{app_kubernetes_io_name=~".*rosco.*"})',
        legendFormat='Active',
      )
    )

    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesRequested_total{app_kubernetes_io_name=~".*rosco.*"}[$__rate_interval])) by (flavor)',
        legendFormat='Request({{flavor}})',
      )
    )
  )

  .addPanel(
    grafana.graphPanel.new(
      title='Bake Failure Rate (rosco)',
      datasource='$datasource',
      span=3,
      min=0,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesCompleted_seconds_count{app_kubernetes_io_name=~".*rosco.*",success="false"}[$__rate_interval])) by (cause, region)',
        legendFormat='{{cause}}/{{region}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Bake Succees Rate (rosco)',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(bakesCompleted_seconds_count{app_kubernetes_io_name=~".*rosco.*",success="true"}[$__rate_interval])) by (region)',
        legendFormat='{{region}}',
      )
    )
  )

  .addPanel(
    grafana.graphPanel.new(
      title='Resilience4J Open',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(resilience4j_circuitbreaker_state{state=~".*open"}) by (name, app_kubernetes_io_name)',
        legendFormat='{{app_kubernetes_io_name}}-{{name}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Resilience4J Failure Rate',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(rate(resilience4j_circuitbreaker_failure_rate[$__rate_interval])) by (name, app_kubernetes_io_name)',
        legendFormat='{{app_kubernetes_io_name}}-{{name}}',
      )
    )
  )
  .addPanel(
    grafana.graphPanel.new(
      title='Resilience4J Half-Open',
      datasource='$datasource',
      span=3,
    )
    .addTarget(
      grafana.prometheus.target(
        'sum(resilience4j_circuitbreaker_state{state="half_open"}) by (name, app_kubernetes_io_name)',
        legendFormat='{{app_kubernetes_io_name}}-{{name}}',
      )
    )
  )
)
