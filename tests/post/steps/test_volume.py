import re
from urllib3.exceptions import HTTPError

import kubernetes.client
from kubernetes.client import CustomObjectsApi
from kubernetes.client import StorageV1Api
from kubernetes.client.rest import ApiException
import pytest
from pytest_bdd import given, when, scenario, then, parsers
import yaml

from tests import utils


# Constants {{{

DEFAULT_VOLUME = """
apiVersion: storage.metalk8s.scality.com/v1alpha1
kind: Volume
metadata:
  name: {name}
spec:
  nodeName: bootstrap
  storageClassName: metalk8s-prometheus
  sparseLoopDevice:
    size: 10Gi
"""

# }}}
# Fixture {{{

@pytest.fixture
def k8s_custom_client(k8s_apiclient):
    return CustomObjectsApi(api_client=k8s_apiclient)

# }}}
# Scenarios {{{

@scenario('../features/volume.feature', 'Our StorageClass is deployed')
def test_deploy_storage_class(host):
    pass

@scenario('../features/volume.feature', 'The storage operator is up')
def test_deploy_operator(host):
    pass

@scenario('../features/volume.feature',
          'Test volume creation (sparseLoopDevice)')
def test_volume_creation(host):
    pass

@scenario('../features/volume.feature',
          'Test volume deletion (sparseLoopDevice)')
def test_volume_deletion(host):
    pass

@scenario('../features/volume.feature', 'Test PersistentVolume protection')
def test_pv_protection(host):
    pass

@scenario('../features/volume.feature', 'Create a volume with no volume type')
def test_no_volume_type(host):
    pass

# }}}
# Given {{{

@given(parsers.parse("a Volume '{name}' exist"))
def volume_exist(host, name, k8s_custom_client):
    if _get_volume(k8s_custom_client, name) is not None:
        return
    body = DEFAULT_VOLUME.format(name=name)
    _create_volume(k8s_custom_client, body)
    check_volume_status(host, name, 'Available', k8s_custom_client)

# }}}
# When {{{

@when(parsers.parse("I create the following Volume:\n{body}"))
def create_volume(host, body, k8s_custom_client):
    _create_volume(k8s_custom_client, body)


@when(parsers.parse("I delete the Volume '{name}'"))
def delete_volume(host, name, k8s_custom_client):
    k8s_custom_client.delete_cluster_custom_object(
        group="storage.metalk8s.scality.com",
        version="v1alpha1",
        plural="volumes",
        name=name,
        body=kubernetes.client.V1DeleteOptions(),
        grace_period_seconds=0
    )


@when(parsers.parse("I delete the PersistentVolume '{name}'"))
def delete_pv(host, name, k8s_client):
    k8s_client.delete_persistent_volume(
        name=name,
        body=kubernetes.client.V1DeleteOptions(),
        grace_period_seconds=0
    )


# }}}
# Then {{{

@then(parsers.parse("we have a StorageClass '{name}'"))
def check_storage_class(host, name, k8s_apiclient):
    k8s_client = StorageV1Api(api_client=k8s_apiclient)
    try:
        k8s_client.read_storage_class(name) is not None
    except (ApiException, HTTPError) as exc:
        if isinstance(exc, ApiException) and exc.status == 404:
            assert False, 'StorageClass {} not found'.format(name)
        raise


@then(parsers.parse("the Volume '{name}' is '{status}'"))
def check_volume_status(host, name, status, k8s_custom_client):
    def _check_volume_status():
        volume = _get_volume(k8s_custom_client, name)
        assert volume is not None, 'Volume {} not found'.format(name)
        try:
            assert volume['status']['phase'] == status,\
                'Unexpected status: expected {}, got {}'.format(
                    status, volume['status']['phase']
                )
        except KeyError:
            assert status == 'Unknown', \
                'Unexpected status: expected {}, got none'.format(status)

    utils.retry(
        _check_volume_status, times=30, wait=2,
        name='checking status of Volume {}'.format(name)
    )


@then(parsers.parse("the PersistentVolume '{name}' has size '{size}'"))
def check_pv_size(host, name, size, k8s_client):
    def _check_pv_size():
        try:
            pv = k8s_client.read_persistent_volume(name)
        except (ApiException, HTTPError) as exc:
            if isinstance(exc, ApiException) and exc.status == 404:
                assert False, 'PersistentVolume {} not found'.format(name)
            raise
        assert pv.spec.capacity['storage'] == size, \
            'Unexpected PersistentVolume size: expected {}, got {}'.format(
                size, pv.spec.capacity['storage']
            )

    utils.retry(
        _check_pv_size, times=10, wait=2,
        name='checking size of PersistentVolume {}'.format(name)
    )


@then(parsers.parse("the Volume '{name}' does not exist"))
def check_volume_absent(host, name, k8s_custom_client):
    def _check_volume_absent():
        assert _get_volume(k8s_custom_client, name) is None,\
            'Volume {} still exist'.format(name)

    utils.retry(
        _check_volume_absent, times=30, wait=2,
        name='checking for the absence of volume {}'.format(name)
    )


@then(parsers.parse("the PersistentVolume '{name}' does not exist"))
def check_pv_absent(name, k8s_client):
    def _check_pv():
        assert _get_pv(k8s_client, name) is None,\
            'PersistentVolume {} exist'.format(name)

    utils.retry(
        _check_pv, times=10, wait=2,
        name='checking the absence of PersistentVolume {}'.format(name)
    )


@then(parsers.parse("the PersistentVolume '{name}' is marked for deletion"))
def check_pv_deletion_marker(name, k8s_client):
    def _check_pv_deletion_marker():
        pv = _get_pv(k8s_client, name)
        assert pv is not None, 'PersistentVolume {} not found'.format(name)
        assert pv.metadata.deletion_timestamp is not None,\
            'PersistentVolume {} is not marked for deletion'.format(name)

    utils.retry(
        _check_pv_deletion_marker, times=10, wait=2,
        name='checking that PersistentVolume {} is marked for deletion'.format(
            name
        )
    )


@then(parsers.parse("the Volume '{name}' is 'Failed' "
                    "with code '{code}' and message matches '{pattern}'"))
def check_volume_error(host, name, code, pattern, k8s_custom_client):
    def _check_error():
        volume = _get_volume(k8s_custom_client, name)
        assert volume is not None, 'Volume {} not found'.format(name)
        status = volume.get('status')
        assert status is not None, 'no status for volume {}'.format(name)
        assert status['phase'] == 'Failed',\
            'Unexpected status: expected Failed, got {}'.format(
                status, status['phase']
            )
        assert status['errorCode'] == code,\
            'Unexpected error code: expected {}, got {}'.format(
                code, status['errorCode']
            )
        assert re.search(pattern, status['errorMessage']) is not None,\
            "error message `{}` doesn't match `{}`".format(
                status['errorMessage'], pattern
            )

    utils.retry(
        _check_error, times=30, wait=2,
        name='checking error for Volume {}'.format(name)
    )

# }}}
# Helpers {{{
# Volume {{{

def _create_volume(k8s_client, body):
    k8s_client.create_cluster_custom_object(
        group="storage.metalk8s.scality.com",
        version="v1alpha1",
        plural="volumes",
        body=yaml.safe_load(body)
    )


def _get_volume(k8s_client, name):
    try:
        return k8s_client.get_cluster_custom_object(
            group="storage.metalk8s.scality.com",
            version="v1alpha1",
            plural="volumes",
            name=name
        )
    except (ApiException, HTTPError) as exc:
        if isinstance(exc, ApiException) and exc.status == 404:
            return None
        raise

# }}}
# PersistentVolume {{{

def _get_pv(k8s_client, name):
    try:
        return k8s_client.read_persistent_volume(name)
    except (ApiException, HTTPError) as exc:
        if isinstance(exc, ApiException) and exc.status == 404:
            return None
        raise

# }}}
# }}}
