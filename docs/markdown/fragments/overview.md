## Overview

This document provides an overview of the `Python Package Repository` Service. It gives a brief description of its main features and its functionalities. Python `Python Package Repository`, based on pypiserver provides hosting, distribution, and management of Python packages. It helps the organizations or individuals who want to manage and distribute Python packages internally, ensuring that only authorized users can access and download the packages.

The  `Python Package Repository` service is based on docker distribution.

### Features

### Architecture

The following picture shows the Container Registry Service and its architectural context.

![Architecture](pypi-server-architecture-design.png)

The `Python Package Repository` server serves as an abstraction layer between Python package management tools (pip/twine/poetry) and the storage backends:

Package management tools communicate with pywharf server, following [PEP 503 -- Simple Repository API](https://www.python.org/dev/peps/pep-0503/) for searching/downloading package, and Legacy API for uploading package.
`Python Package Repository` server then performs file search/download/upload operations with some specific storage backend.

### Deployment View
`Python Package Repository` is packaged as a Docker container. It supports deployment in Kubernetes using Helm. By default, `Python Package Repository` uses PVC as low footprint deployment.

![Deployment diagram](pypi-server.png)

#### Performance Efficiency

Performance testing conducted on the Python Package Repository to assess its time behavior, capacity and resource utilization under various conditions.

The Performance test was run in the following test environment:

| Cluster Configuration                            | Details            |
| ------------------------------------------------ | ------------------ |
| Kubernetes Version                               | 1.29.1             |
| Number of Masters                                | 3                  |
| Number of Workers                                | 8                  |
| Memory per Node                                  | 64                 |
| CPU per Node                                     | 16                 |

Python wheel packages without any dependencies of various sizes like 100MB, 500MB and 850MB are considered as testdata.

Testing Tools used:

| Tools | Version | Details                                                      |
|-------|---------|--------------------------------------------------------------|
| Twine | 3.1.1   | Twine for package upload to python package repository.       |
| pip   | 22.0.2  | Pip for package installation from python package repository. |

##### Time Behavior

The time taken by the Python package repository to respond to requests, including package uploads and installations.

| Pod                              | Container                      | Request type | packages | Time Taken | ~ CPU (cores) | ~ MEMORY(Mi) |
|----------------------------------|--------------------------------|--------------|----------|------------|---------------|--------------|
| eric-lcm-package-repository-py-0 | eric-lcm-package-repository-py | Upload       | ~100MB   | 4s         | 146m          | 38Mi         |
|                                  |                                | Upload       | ~500MB   | 9s         | 486m          | 61Mi         |
|                                  |                                | Upload       | ~850MB   | 15s        | 760m          | 71Mi         |
|                                  |                                | Install      | ~100MB   | 4s         | 38m           | 151Mi        |
|                                  |                                | Install      | ~500MB   | 7s         | 141m          | 547Mi        |
|                                  |                                | Install      | ~850MB   | 13s        | 282m          | 888Mi        |

##### Capacity

Measuring the capacity of the Python Package Repository. 

This includes testing with increasing numbers of concurrent users or requests to determine at what point the system starts to exhibit issues.

Same package of 850MB size at different concurrency level:

| Pod                              | Container                      | Concurrency | Time Taken | ~CPU (Millicores) | ~MEMORY (Mib) |
|----------------------------------|--------------------------------|-------------|------------|-------------------|---------------|
| eric-lcm-package-repository-py-0 | eric-lcm-package-repository-py | 5           | 22         | 898m              | 898Mi         |
|                                  |                                | 6           | 23         | 1133m             | 907Mi         |
|                                  |                                | 7           | 27         | 1221m             | 907Mi         |

Different package of 850MB size at different concurrency level:

| Pod                              | Container                      | Concurrency | Time Taken | ~CPU (Millicores) | ~MEMORY (Mib) |
|----------------------------------|--------------------------------|-------------|------------|-------------------|---------------|
| eric-lcm-package-repository-py-0 | eric-lcm-package-repository-py | 3           | 14         | 1130m             | 578Mi         |
|                                  |                                | 4           | 15         | 1277m             | 587Mi         |


