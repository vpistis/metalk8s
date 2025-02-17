//@flow
import { useContext } from 'react';
import { Query } from 'react-query';
import { AlertContext } from './alertContext';
import type { FilterLabels, Alert } from './services/alertUtils';
import { getHealthStatus, filterAlerts } from './services/alertUtils';

export const getPlatformAlertSelectors = (): FilterLabels => {
  return { alertname: ['ClusterAtRisk', 'ClusterDegraded'] };
};

export const getNodesAlertSelectors = (): FilterLabels => {
  return { alertname: ['NodeAtRisk', 'NodeDegraded'] };
};

export const getVolumesAlertSelectors = (): FilterLabels => {
  return { alertname: ['VolumeAtRisk', 'VolumeDegraded'] };
};

export const getNetworksAlertSelectors = (): FilterLabels => {
  return {
    alertname: ['NetworkDegraded'],
  };
};

export const getServicesAlertSelectors = (): FilterLabels => {
  return {
    alertname: ['PlatformServicesAtRisk', 'PlatformServicesDegraded'],
  };
};

export const getK8SMasterAlertSelectors = (): FilterLabels => {
  return {
    alertname: [
      'KubernetesControlPlaneAtRisk',
      'KubernetesControlPlaneDegraded',
    ],
  };
};

export const getBootstrapAlertSelectors = (): FilterLabels => {
  return { alertname: ['BootstrapServicesDegraded'] };
};

export const getMonitoringAlertSelectors = (): FilterLabels => {
  return {
    alertname: ['MonitoringServiceAtRisk', 'MonitoringServiceDegraded'],
  };
};

export const getAlertingAlertSelectors = (): FilterLabels => {
  return {
    alertname: ['AlertingServiceAtRisk', 'AlertingServiceDegraded'],
  };
};

export const getLoggingAlertSelectors = (): FilterLabels => {
  return { alertname: ['LoggingServiceDegraded'] };
};

export const getDashboardingAlertSelectors = (): FilterLabels => {
  return { alertname: ['DashboardingServiceDegraded'] };
};

export const getIngressControllerAlertSelectors = (): FilterLabels => {
  return { alertname: ['IngressControllerServicesDegraded'] };
};

export const getAuthenticationAlertSelectors = (): FilterLabels => {
  return { alertname: ['AuthenticationServiceDegraded'] };
};

/**
 *
 * @param {FilterLabels} filters
 * @returns An array of alerts with the highest severity
 */
export const useHighestSeverityAlerts = (filters: FilterLabels): Alert[] => {
  const query = useAlerts(filters);
  const filteredAlerts = query && query.alerts;

  if (!filteredAlerts || !filteredAlerts.length) return [];

  const health = getHealthStatus(filteredAlerts);
  return filteredAlerts.filter((alert) => alert.severity === health);
};

/**
 * Hook that enables retrieval of alerts fetched by <AlertProvider />
 *
 * @returns react query result
 */
export function useAlerts(filters: FilterLabels) {
  const query = useContext(AlertContext);
  if (!query) {
    throw new Error(
      'The useAlerts hook can only be used within AlertProvider.',
    );
  } else if (query.status === 'success') {
    const newQuery = {
      ...query,
      alerts: filterAlerts(query.data, filters),
    };
    delete newQuery.data;
    return newQuery;
  }
  return query;
}
