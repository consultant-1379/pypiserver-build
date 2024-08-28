## Troubleshooting

This section describes the troubleshooting functions and procedures for the Python Package Repository. It provides the following information:

- Simple verification and possible recovery.

- The required information when reporting a bug or writing a support case, including all files and system logs that are needed.

- How to retrieve the above information from the system.

### Prerequisites

- kubectl CLI tool properly configured
- helm CLI tool properly configured

### Installation

In case of problems at installation, inspect the helm release:

```sh
helm get <release name> --namespace=<namespace>
helm status <release name> --namespace=<namespace>
```

Delete the helm release, and try again:

```sh
helm uninstall <release name> --namespace=<namespace>
```

### Health checks

Services can be listed by issuing the command:

```sh
kubectl get service --namespace=<namespace>
```

### Enable debug logging

Log Level can be set in the values file during installation for the Python Package Repository Service by setting the pypiserver.extraArgs arguments with --verbase refer [optional arguments](#optional-arguments) section

```yaml
   -v, --verbose         Enable verbose logging; repeat for more verbosity.
   
   pypiserver:
    extraArgs:
      - --verbose
      - --verbose
      - --verbose
      - --disable-fallback
      - --log-file=/log/pypiserver.log

```


### Data Collection

> **_Note:_** The below commands are not applicable, if logshipper is integrated with Python Package Repository service without enabling stdout log output

The detailed information about the pod are collected using command:

```sh
kubectl describe pod <python package repository pod> --namespace=<namespace>
kubectl logs <python package repository pod> -c eric-lcm-package-repository-py --namespace=<namespace>

```

### Bug Reporting and Additional Support

Issues can be handled in different ways, as listed below:

For questions, support or hot requesting, see Additional Support.

For reporting of faults, see Bug Reporting.

#### Additional Support
If there are Python Package Repository Service support issues, use the JIRA in [Additional Support](https://eteamproject.internal.ericsson.com/projects/MXESUP)

#### Bug Reporting
If there is a suspected fault, report a bug. The bug report must contain specific Python Package Repository Service information and all applicable troubleshooting information highlighted in the [Troubleshooting section](#troubleshooting).

Indicate if the suspected fault can be resolved by restarting the pod.

When reporting a bug for the Python Package Repository Service open [JIRA Support](https://eteamproject.internal.ericsson.com/projects/MXESUP), specify the following in the JIRA issue:

Make sure you fill in these fields properly:

**Project**: mxe-support (MXESUP)  
**Issue type**: Bug  
**Component/s**: Python Package Repository  
**Affects Version/s**: version of Python Package Repository
**Linked Issue**: if you know any previous related issue, or if you submit multiple related issues, it's appreciated if you fill this in.  

------------------------------  
Welcome to ADP Domain Services!  
For Jira case registration please use the below template. This will help to get a quicker resolution.  
Minimum logs to include when applicable are either collected by:  
1) Diagnostic Data Collector (DDC) with required configuration to collect needed content, see https://eteamspace.internal.ericsson.com/pages/viewpage.action?pageId=1007108986  
2) collect_ADP_Logs.sh found at https://eteamspace.internal.ericsson.com/display/ACD/Tools  
   Does the problem persist (Y/N):  
   Reproducible (Y/N):  
   How to reproduce the problem:  
   Detailed Description:  
   • What is happening?  
   • What did you expect to happen?  
   • What have you tried?  
   • What do YOU think is the issue (optional)?  
   • Anything else that is worth being noted (optional)?  
   Screenshots are welcome if it's GUI related (optional)  
   Any config, e.g., Helm config or config extract (optional)  
--------------------------------  

### Known Issues
