import React, { useCallback } from 'react';
import { LineTemporalChart } from '@scality/core-ui/dist/next';
import { GraphWrapper } from './DashboardMetrics';
import {
  useNodeAddressesSelector,
  useNodes,
  useSingleChartSerie,
} from '../hooks';
import type { DashboardChartProps } from '../containers/DashboardPage';
import {
  getNodesSystemLoadAboveBelowThresholdQuery,
  getNodesSystemLoadQuantileQuery,
  getNodesSystemLoadQuery,
} from '../services/platformlibrary/metrics';
import { getMultiResourceSeriesForChart } from '../services/graphUtils';
import NonSymmetricalQuantileChart from './NonSymmetricalQuantileChart';

const DashboardChartSystemLoad = ({
  isShowQuantileChart,
}: {
  isShowQuantileChart: boolean,
}) => {
  return (
    <GraphWrapper>
      {isShowQuantileChart ? (
        <NonSymmetricalQuantileChart
          getQuantileQuery={getNodesSystemLoadQuantileQuery}
          getQuantileHoverQuery={getNodesSystemLoadAboveBelowThresholdQuery}
          title={'System Load'}
        />
      ) : (
        <DashboardChartSystemLoadWithoutQuantiles />
      )}
    </GraphWrapper>
  );
};

const DashboardChartSystemLoadWithoutQuantiles = (
  props: DashboardChartProps,
) => {
  const nodeAddresses = useNodeAddressesSelector(useNodes());
  const { isLoading, series, startingTimeStamp } = useSingleChartSerie({
    getQuery: (timeSpanProps) => getNodesSystemLoadQuery(timeSpanProps),
    transformPrometheusDataToSeries: useCallback(
      (prometheusResult) =>
        getMultiResourceSeriesForChart(prometheusResult, nodeAddresses),
      // eslint-disable-next-line react-hooks/exhaustive-deps
      [JSON.stringify(nodeAddresses)],
    ),
  });
  return (
    <LineTemporalChart
      series={series}
      height={80}
      title="System Load"
      startingTimeStamp={startingTimeStamp}
      isLegendHided={true}
      isLoading={isLoading}
    />
  );
};

export default DashboardChartSystemLoad;
