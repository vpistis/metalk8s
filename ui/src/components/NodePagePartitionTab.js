// @flow
import React from 'react';
import styled from 'styled-components';
import { Button } from '@scality/core-ui/dist/next';
import { NodeTab } from './style/CommonLayoutStyle';
import { useIntl } from 'react-intl';
import { padding } from '@scality/core-ui/dist/style/theme';
import NodePartitionTable from './NodePartitionTable';
import { GRAFANA_DASHBOARDS, PORT_NODE_EXPORTER } from '../constants';
import { useTypedSelector } from '../hooks';

const TitleContainer = styled.div`
  display: flex;
  position: sticky;
  z-index: 100;
  top: 0;
  justify-content: flex-end;
  padding: ${padding.large} ${padding.base} 0 ${padding.larger};
`;

const NodePagePartitionTab = (props: Object) => {
  const { instanceIP } = props;
  const intl = useIntl();
  // To redirect to the right Node(Detailed) dashboard in Grafana
  const api = useTypedSelector((state) => state.config.api);
  const unameInfos = useTypedSelector(
    (state) => state.app.monitoring.unameInfo,
  );
  const hostnameLabel = unameInfos.find(
    (unameInfo) =>
      unameInfo?.metric?.instance === `${instanceIP}:${PORT_NODE_EXPORTER}`,
  )?.metric?.nodename;

  return (
    <NodeTab>
      <TitleContainer>
        {api && api.url_grafana && (
          <a
            // We can't redirect to the Node(detailed) Filesystem Detail category.
            // So we hardcode the panel ID to redirect to 'File Nodes Free' chart
            href={`${api.url_grafana}/d/${GRAFANA_DASHBOARDS.nodes}?var-DS_PROMETHEUS=Prometheus&var-job=node-exporter&var-name=${hostnameLabel}&viewPanel=41`}
            target="_blank"
            rel="noopener noreferrer"
          >
            <Button
              label={intl.formatMessage({ id: 'advanced_metrics' })}
              variant={'secondary'}
              icon={<i className="fas fa-external-link-alt" />}
              data-cy="advanced_metrics_node_detailed_file_node_free"
            />
          </a>
        )}
      </TitleContainer>
      <NodePartitionTable instanceIP={instanceIP} />
    </NodeTab>
  );
};

export default NodePagePartitionTab;
