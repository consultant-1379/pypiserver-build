*** Settings ***
Documentation    Functional completeness testcases for pypi server microservice
Library    Process
Library    OperatingSystem
Library    Collections
Library    String
Variables    variables/pypi_repository_details.py
Variables    variables/functional_completeness/pypi.py
Resource    keywords/pypi_keywords.robot

Suite Setup     Run Keywords    enable access to pypi repository    test_dir=${test_dir}     repository_hostname=${repository_hostname}    repository_url=${repository_url}    username=${username}    password=${password}
...    AND    upload python package to pypi repository    repository_url=${repository_url}    package=${sample_package_4_wheel}
Suite Teardown    Run Keywords    uninstall python package    package_name=${sample_package_4_name}
...    AND    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_4_name}    package_version=${sample_package_4_version}    username=${username}    password=${password}

*** Variables ***

*** Test Cases ***
install python package from pypi repository
    [Documentation]    Upload the python package to pypi repository
    ...                install uploaded python package from pypi repository
    ...                uninstall the python package
    [Tags]    tc1    test-dev    test-weekly    ericsson-mlops
    [Teardown]    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_1_name}    package_version=${sample_package_1_version_1}    username=${username}    password=${password}
    upload python package to pypi repository    repository_url=${repository_url}    package=${sample_package_1_wheel_version_1}
    install python package    repository_url=${repository_url}    package_name=${sample_package_1_name}
    uninstall python package    package_name=${sample_package_1_name}

upgrade python package from pypi repository
    [Documentation]    Upload the python packages of different versions to pypi repository
    ...                install the uploaded python package from pypi repository
    ...                upgrade it to latest version of python package from pypi repository
    ...                uninstall the python package
    [Tags]    tc2    test-dev    test-weekly
    [Teardown]  Run Keywords    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_1_name}    package_version=${sample_package_1_version_1}    username=${username}    password=${password}
    ...    AND    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_1_name}    package_version=${sample_package_1_version_2}    username=${username}    password=${password}
    upload python package to pypi repository    repository_url=${repository_url}    package=${sample_package_1_wheel_version_1}
    upload python package to pypi repository    repository_url=${repository_url}    package=${sample_package_1_wheel_version_2}
    # search python package in pypi repository    package_name=${sample_package_1_name}   repository_url=${repository_url}
    install python package    repository_url=${repository_url}    package_name=${sample_package_1_name}    package_version=${sample_package_1_version_1}
    upgrade python package      repository_url=${repository_url}    package_name=${sample_package_1_name}
    uninstall python package    package_name=${sample_package_1_name}

install python package from local filesystem
    [Documentation]    Upload the python package to pypi repository
    ...                download the python package from pypi repository 
    ...                install it from local filesystem and 
    ...                uninstall the python package
    [Tags]    tc3    test-dev    test-weekly
    [Teardown]    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_5_name}      package_version=${sample_package_5_version}     username=${username}     password=${password}
    upload python package to pypi repository     repository_url=${repository_url}    package=${sample_package_5_wheel}
    download python package    repository_url=${repository_url}    package_name=${sample_package_5_name}      package_version=${sample_package_5_version}
    install python package    repository_url=${repository_url}    package_name=${sample_package_5_name}    from_local=${True}
    uninstall python package    package_name=${sample_package_5_name}


install python package with different python versions
    [Documentation]    Upload the python package that is supported in specific python version  to pypi repository
    ...                try to install the uploaded python package from pypi repository, 
    ...                expected to fail as supported python version is unavailable in client
    [Tags]    tc4    test-dev    test-weekly
    [Teardown]    Run Keywords   remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_2_name}     package_version=${sample_package_2_version}    username=${username}    password=${password}
    ...    AND    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_3_name}     package_version=${sample_package_3_version}    username=${username}    password=${password}
    upload python package to pypi repository     repository_url=${repository_url}    package=${sample_package_2_wheel}
    upload python package to pypi repository     repository_url=${repository_url}    package=${sample_package_3_wheel}
    ${result}=    Run Process    pip install ${sample_package_2_name} --index-url ${repository_url}    shell=True    stderr=STDOUT  
    Log     ${result.stdout}
    Should Contain    ${result.stdout}    requires a different Python    strip_spaces=True
    ${result}=    Run Process    pip install ${sample_package_3_name} --index-url ${repository_url}    shell=True    stderr=STDOUT  
    Log     ${result.stdout}
    Should Contain    ${result.stdout}    requires a different Python    strip_spaces=True

access pypi repository with unauthorized credentials
    [Documentation]    Try to access pypi repository using twine with unauthorized credentials
    [Tags]    tc5    test-dev    test-weekly
    ${result}=    Run Process    twine upload --repository-url ${repository_url} -u dummy -p dummy ${sample_package_2_wheel}    shell=True    stderr=STDOUT  
    Log     ${result.stdout}
    Should Contain    ${result.stdout}    HTTPError: 403 Forbidden    strip_spaces=True      

install preloaded python package from pypi repository
    [Documentation]    install preloaded python package from pypi repository
    [Tags]    tc6    test-dev    test-weekly
    install python package    repository_url=${repository_url}    package_name=${sample_preloaded_package}      package_version='${sample_preloaded_package_version}'

install not preloaded python package from pypi repository
    [Documentation]    Try to install not preloaded python package from pypi repository
    [Tags]    tc7    test-dev    test-weekly
    ${result}=    Run Process    pip install torch\=\=2.0.1 --index-url ${repository_url}    shell=True    stderr=STDOUT  
    Log     ${result.stdout}
    Should Contain    ${result.stdout}    No matching distribution found for    strip_spaces=True