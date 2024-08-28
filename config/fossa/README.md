# FOSS EDITS

## dependencies.packager.yaml

### aws-sdk-go-v2

Some entries of aws-sdk-go-v2 do not have license detected. These have license in bazaar and mimer as Apache-2
Manually updated 

```yaml
    licenses: []
```
   
To

```yaml
licenses:
    - Apache-2.0
```

### removed dependency entries

Following IDs have been removed manually from dependencies.packager.yaml

1. `ID: github.com/acomagu/bufpipe+1.0.3`
   Does not have license. Recommendation is to use code from master, however unclear if we need OSCT approval to upgrade dependency version
   JIRA ticket has been raised with OSCT for guidance.

    ```yaml
    - ID: github.com/acomagu/bufpipe+1.0.3
    additional_info:
        fossa-attribution:
        Description: The fossa information is fetched from  FOSSA service. Don't Edit!
        Package: github.com/acomagu/bufpipe
        Source: git
        Version: 1.0.3
        Hash: dac7fac8e4fdc02e3f37673df5755dc1649d1169
        licenses: []
        Title: bufpipe
        DownloadURL: https://github.com/acomagu/bufpipe/archive/v1.0.3.zip
    bazaar:
        register: CTR-907342
        prim: ''
        community_link: https://github.com/acomagu/bufpipe
        community_name: https://github.com/acomagu/bufpipe
        community_url: https://github.com/acomagu/bufpipe
        component_comment: ''
        component_highlevel_description: ''
        component_name: bufpipe
        component_platform: linux
        component_programing_language: ''
        component_version: 1.0.3
        licenses: []
        src_download_link: https://github.com/acomagu/bufpipe/archive/v1.0.3.zip
        stako_decision_reason: automatic
        stako: DO_NOT_EDIT_MANUALLY
        stako_comment: ''
        bazaarurl: ''
        recode: ''
        retext: ''
        country: ''
    encryptions:
        used:
        - ''
    evms:
        register: 'yes'
        product_name: github.com/acomagu/bufpipe
        target_sw: linux
        vendor: git
        version: 1.0.3
        web_url: https://github.com/acomagu/bufpipe
    licenses: []
    name: bufpipe
    primary:
    - this
    subcomponent: false
    type: FOSS
    versions:
    - 1.0.3
    - dac7fac8e4fdc02e3f37673df5755dc1649d1169
    mimer:
        linking: Static
        product_number: ''
        product_version_label: 1.0.3
        selected_licenses: []
        obligation: Including the full license text in a prominent place with the software
        when the FOSS is distributed
        usage: Use as is
        primary: 'True'
    ```

2. `ID: github.com/GoogleContainerTools/kaniko+cf9a334cb027e6bc6a35c94a3b120b34880750a9`
   Fossa scan is adding kaniko@latest back as dependency of kaniko. Each time with a different COMMIT-SHA
   Eg: github.com/GoogleContainerTools/kaniko+cf9a334cb027e6bc6a35c94a3b120b34880750a9

3. While generating license agreement got errors due to below
    a) Apache license missing in fossa json for below items, added it manually
        ```text
            "title": "aws-sdk-go-v2",
            "version": "service/backup/v1.14.0"```
            "title": "aws-sdk-go-v2",
            "version": "feature/cloudfront/sign/v1.3.13"```

    b) SunPro license mapping does not exist in adp-release-auto, for purpose of license generation removed SunPro from dependency file
