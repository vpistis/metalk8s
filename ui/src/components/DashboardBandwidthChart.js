//@flow
import React, { useEffect, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { LineTemporalChart } from '@scality/core-ui/dist/next';
import { UNIT_RANGE_BS } from '@scality/core-ui/dist/components/linetemporalchart/LineTemporalChart.component';
import {
  getMultipleSymmetricalSeries,
  getNodesInterfacesString,
  renderTooltipSeperationLine,
} from '../services/graphUtils';
import { fetchNodesAction } from '../ducks/app/nodes';
import {
  useNodeAddressesSelector,
  useNodes,
  useShowQuantileChart,
  useSymetricalChartSeries,
} from '../hooks';
import {
  getNodesPlanesBandwidthInOutpassingThresholdQuery,
  getNodesPlanesBandwidthInQuantileQuery,
  getNodesPlanesBandwidthInQuery,
  getNodesPlanesBandwidthOutOutpassingThresholdQuery,
  getNodesPlanesBandwidthOutQuantileQuery,
  getNodesPlanesBandwidthOutQuery,
} from '../services/platformlibrary/metrics';
import SymmetricalQuantileChart from './SymmetricalQuantileChart';
import { defaultRenderTooltipSerie } from '@scality/core-ui/dist/components/linetemporalchart/tooltip';
import { useTheme } from 'styled-components';

const DashboardBandwidthChartWithoutQuantile = ({
  title,
  plane,
}: {
  title: string,
  plane: 'controlPlane' | 'workloadPlane',
}) => {
  const theme = useTheme();
  const nodes = useNodes();
  const nodeAddresses = useNodeAddressesSelector(nodes);
  const nodeIPsInfo = useSelector((state) => state.app.nodes.IPsInfo);
  const devices = getNodesInterfacesString(nodeIPsInfo);
  const nodesPlaneInterface = {};
  for (const [key, value] of Object.entries(nodeIPsInfo)) {
    nodesPlaneInterface[key] =
      plane === 'controlPlane' ? value.controlPlane : value.workloadPlane;
  }
  // will be used to draw the line speration lines
  const lastNodeName = nodes?.slice(-1)[0]?.metadata?.name;
  const { isLoading, series, startingTimeStamp } = useSymetricalChartSeries({
    getAboveQueries: (timeSpanProps) => [
      getNodesPlanesBandwidthInQuery(timeSpanProps, devices),
    ],
    getBelowQueries: (timeSpanProps) => [
      getNodesPlanesBandwidthOutQuery(timeSpanProps, devices),
    ],
    transformPrometheusDataToSeries: useCallback(
      ([prometheusResultAbove], [prometheusResultBelow]) => {
        if (!prometheusResultAbove || !prometheusResultBelow) {
          return [];
        }
        return getMultipleSymmetricalSeries(
          prometheusResultAbove,
          prometheusResultBelow,
          'in',
          'out',
          nodeAddresses,
          nodesPlaneInterface,
        );
      },
      [JSON.stringify(nodeAddresses), JSON.stringify(nodesPlaneInterface)],
    ),
  });
  return (
    <LineTemporalChart
      series={series}
      height={150}
      title={title}
      startingTimeStamp={startingTimeStamp}
      yAxisType={'symmetrical'}
      yAxisTitle={'in(+) / out(-)'}
      isLegendHidden={false}
      isLoading={isLoading}
      unitRange={UNIT_RANGE_BS}
      renderTooltipSerie={useCallback(
        (serie) => {
          if (serie.key === `${lastNodeName}-in`) {
            return `${defaultRenderTooltipSerie(
              serie,
            )}${renderTooltipSeperationLine(theme.border)}`;
          } else {
            return defaultRenderTooltipSerie(serie);
          }
        },
        [lastNodeName, theme],
      )}
    />
  );
};

const DashboardBandwidthChart = ({
  title,
  plane,
}: {
  title: string,
  plane: 'controlPlane' | 'workloadPlane',
}) => {
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(fetchNodesAction());
  }, [dispatch]);
  const { isShowQuantileChart } = useShowQuantileChart();
  return (
    <>
      {isShowQuantileChart ? (
        <SymmetricalQuantileChart
          getAboveQuantileQuery={getNodesPlanesBandwidthInQuantileQuery}
          getBelowQuantileQuery={getNodesPlanesBandwidthOutQuantileQuery}
          getAboveQuantileHoverQuery={
            getNodesPlanesBandwidthInOutpassingThresholdQuery
          }
          getBelowQuantileHoverQuery={
            getNodesPlanesBandwidthOutOutpassingThresholdQuery
          }
          metricPrefixAbove={'in'}
          metricPrefixBelow={'out'}
          title={title}
          yAxisTitle={'in(+) / out(-)'}
        />
      ) : (
        <DashboardBandwidthChartWithoutQuantile title={title} plane={plane} />
      )}
    </>
  );
};

export default DashboardBandwidthChart;
