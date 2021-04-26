//@flow
import React, { useCallback, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { ThemeProvider } from 'styled-components';
import { matchPath, RouteProps, Route, Redirect } from 'react-router';
import { useHistory, useLocation, Switch } from 'react-router-dom';
import {
  Layout as CoreUILayout,
  Notifications,
  Loader,
  ScrollbarWrapper,
  ErrorPage404,
} from '@scality/core-ui';
import { intl } from '../translations/IntlGlobalProvider';
import { toggleSideBarAction } from '../ducks/app/layout';
import { removeNotificationAction } from '../ducks/app/notifications';
import CreateVolume from './CreateVolume';
import { fetchClusterVersionAction } from '../ducks/app/nodes';
import { useTypedSelector } from '../hooks';
import { Navbar } from '../components/Navbar';
import { Suspense } from 'react';
import AlertProvider from './AlertProvider';

const NodeCreateForm = React.lazy(() => import('./NodeCreateForm'));
const NodePage = React.lazy(() => import('./NodePage'));
const About = React.lazy(() => import('./About'));
const PrivateRoute = React.lazy(() => import('./PrivateRoute'));
const VolumePage = React.lazy(() => import('./VolumePage'));
const DashboardPage = React.lazy(() => import('./DashboardPage'));
const AlertPage = React.lazy(() => import('./AlertPage'));

const Layout = () => {
  const sidebar = useTypedSelector((state) => state.app.layout.sidebar);
  const { theme, language } = useTypedSelector((state) => state.config);
  const notifications = useTypedSelector(
    (state) => state.app.notifications.list,
  );

  const isUserLoaded = useTypedSelector((state) => !!state.oidc?.user);
  const api = useTypedSelector((state) => state.config.api);
  const dispatch = useDispatch();

  const removeNotification = (uid) => dispatch(removeNotificationAction(uid));
  const toggleSidebar = () => dispatch(toggleSideBarAction());
  const history = useHistory();
  const location = useLocation();

  useEffect(() => {
    dispatch(fetchClusterVersionAction());
  }, [dispatch]);

  const doesRouteMatch = useCallback(
    (path: RouteProps) => {
      const location = history.location;
      return matchPath(location.pathname, path);
    },
    [location],
  );

  const isAlertsPage = doesRouteMatch({
    path: '/alerts',
    exact: true,
    strict: true,
  });

  const sidebarConfig = {
    onToggleClick: toggleSidebar,
    hoverable: true,
    expanded: sidebar.expanded,
    'data-cy-state-isexpanded': sidebar.expanded,
    actions: [
      {
        label: intl.translate('dashboard'),
        icon: <i className="fas fa-desktop" />,
        onClick: () => {
          history.push('/dashboard');
        },
        active: doesRouteMatch({
          path: '/dashboard',
          exact: true,
          strict: true,
        }),
        'data-cy': 'sidebar_item_dashboard',
      },
      // TODO: Will move to the global navbar
      {
        label: intl.translate('nodes'),
        icon: <i className="fas fa-server" />,
        onClick: () => {
          history.push('/nodes');
        },
        active: doesRouteMatch({
          path: '/nodes',
          exact: false,
          strict: true,
        }),
        'data-cy': 'sidebar_item_nodes',
      },
      {
        label: intl.translate('volumes'),
        icon: <i className="fas fa-database" />,
        onClick: () => {
          history.push('/volumes');
        },
        active: doesRouteMatch({
          path: '/volumes',
          exact: false,
          strict: true,
        }),
        'data-cy': 'sidebar_item_volumes',
      },
    ],
  };
  // Remove the access to dashboard page if no flags property in the config.json,
  // or no `dashboard` specified in the values.
  if (
    (api && !Object.prototype.hasOwnProperty.call(api, 'flags')) ||
    (api && api.flags && !api.flags.includes('dashboard'))
  ) {
    sidebarConfig.actions.shift();
  }

  return (
    <ThemeProvider theme={theme}>
      <ScrollbarWrapper>
        <CoreUILayout
          sidebar={isUserLoaded && !isAlertsPage ? sidebarConfig : undefined}
          navbarElement={<Navbar />}
        >
          <AlertProvider>
            <Notifications
              notifications={notifications}
              onDismiss={removeNotification}
            />
            <Suspense fallback={<Loader size="massive" centered={true} />}>
              <Switch>
                <PrivateRoute
                  exact
                  path="/"
                  component={() => <Redirect to="/nodes" />}
                />
                <PrivateRoute
                  exact
                  path="/nodes/create"
                  component={NodeCreateForm}
                />
                <PrivateRoute
                  path={`/nodes/:id/createVolume`}
                  component={CreateVolume}
                />
                <PrivateRoute
                  exact
                  path="/volumes/createVolume"
                  component={CreateVolume}
                />
                <PrivateRoute path="/nodes" component={NodePage} />
                <PrivateRoute path="/volumes/:name?" component={VolumePage} />
                <PrivateRoute exact path="/about" component={About} />
                <PrivateRoute exact path="/alerts" component={AlertPage} />

                {api && api.flags && api.flags.includes('dashboard') && (
                  <PrivateRoute
                    exact
                    path="/dashboard"
                    component={DashboardPage}
                  />
                )}
                <Route
                  component={() => (
                    <ErrorPage404
                      data-cy="sc-error-page404"
                      locale={language}
                    />
                  )}
                />
              </Switch>
            </Suspense>
          </AlertProvider>
        </CoreUILayout>
      </ScrollbarWrapper>
    </ThemeProvider>
  );
};

export default Layout;
