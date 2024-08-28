## Verify logs in Search engine

1. Exec into any one of the search engine master pods

```sh
❯ kubectl get pods -n lcm-pypiserver-local | grep search-engine-master
eric-data-search-engine-master-1                                  1/1     Running     0              90m
eric-data-search-engine-master-0                                  1/1     Running     0              90m
eric-data-search-engine-master-2                                  1/1     Running     0              90m
```


2. Find all indices

```sh

bash-4.4$ esRest GET /_cat/indices?v
health status index                   uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   adp-app-logs-2023.11.16 a-VYKvwFSbmOps5Fzxv8qQ   5   1       3245            0      4.3mb          2.1mb
bash-4.4$
```

3. Search for shipped logs using Index name and Pod Name

```sh
POD_NAME=eric-lcm-package-repository-py-0
INDEX_NAME=adp-app-logs-2023.11.16

bash-4.4$ esRest GET /$INDEX_NAME/_search?pretty --data '{"query":{"bool":{"must":[{"match":{"metadata.pod_name":"'$POD_NAME'"}}]}}}'
{
  "took" : 1116,
  "timed_out" : false,
  "_shards" : {
    "total" : 5,
    "successful" : 5,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 3331,
      "relation" : "eq"
    },
    "max_score" : 0.004832864,
    "hits" : [
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "Q5Ct1osB79leRMdtDIoy",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "[filter:multiline:multiline.1] created emitter: emitter_for_multiline.1",
          "timestamp" : "2023-11-16T05:48:59.720+00:00",
          "version" : "1.1.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "container_name" : "logshipper",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:49:02.421685Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/logshipper.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "TJCt1osB79leRMdtHYpz",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "Server 'auto' selected. Expecting bottle to run 'Waitress'. Passing extra keyword args: {}",
          "timestamp" : "2023-11-16T05:49:01.786+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:49:05.515739Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "TpCt1osB79leRMdtHYpz",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "Listening on http://0.0.0.0:8080/",
          "timestamp" : "2023-11-16T05:49:01.786+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:49:05.515785Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "mpCu1osB79leRMdtz4oy",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "<LocalRequest: GET http://192.168.238.130:8080/>",
          "timestamp" : "2023-11-16T05:51:01.784+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:51:02.338912Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "m5Cu1osB79leRMdtz4oy",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "200 OK",
          "timestamp" : "2023-11-16T05:51:01.785+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:51:02.338946Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "qJCv1osB79leRMdtOIqv",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "<LocalRequest: GET http://192.168.238.130:8080/>",
          "timestamp" : "2023-11-16T05:51:26.785+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:51:29.345881Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "qpCv1osB79leRMdtOIqv",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "200 OK",
          "timestamp" : "2023-11-16T05:51:26.786+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:51:29.345950Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "rJCv1osB79leRMdtRIpk",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "<LocalRequest: GET http://192.168.238.130:8080/>",
          "timestamp" : "2023-11-16T05:51:31.785+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:51:32.339368Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "rZCv1osB79leRMdtRIpk",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "200 OK",
          "timestamp" : "2023-11-16T05:51:31.786+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:51:32.339380Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      },
      {
        "_index" : "adp-app-logs-2023.11.16",
        "_type" : "_doc",
        "_id" : "i5Cu1osB79leRMdtcYp9",
        "_score" : 0.004832864,
        "_source" : {
          "@version" : "1",
          "message" : "<LocalRequest: GET http://192.168.238.130:8080/>",
          "timestamp" : "2023-11-16T05:50:36.785+00:00",
          "version" : "1.2.0",
          "metadata" : {
            "node_name" : "node-10-120-8-109",
            "namespace" : "lcm-pypiserver-local",
            "pod_uid" : "49bd2802-e411-4d7b-bb2e-90fefd05091b",
            "pod_name" : "eric-lcm-package-repository-py-0"
          },
          "@timestamp" : "2023-11-16T05:50:38.345563Z",
          "logplane" : "adp-app-logs",
          "service_id" : "eric-lcm-package-repository-py-release",
          "severity" : "info",
          "extra_data" : {
            "fluentbit" : {
              "filename" : "/logs/pypiserver.log"
            }
          }
        }
      }
    ]
  }
}
      ....
```