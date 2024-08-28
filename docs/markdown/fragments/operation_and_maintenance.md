## Operation and Maintenance

### Performance Management

### Backup and Restore

The Backup and Restore needs to be managed by admins running the Python Package Repository deployment.

#### Backup of Python Package Repository

The Backup and Restore function is managed by Backup and Restore Orchestrator Service. It can be triggered through the REST API provided by Backup and Restore Orchestrator.

For the details about how to deploy Backup and Restore Orchestrator, refer to the latest [Deployment Guide of Backup and Restore Orchestrator][docbrodep].

For the details about how to perform Backup and Restore operations, refer to the latest [Operation Guide of Backup and Restore Orchestrator][docbroop].

Python Package Repository service uses PVC for storing the python packages and this PVC will be backedup, restored and deleted by the BRO service upon request using the relevent BRO REST API calls.

##### Prepare Backup and Restore Environment.

- Set environment variable for BRO Server Host and Port. Please refer [Backup and Restore Orchestrator Service User Guide][docbroug] for more information.

```sh
export BROSERVICE=<bro-service-name>:<bro-rest-port>
```
- Data encryption in transit (mTLS) is enabled by default and so execute the following to fetch the relevant certificates. **_Note:_** If Data encryption in transit (mTLS) is disabled, then ignore the following steps.

```sh
export NAMESPACE=<NAMESPACE>

kubectl -n "${NAMESPACE}" get secret eric-sec-sip-tls-trusted-root-cert -o json | jq -r '.data."cacertbundle.pem"' | base64 -d > cacertbundle.pem

kubectl -n "${NAMESPACE}" get eric-lcm-package-repository-py-bro-client-cert -o json | jq -r '.data."bra-cert.pem"' | base64 -d > clientcert.pem

kubectl -n "${NAMESPACE}" get eric-lcm-package-repository-py-bro-client-cert -o json | jq -r '.data."bra-privkey.pem"' | base64 -d > clientprivkey.pem
```

##### Create a Backup

This example triggering a backup on the DEFAULT Backup Manager.
> **_Note:_** If Data encryption in transit (mTLS) is disabled, then ignore the flags "–cacert", "–key", "–cert" in the command and keep "http" in the url.

```sh
 curl -i -X POST \
       -H "Content-Type:application/json" \
       -d \
    '{
      "action": "CREATE_BACKUP",
      "payload": {
        "backupName": "myBackup"
      }
    }' \
     'https://$BROSERVICE/v1/backup-manager/DEFAULT/action' \
     --cacert <path>/cacertbundle.pem \
     --key <path>/clientprivkey.pem \
     --cert <path>/clientcert.pem
```
This will generate action id as per the sample response:
```
    HTTP/1.1 201
    Content-Type: application/json;charset=UTF-8

    {"id":"28997"}
```
A Backup called "myBackup" will be created. The id of the action is "28997". As the action is executed, a Backup called myBackup will be created, and can be accessed by 
```sh
 curl -i https://$BROSERVICE/v1/backup-manager/DEFAULT/backup/myBackup --cacert <path>/cacertbundle.pem --key <path>/clientprivkey.pem --cert <path>/clientcert.pem
```

##### Restore a Backup

This example is triggering the restore of backup myBackup, that belongs to the DEFAULT Backup Manager.
> **_Note:_** If Data encryption in transit (mTLS) is disabled, then ignore the flags "–cacert", "–key", "–cert" in the command and keep "http" in the url.

```sh
curl -i -X POST \
       -H "Content-Type:application/json" \
       -d \
    '{
      "action": "RESTORE",
      "payload": {
        "backupName": "myBackup"
      }
    }' 
 'https://$BROSERVICE/v1/backup-manager/DEFAULT/action' \
     --cacert <path>/cacertbundle.pem \
     --key <path>/clientprivkey.pem \
     --cert <path>/clientcert.pem
```
This will generate action id as per the sample response:
```
    HTTP/1.1 201
    Content-Type: application/json;charset=UTF-8

    {"id":"18109"}
```
The id of the action is "18109". The BRO will trigger a restore on all agents associated with that backup. When all agents download all necessary fragments and perform their own restores, the action will be completed.

##### Delete a Backup

This example is triggering the deletion of backup myBackup, that belongs to the DEFAULT Backup Manager.
> **_Note:_** If Data encryption in transit (mTLS) is disabled, then ignore the flags "–cacert", "–key", "–cert" in the command and keep "http" in the url.

```sh
curl -i -X POST \
       -H "Content-Type:application/json" \
       -d \
    '{
      "action": "DELETE_BACKUP",
      "payload": {
        "backupName": "myBackup"
      }
    }' \
     'https://$BROSERVICE/v1/backup-manager/DEFAULT/action' \
     --cacert <path>/cacertbundle.pem \
     --key <path>/clientprivkey.pem \
     --cert <path>/clientcert.pem
```
This will generate action id as per the sample response:
```
    HTTP/1.1 201
    Content-Type: application/json;charset=UTF-8

    {"id":"63185"}
```
The id of the action is "63185". As the action is executed, the backup will be deleted from the BRO and will no longer be available to be used for a restore or any other action. All of the backup’s data will be deleted from the BRO storage.

Track completion of the above actions by using the action id generated in the previous step. The response must have result as SUCCESS.

```sh
curl -i https://$BROSERVICE/v1/backup-manager/DEFAULT/action/<action-id> --cacert <path>/cacertbundle.pem --key <path>/clientprivkey.pem --cert <path>/clientcert.pem

```
[docbrodep]: https://adp.ericsson.se/marketplace/backup-and-restore-orchestrator/documentation/development/dpi/service-user-guide#deployment
[docbroop]: https://adp.ericsson.se/marketplace/backup-and-restore-orchestrator/documentation/development/additional-documents/operations-guide
[docbroug]: https://adp.ericsson.se/marketplace/backup-and-restore-orchestrator/documentation/development/dpi/service-user-guide