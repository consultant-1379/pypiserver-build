## Deployment

This section describes the operational procedures for how to deploy and upgrade the `Python Package Repository` Service Service in a Kubernetes environment with Helm. It also covers hardening guidelines to consider when deploying this service.

### Prerequisites

- A running Kubernetes environment with helm support, some knowledge of
the Kubernetes environment, including the networking detail, and access
rights to deploy and manage workloads.
- Access rights to deploy and manage workloads.
- Availability of the kubectl CLI tool with compatible version and correct
authentication details. Contact the Kubernetes System Admin if necessary.
- Availability of the helm package
- Availability of Helm charts and Docker images for the service
and all dependent services.

`Python Package Repository` Service has been tested on Kubernetes 1.25 using Kubectl version 1.25.3
and Helm version 3.11.3.

### Deployment in a Kubernetes Environment Using Helm

This section describes how to deploy service in Kubernetes using _Helm_ and
_kubectl_ CLI client. Helm is a package manager for Kubernetes that streamlines
the installation and management of Kubernetes applications.

#### Preparation

Prepare helm chart and docker images.
Helm chart in the following link can be used for installation:
<https://arm.seli.gic.ericsson.se/artifactory/proj-mlops-released-helm/>

Fetch the latest released version of _eric-lcm-package-repository-py_ helm chart.

#### Pre-Deployment Checks for Python Package Repository Service

Ensure the following:

- The `<RELEASE_NAME>` is not used already in the corresponding cluster.
Use helm list command to list the existing deployments (and delete previous deployment
with the corresponding <RELEASE_NAME> if needed).
- The same namespace is used for all deployments.

#### Helm Chart Installations of Dependent Services

##### Helm Chart Installation of Backup and Restore Orchestrator
If users want to use Python Package Repository Backup and Restore, users needs to install Backup and Restore Orchestrator, and set brAgent.enabled=true to enabled Backup and Restore Agent when deploying Python Package Repository.

For more information, refer to [Backup and Restore Orchestrator (BRO)][docbroug].

##### Helm Chart Installation of Service Identity Provider TLS

The SIP TLS CRD and SIP TLS Service should be installed as a prerequisite,
if TLS is enabled for Python Package Repository  Service.

For installation of Service Identity Provider TLS Service deployment refer
[Service Identity Provider TLS User Guide][docdsiptls].

Users can set global.security.tls.enabled=false to disable TLS function.

##### Helm Chart Installation of ServiceMesh Controller

Python Package Repository  Service uses ServiceMesh CRD and Controller service for
internal cluster Mutual TLS (mTLS).

For Installation of ServiceMesh Controller refer
[ServiceMesh Controller User Guide] [docsmctl]

##### Helm Chart Installation of ServiceMesh Gateways

ServiceMesh Gateway is used to handle external traffic towards
Python Package Repository  Service. The external traffic terminates at ServiceMesh gateway
and all internal cluster traffic are secured via ServiceMesh proxy.

For installation of ServiceMesh Gateways
refer [ServiceMesh Gateways User Guide] [docsmgtwy]

##### Helm Chart Installation of Log Transformer

If users want to enable Application Level Log, Log Transformer is mandatory which deployed in the same namespace.

For more information, refer to - Log Transformer.

##### Helm Chart Installation of Certificate Management

Users can use Certificate Management provide certificate to ingress controller for securing the cluster-external interface.

For more information, refer to - Certificate Management.

##### Helm Chart Installation of Ingress Controller CR

Container Registry can be accessed via Ingress Controller CR.

For more information, refer to - Ingress Controller CR (ICCR) [docdiccr].

### Helm Chart Installation of Python Package Repository Service Service

> **_Note:_** Ensure all dependent services are deployed and healthy before
continue with this step (see previous chapter).

Helm is a tool that streamlines installing and managing Kubernetes applications.
`Python Package Repository` Service can be deployed on Kubernetes using Helm Charts. Charts are
packages of pre-configured Kubernetes resources. Users can override the default
values provided in the values.yaml template of the helm chart. The recommended
parameters to override are listed in [Configuration Parameters section](#configuration-parameters).

### Deploy the Python Package Repository Service

##### Deploy with dynamic Log Shipper Sidecar

An integration chart with dynamic sidecar injection configuration is necessary for
eric-lcm-package-repository-py logs to be forwarded to a log aggregator service such as
Log transformer.

Add `stream` option to the `global.log.outputs` field in `values.yaml` of
the integration chart file to deploy with Log Shipper sidecar.

> **_Note:_** Ensure that the dependent services of ADP Log Shipper are installed
and running. Refer [Log Shipper User Guide][docdls]

**values.yaml**

```yaml
global:
    log:
        outputs:
            - "stream"
```

Log forwarding from the following containers are supported:

| Container                                        | Logfile            |
| ------------------------------------------------ | ------------------ |
| eric-lcm-package-repository-py                   | pypiserver.log     |


These container log files are default configured by the `logShipper.input.files.paths`
in the values.yaml of eric-lcm-package-repository-py chart.

As this is adopted as a common deployment pattern in ADP, please check the [Log Shipper Dynamic sidecar application integration guide][docdlsad1]
for more information on the deployment settings.

For the complete list of Log Shipper's optional configuration parameters, visit the [Log Shipper Low Footprint Sidecar Developer's Guide][docdlsad2]

#### Deployment Steps

Add helm drop repository <https://arm.seli.gic.ericsson.se/artifactory/proj-mlops-released-helm/>
for installation.

```sh
helm repo add eric-lcm-package-repository-py-drop https://arm.seli.gic.ericsson.se/artifactory/proj-mlops-released-helm --username <SELI_ARTIFACTORY_REPO_USER> --password <SELI_ARTIFACTORY_REPO_TOKEN>
```

Install the `Python Package Repository` Service Service on the Kubernetes cluster by using the helm
installation command:

```sh
helm install <CHART_REFERENCE> --name <RELEASE_NAME> --namespace <NAMESPACE> [--set <other_parameters>]
```

The variables specified in the command are as follows:

- `<CHART_REFERENCE>`: Path to a packaged chart, path to an unpacked
  chart directory or a URL.
- `<RELEASE_NAME>`: String value, a name to identify and manage your helm chart.
- `<NAMESPACE>`: String value, a namespace to be used by the user for
  deploying own helm charts.
- `<VERSION>` : String value, the version of service chart.

> **_Note:_** `Python Package Repository` Service docker images are stored in "armdocker.rnd.ericsson.se"
docker registry and it is protected with authorization. Hence, a Kubernetes secret
to access the docker registry should be created and refer it in _global.pullSecret_.

```sh
kubectl create secret docker-registry armdocker-creds --docker-server armdocker.rnd.ericsson.se --docker-username "<username>" --docker-password "<password>" --namespace <NAMESPACE>
```

```sh
helm upgrade --install eric-lcm-package-repository-py <HELM_REPO_NAME>/eric-lcm-package-repository-py --version <VERSION> \
    --namespace <NAMESPACE> \
    --set global.pullSecret=<ARMDOCKER_SECRET> \
    --set ingress.ingressClass=<INGRESS_CLASS> \
    --set ingress.enabled=true \
    --set ingress.tls.enabled=false \
    --set ingress.hostname=<INGRESS_HOST_NAME> \
    --set global.security.tls.enabled=false \
    --timeout=5m  \
    --wait
```

The variables specified in the command are as follows:

- `<NAMESPACE>` : String value, a name to be used dedicated by the user for
  deploying own helm charts.
- `<ARMDOCKER_SECRET>` : String value, the secret name to access docker registry
  to pull `Python Package Repository` Service docker images.
- `<INGRESS_CLASS>` : String value, the ingress class.
- `<INGRESS_HOST_NAME>`: String value, the api end point to access
  `Python Package Repository` Service service.

Here is an example of the `helm install` command:

```sh
helm upgrade --install eric-lcm-package-repository-py eric-lcm-package-repository-py-drop/eric-lcm-package-repository-py --version 1.0.0-25 \
    --namespace lcm-pypiserver-ci \
    --set global.pullSecret=armdocker-creds \
	  --set global.serviceMesh.enabled=true \
    --set ingress.ingressClass="eric-tm-ingress-controller-cr" \
    --set ingress.enabled=true \
    --set ingress.hostname=eric-lcm-package-repo-py.hall033.rnd.gic.ericsson.se \
    --set global.security.tls.enabled=true \
	  --set ingress.tls.secretName=lcm-package-repository-py-tls \
	  --timeout=5m  \
    --wait    
```

#### Verify the Python Package Repository ServiceService Availability

To verify whether the deployment is successful, do as follows:

1. Check if the chart is installed with the provided release name and in related
   namespace by using the following command:

```sh
helm ls --namespace <namespace>
```

2.Verify the status of the deployed helm chart.

```sh
helm status <release_name> --namespace <namespace>
```

_Chart status should be reported as "DEPLOYED"._

3.Verify that the pods are running by getting the status for your pods.

```sh
kubectl get pods --namespace=<namespace>
```

All pods should be _Running_. All containers in should be reported as _Ready_.

```sh
helm ls --namespace example
helm status examplerelease --namespace example
kubectl get pods --namespace=example
```

### Configuration Parameters

#### Mandatory Configuration Parameters

There is no mandatory patameter

#### Optional Configuration Parameters

Following parameters are not mandatory. If not explicitly set (using the --set argument),
the default values provided in the helm chart are used.

| Variable Name                          | Description                                                                                     | Default Value                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------------| -------------------------------------------- |
| `labels`                                                        | Additional labels to be added to all resources in the cluster.                      | `{}`                             |
| `annotations`                                                   | Extra annotations to be added to all resources in the cluster.                      | `{}`                             |
| `fullnameOverride`                                    | Along with `nameOverride` allow to adjust how the resources part of the Helm chart are named. | `""`                             |
| `nameOverride`                                                  | Name of chart.                                                                      | `""`                             |
| `pypiserver.extraArgs`                  | Additional arguments (beside -P, -p, -a) to be passed to the underyling pypiserver image, refer [optional arguments](#optional-arguments) section                                                         | `["--disable-fallback", "--log-file=/log/pypiserver.log"]`                                 |
| `auth.actions`                  | Actions requiring authentication (comma separated list)                                                        | `''`                                 |
| `auth.credentials`                  | Map of username / encoded password to write in a htpasswd file, refer [create auth credentails](#create-auth-credentials) section                                                    | `{}`                                 |
| `imageCredentials.repopath`                 | Common repository path for all containers.                                                               | `""` |
| `imageCredentials.pullSecret`                 | Image registry pull secret.                                                               | `""` |
| `imageCredentials.registry.url`                            | Docker image repository. Overrides global Docker registry url and eric-product-info.yaml | `""`                             |
| `imageCredentials.registry.imagePullPolicy`                     | Docker image pull policy. Overrides global image pull policy                        | `""`                             |
| `imageCredentials.ericLcmPackageRepositoryPy.registry.url`                 | `Python Package Repository` registry url                                                           | `""` |
| `imageCredentials.ericLcmPackageRepositoryPy.registry.imagePullPolicy`                 | `Python Package Repository` registry image pull policy                                                           | `""` |
| `imageCredentials.ericLcmPackageRepositoryPy.registry.repoPath`                 | `Python Package Repository` registry repo path                                                           | `""` |
| `imageCredentials.pypiinit.enabled`                 | Enable PyPI Init                                                           | `false` |
| `imageCredentials.pypiinit.image.name`                 | Enable PyPI Init image name                                                         | `""` |
| `imageCredentials.pypiinit.image.tag`                 | Enable PyPI Init image tag                                                          | `""` |
| `imageCredentials.pypiinit.registry.url`                 | PyPI Init registry url                                                           | `""` |
| `imageCredentials.pypiinit.registry.imagePullPolicy`                 | PyPI Init image pull policy                                                           | `""` |
| `imageCredentials.pypiinit.registry.repoPath`                 | PyPI Init registry repo path                                                           | `""` |
| `ingress.enabled`                       | Enables external access to Python Package Repository                                                         | `false`                                 |
| `ingress.useHTTPProxy`                  | Deploys Ingress Controller CR HTTPProxy, if set to false used Ingress Object                   | `true`                                  |
| `ingress.annotations`                   | Additional Ingress Annotations to be set, based on the ingress class used                      | `"{}"`                                      |
| `ingress.ingressClass`                  | Ingress class name indicating which ingress controller instance is consuming the ingress resource | `""`                                    |
| `ingress.hostname`                      | The ingress host fully qualified domain name                                                   | `""`                                    |
| `ingress.tls.enabled`                   | Enables secured cluster-external traffic.                                                      | `false`                                 |
| `ingress.tls.secretName`                | Kubernetes secret where certificates are stored                                                | `""`                                 |                              |
| `ingress.tls.client.rootCaSecret`       | CA certificate to validate the upstream service                                                | `""`                                    |
| `ingress.tls.client.subjectName`        | Subject name for for the upstream service TLS                                                  | `""`                                    |
| `logShipper.logLevel`                  | log level of log shipper, when enabled.                                                         | `info`                                  |
| `logShipper.output.logTransformer.host`| Log Shipper, Log transformer host.                                                              |`eric-log-transformer`                  |
| `logShipper.storage.size`              | Size of the shared volume.                                                                      |`128Mi`                                 |
| `logShipper.input.files.enabled`       | Enable or disable input.                                                                        |`true`                                  |
| `logShipper.storage.path`              | Log files directory                                                                             | `/logs`                                   |
| `logShipper.input.files.paths`         | List of files to ship relative from `logShipper.storage.path`.                                  | `["pypiserver.log", "chp.log"]`                                       |
| `logShipper.storage.medium`            | Options avaliable: Memory or Ephemeral. For Memory, emptyDir volumes will be selected to setup tmpfs (RAM-backed filesystem), this will impact log producer memory dimensioning | `Memory`    |
| `persistence.persistentVolumeClaim.annotations`         | Annotations for the presistence                                                                | `{}`                   |
| `persistence.persistentVolumeClaim.storageClass`         | Persistence storage class                                                                | `null`                   |
| `persistence.persistentVolumeClaim.accessMode`           | Persistence access mode                                                                  | `ReadWriteOnce`         |
| `persistence.persistentVolumeClaim.size`                 | Persistence volume size                                                                  | `10Gi`                   |
| `persistence.mountPropagation`     | Mount propagation method                                                                 | `nil`                   |
| `nodeSelector.pypiserver`                     | Node selector of the deployment                                                          | `{}`                    |
| `nodeSelector.brAgent`                                          | Service-level parameter BR Agent.                                      | `{}`                             |
| `tolerations`                      | Tolerations configuration for the deployment                                             | `[]`                    |
| `affinity.podAntiAffinity`                         | Affinity of the deployment                                                               | `soft`                    |
| `affinity.topologyKey` |topologyKey is the key of node labels used by the scheduler to determine the domain for Pod placement| `kubernetes.io/hostname` |
| `podPriority.ericLcmPackageRepositoryPy.priorityClassName`                         | Priority class name for the service Pod                                                               | `""`                    |
| `podPriority.brAgent.priorityClassName`                         | PodPriority for Python Package Repository brAgent Pods.                                        | `""`                             |
| `securityPolicy.rolename`               | The attribute sets the name of the security policy role that is bound to the service account.               | `eric-lcm-package-repository-py-role`          |
| `probes.ericLcmPackageRepositoryPy.livenessProbe.initialDelaySeconds`                  | Initial delay, in seconds, for the liveness probe                                   | `10`                            |
| `probes.ericLcmPackageRepositoryPy.livenessProbe.periodSeconds`                        | Period, in seconds, for the liveness probe                                          | `10`                             |
| `probes.ericLcmPackageRepositoryPy.livenessProbe.failureThreshold`                     | Failure threshold for the liveness probe                                            | `3`                             |
| `probes.ericLcmPackageRepositoryPy.livenessProbe.timeoutSeconds`                       | Timeout, in seconds, for the liveness probe                                         | `1`                              |
| `probes.ericLcmPackageRepositoryPy.livenessProbe.successThreshold`                       | Success threshold for the liveness probe                                         | `1`                              |
| `probes.ericLcmPackageRepositoryPy.readinessProbe.initialDelaySeconds`                 | Initial delay, in seconds, for the readiness probe                                  | `10`                              |
| `probes.ericLcmPackageRepositoryPy.readinessProbe.periodSeconds`                       | Period, in seconds, for the readiness probe                                         | `5`                              |
| `probes.ericLcmPackageRepositoryPy.readinessProbe.failureThreshold`                    | Failure threshold for the readiness probe                                           | `3`                           |
| `probes.ericLcmPackageRepositoryPy.readinessProbe.timeoutSeconds`                      | Timeout, in seconds, for the readiness probe                                        | `1`                              |
| `probes.ericLcmPackageRepositoryPy.readinessProbe.successThreshold`                       | Success threshold for the readiness probe                                         | `1`                              |
| `probes.brAgent.startupProbe.initialDelaySeconds`                  | Initial delay, in seconds, for the startup probe                                   | `0`                            |
| `probes.brAgent.startupProbe.periodSeconds`                        | Period, in seconds, for the startup probe                                          | `5`                             |
| `probes.brAgent.startupProbe.failureThreshold`                     | Failure threshold for the startup probe                                            | `60`                             |
| `probes.brAgent.startupProbe.timeoutSeconds`                       | Timeout, in seconds, for the startup probe                                         | `5`                              |
| `probes.brAgent.startupProbe.successThreshold`                     | Success Threshold, in seconds, for the startup probe                                | `1`                              |
| `probes.brAgent.livenessProbe.initialDelaySeconds`                  | Initial delay, in seconds, for the liveness probe                                   | `0`                            |
| `probes.brAgent.livenessProbe.periodSeconds`                        | Period, in seconds, for the liveness probe                                          | `10`                             |
| `probes.brAgent.livenessProbe.failureThreshold`                     | Failure threshold for the liveness probe                                            | `5`                             |
| `probes.brAgent.livenessProbe.timeoutSeconds`                       | Timeout, in seconds, for the liveness probe                                         | `5`                              |
| `probes.brAgent.livenessProbe.successThreshold`                     | Success Threshold, in seconds, for the liveness probe                                | `1`                              |
| `probes.brAgent.readinessProbe.initialDelaySeconds`                  | Initial delay, in seconds, for the readiness probe                                   | `0`                            |
| `probes.brAgent.readinessProbe.periodSeconds`                        | Period, in seconds, for the readiness probe                                          | `10`                             |
| `probes.brAgent.readinessProbe.failureThreshold`                     | Failure threshold for the readiness probe                                            | `5`                             |
| `probes.brAgent.readinessProbe.timeoutSeconds`                       | Timeout, in seconds, for the readiness probe                                         | `5`                              |
| `probes.brAgent.readinessProbe.successThreshold`                     | Success Threshold, in seconds, for the readiness probe                               | `1`                              |

**ServiceMesh Configurations**,

| Variable Name                          | Description                                                                                     | Default Value                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------------| -------------------------------------------- |
| `serviceMesh.enabled`                  | Determines if service uses service mesh                                                         | `true`                                 |
| `serviceMesh.tls.enabled`              | Determines if service need to use the service mesh mTLS                                         | `false`                                |
| `serviceMesh.tls.mode`                 | Service mesh mTLS mode to be used by the service                                                | `ISTIO_MUTUAL`                              |
| `serviceMesh.gateway.serviceName`      | Mesh Ingress gateway service name                                                               | `""`                                   |
| `serviceMesh.gateway.port`         | HTTP port for ingress gateway                                                                   | `80`                                   |
| `serviceMesh.gateway.tls.enabled`         | Enables SM gateway tls support                                                                    | `false`                                   |
| `serviceMesh.gateway.tls.rootCaSecret`         | Root CA Cert used by SM gateway certificate                                                                   | ``                                   |
| `serviceMesh.gateway.tls.subjectName`         | CN Name used by SM gateway certificate                                                                   | ``                                   |
| `serviceMesh.ingress.enabled`          | Determines if SM ingress is enabled                                                             | `true`                                 |
| `serviceMesh.ingress.gwName`           | The Gateway resource name to be used in the VirtualService resource                             | `""`                                   |
| `serviceMesh.ingress.host`             | The host name to be used in the VirtualService resource                                         | `"*"`                                  |
| `serviceMesh.ingress.matchPrefix`      | The Match prefix for service routing                                                            | `"/"`                                     |
| `serviceMesh.egress.enabled`          | Determines if SM egress is enabled                                                             | `false`                                 |
| `serviceMesh.egress.ca.genSecretName`  | Secret name for egress CA to be used                                                            | `eric-sec-sip-tls-trusted-root-cert`         |
| `serviceMesh.egress.ca.caCertsPath`    | Path the egress CA is mounted on istio-side car                                                 | `/etc/istio/egress-ca-certs/`                |
| `serviceMesh.egress.ericlcmpackagerepositorypy.enabled`          | Determines if DR egress is enabled                                                             | `false`                                 |
| `serviceMesh.settingsVS.enabled`      | Enable Retry settings for VirtualService                                                            | `"true"`                                     |
| `global.serviceMesh.annotations`                                        | Service Mesh related annotations for deployments, job and pod.   | `""`                                       |
| `serviceMesh.settingsVS.retries.attempts`      | Number of retries  for VirtualService                                                            | `3`                                     |
| `serviceMesh.settingsVS.retries.perTryTimeout`      | Per try timeout for VirtualService                                                            | `2s`                                     |
| `serviceMesh.settingsVS.retries.retryOn`      | Retry on settings for VirtualService                                                            | `["connect-failure","refused-stream","5xx","retriable-4xx"]`                                     |
| `serviceMesh.settingsVS.overallTimeout`      | Overall Timeout settings for VirtualService                                                            | `10s`                                     |

Following parameters are not mandatory. If not explicitly set (using the --set argument),
the default values provided in the helm chart are used.

**Global Parameters**,

| Variable Name                                                           | Description                                                      | Default Value                              |
| ----------------------------------------------------------------------- | -----------------------------------------------------------------| -------------------------------------------|
| `global.timezone`                                                       | The time zone used in the servers                                | `UTC`                                      |
| `global.registry.url`                                                   | Global Docker registry url                                       | `armdocker.rnd.ericsson.se`                |
| `global.registry.pullPolicy`                                            | Global Image Pull Policy                                         | `IfNotPresent`                             |
| `global.pullSecret`                                                     | Global Image Pull Secret                                         | `""`                                       |
| `global.adpBR.broServiceName`                                           | The name of the Backup and Restore Orchestrator Service.         | `eric-ctrl-bro`                            |
| `global.adpBR.broGrpcServicePort`                                       | The port which exposes the GRPC interface of Backup and Restore Orchestrator.| `3000`                                     |
| `global.adpBR.brLabelKey`                                               | The label key which appended to the list of labels in brAgent pod. | `adpbrlabelkey`                                       |
| `global.fsGroup.manual`                                                 | Sets an fsGroup ID for all services                              | `""`                                       |
| `global.fsGroup.namespace`                                              | Sets an fsGroup to use namespace default                         | `""`                                       |
| `global.networkPolicy.enabled`                                          | Enable creation of NetworkPolicy resources                       | `false`                                    |
| `global.security.policyBinding.create`                                  | Create the Pod Security Policy (PSP) RoleBinding                 | `true`                                     |
| `global.security.policyReferenceMap.default-restricted-security-policy` | Map for changing default restricted security policy              | `default-restricted-security-policy`       |
| `global.security.tls.enabled`                                           | Enable mTLS communication for other services communication       | `true`                                     |
| `global.securityPolicy.roleKind`                                        | Configuration of the security policy role kind                   | `""`                                       |
| `global.podSecurityContext.supplementalGroups`  | SupplementalGroups (list) in the pod's securityContext. This will be appended to the service level parameter.   | `null`              |
| `global.serviceMesh.enabled`                                            | Enable service mesh integration                                  | `false`                                    |
| `global.serviceMesh.annotations`                                        | Service Mesh related annotations for deployments, job and pod.   | `""`                                       |


**Hardening Configurations**,

| Variable Name                                                   | Description                                                                          | Default Value                     |
| --------------------------------------------------------------- | -------------------------------------------------------------------------------------| --------------------------------- |
| `appArmorProfile.type`  | AppArmor type for all containers ("unconfined", "runtime/default", "localhost", ""). Setting applies only when container specific parameter omitted.  | `""`     |
| `appArmorProfile.localhostProfile`            | Localhost profile name for all containers if type is localhost. Setting applies only when container specific parameter omitted. | `""`     |
| `seccompProfile.type`  | Seccomp type for all containers ("Unconfined", "RuntimeDefault", "Localhost", ""). Setting applies only when container specific parameter omitted.| `""`          |
| `seccompProfile.localhostProfile`        | Localhost profile name for all containers if type is Localhost. Setting applies only when container specific parameter omitted. | `""`          |
| `networkPolicy.enabled`                                         | Service level control. Impacts only when `global.networkPolicy.enabled` is `true`.   | `true` 


**Update Stratergy Configurations**,

| Variable Name                                                   | Description                                                              | Default Value                              |
| --------------------------------------------------------------- | -------------------------------------------------------------------------| ------------------------------------------ |
| `updateStrategy.type`                                       | Update Strategy used Python Package Repository pod                                      | `RollingUpdate`                                 |
| `updateStrategy.rollingUpdate.maxUnavailable`                                     | The amount (number or percentage) of pods that can be unavailable during the update process.                         | "25%"                                 |
| `updateStrategy.rollingUpdate.maxSurge`                            | The amount (number or percentage) of pods that can be created above the desired amount of pods during an update.                                    | `"25%"`                                       |
| `updateStrategy.brAgent.type`                                     | Update Strategy used for BRAgent Pod                                   | `RollingUpdate`                                 |
| `updateStrategy.brAgent.rollingUpdate`                            | Update Strategy used BRAgent Pod                                     | `""`                                       |


**Resource configurations**,

| Variable Name                                                   | Description                                                              | Default Value                              |
| --------------------------------------------------------------- | -------------------------------------------------------------------------| ------------------------------------------ |
| `resources.ericLcmPackageRepositoryPy.requests.memory`                                 | To specify a memory request for Python Package Repository container                            | `512Mi`                                    |
| `resources.ericLcmPackageRepositoryPy.requests.cpu`                                    | To specify a CPU request for Python Package Repository container                               | `1000m`                                      |
| `resources.ericLcmPackageRepositoryPy.requests.ephemeral-storage`                      | To specify an ephemeral storage request for Python Package Repository container                | ``                                     |
| `resources.ericLcmPackageRepositoryPy.limits.memory`                                   | To specify a memory limit for Python Package Repository container                              | `2Gi`                                      |
| `resources.ericLcmPackageRepositoryPy.limits.cpu`                                      | To specify a CPU limit for Python Package Repository container                                 | `2000m`                                     |
| `resources.ericLcmPackageRepositoryPy.limits.ephemeral-storage`                        | To specify an ephemeral storage limit for Python Package Repository container                  | `250Mi`                                    |
| `resources.init-load-packages.requests.memory`                                 | To specify a memory request for init package loader                            | `256Mi`                                    |
| `resources.init-load-packages.requests.cpu`                                    | To specify a CPU request for init package loader                               | `100m`                                      |
| `resources.init-load-packages.requests.ephemeral-storage`                      | To specify an ephemeral storage request for init package loader                | ``                                     |
| `resources.init-load-packages.limits.memory`                                   | To specify a memory limit for init package loader                              | `512Mi`                                      |
| `resources.init-load-packages.limits.cpu`                                      | To specify a CPU limit for init package loader                                 | `200m`                                     |
| `resources.init-load-packages.limits.ephemeral-storage`                        | To specify an ephemeral storage limit for init package loader                  | `250Mi`                                    |
| `resources.logshipper.requests.memory`                          | To specify a memory request for logshipper container                     | `25Mi`                                     |
| `resources.logshipper.requests.cpu`                             | To specify a CPU request for logshipper container                        | `25m`                                      |
| `resources.logshipper.requests.ephemeral-storage`               | To specify an ephemeral storage request for logshipper container         | `""`                                       |
| `resources.logshipper.limits.memory`                            | To specify a memory limit for logshipper container                       | `50Mi`                                     |
| `resources.logshipper.limits.cpu`                               | To specify a CPU limit for logshipper container                          | `40m`                                      |
| `resources.logshipper.limits.ephemeral-storage`                 | To specify an ephemeral storage limit for logshipper container           | `""`                                       |
| `resources.brAgent.requests.memory`                             | To specify a memory request for -brAgent container                            | `128Mi`                                    |
| `resources.brAgent.requests.cpu`                                | To specify a CPU request for brAgent container                               | `300m`                                      |
| `resources.brAgent.requests.ephemeral-storage`                  | To specify an ephemeral storage request for brAgent container                | `10Gi`                                     |
| `resources.brAgent.limits.memory`                               | To specify a memory limit for brAgent container                              | `1280Mi`                                      |
| `resources.brAgent.limits.cpu`                                  | To specify a CPU limit for brAgent container                                 | `1500m`                                     |
| `resources.brAgent.limits.ephemeral-storage`                    | To specify an ephemeral storage limit for brAgent container                  | `20Gi`                                    |
| `resources.brAgent.jvm.initialMemoryAllocationPercentage`       | To specify a JVM initialMemoryAllocationPercentage for brAgent container     | `1280Mi`                                      |
| `resources.brAgent.jvm.smallMemoryAllocationMaxPercentage`      | To specify JVM smallMemoryAllocationMaxPercentage for brAgent container      | `1500m`                                     |
| `resources.brAgent.jvm.largeMemoryAllocationMaxPercentage`      | To specify JVM largeMemoryAllocationMaxPercentage for brAgent container      | `20Gi`                                    |

**Parameters for Backup Restore Agent**,

| Variable Name                          | Description                                                                             | Default Value                                           |
| -------------------------------------- | ----------------------------------------------------------------------------------------| ------------------------------------------------------- |
| `brAgent.enabled`                       | Enable or disable PG Backup Restore Agent.                                             |                 `false`                       |
| `brAgent.logLevel`                      | Log level for PG Backup and restore Agent.                                             |                 `info`                        |
| `brAgent.backupTypeList`                 | A list that specifies the supported backup type(s) in backup and restore agent. Not specifying any value implies that the scope of this BRA will be a logical "DEFAULT" scope which is defined by BRO. | `[]`                                         |
| `brAgent.brLabelValue`                        | The label value which appended to the list of labels in brAgent pod.             | `HubBRAgent`                                           |
| `brAgent.restPort`                        | Port of BRAgent                                                                      | `8081`                                       |

### Create Auth Credentials
To create the auth credentials , user the htpasswd util to generate http password by using command  
```
htpasswd -Bbn <username> <password>
```
Copy the username and password printed in the console and use it to set the Auth Credentials. 

### optional arguments:

```
  -v, --verbose         Enable verbose logging; repeat for more verbosity.

  --disable-fallback    Disable the default redirect to PyPI for packages not
                        found in the local index.

  --fallback-url FALLBACK_URL
                        Redirect to FALLBACK_URL for packages not found in the
                        local index.

  --health-endpoint HEALTH_ENDPOINT
                        Configure a custom liveness endpoint. It always
                        returns 200 Ok if the service is up. Otherwise, it
                        means that the service is not responsive.

  -o, --overwrite       Allow overwriting existing package files during
                        upload.

  --log-req-frmt FORMAT
                        A format-string selecting Http-Request properties to
                        log; set to '%s' to see them all.

  --log-res-frmt FORMAT
                        A format-string selecting Http-Response properties to
                        log; set to '%s' to see them all.

  --log-err-frmt FORMAT
                        A format-string selecting Http-Error properties to
                        log; set to '%s' to see them all.

```


## Client-Side Configurations

### Configuring pip

For **pip** command this can be done by setting the environment variable
**[PIP_EXTRA_INDEX_URL]** in your **.bashr/.profile/.zshrc**

```shell
export PIP_EXTRA_INDEX_URL=http://localhost:8080
```

or by adding the following lines to **~/.pip/pip.conf**

```shell
[global]
extra-index-url = http://localhost:8080
```
### Uploading Packages

#### Upload with setuptools

1. On client-side, edit or create a **~/.pypirc** file with a similar content:

```shell
     [distutils]
     index-servers =
       pypi
       local

     [pypi]
     username:<your_pypi_username>
     password:<your_pypi_passwd>

     [local]
     repository: http://localhost:8080
     username: <some_username>
     password: <some_passwd>
```

2. Then from within the directory of the python-project you wish to upload,
   issue this command:

```shell
     python setup.py sdist upload -r local
```

#### Upload with twine

```shell
  twine upload -r local dist
```