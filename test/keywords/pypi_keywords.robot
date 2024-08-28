*** Settings ***
Documentation    Higher level keywords for pypi microservice based testcases
Library    Process

*** Keywords ***

enable access to pypi repository
    [Documentation]     Setup the netrc file with PyPi details to provide access to the repository
    ...    This keyword accepts the following arguments:
    ...    repository_hostname             :    hostname of the pypi repository
    ...    username                        :    username to access pypi repository
    ...    password                        :    password to access pypi repository
    [Arguments]    ${test_dir}    ${repository_hostname}   ${repository_url}   ${username}    ${password}
    ${result}=    Run Process    ${test_dir}/scripts/enable_access_to_pypi.sh ${repository_hostname} ${username} ${password}    shell=True    stderr=STDOUT  
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0

disable access to pypi repository
    [Documentation]     Remove the access of pypi repository by deleting the netrc file
    ${result}=    Run Process    rm ~/.netrc     shell=True    stderr=STDOUT 
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0   
    ${result}=    Run Process    rm ~/.pypirc     shell=True    stderr=STDOUT    
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0

upload python package to pypi repository
    [Documentation]     upload the python package to pypi repository
    ...    This keyword accepts the following arguments:
    ...    repository_url                  :    url of the pypi repository
    ...    package                         :    python packages that needs to be uploaded to the pypi repository
    [Arguments]    ${repository_url}    ${package}
    ${result}=    Run Process    twine upload --repository pypi ${package}    shell=True    stderr=STDOUT
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0

remove python package from pypi repository
    [Documentation]    remove python package from pypi repository
    ...    This keyword accepts the following arguments:
    ...    repository_url                  :    url of the pypi repository
    ...    username                        :    username to access pypi repository
    ...    password                        :    password to access pypi repository
    ...    package_name                    :    package name that needs to be deleted from the pypi repository
    ...    package_version                 :    package version that needs to be deleted from the pypi repository
    [Arguments]    ${repository_url}    ${package_name}    ${package_version}    ${username}    ${password}
    ${result}=    Run Process    curl -u ${username}:${password} --form ":action\=remove_pkg" --form "name\=${package_name}" --form "version\=${package_version}" "${repository_url}"    shell=True    stderr=STDOUT
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0

search python package in pypi repository
    [Documentation]     search python package in pypi repository
    ...    This keyword accepts the following arguments:
    ...    package_name                    :    package name that needs to be searched in the pypi repository
    ...    repository_url                  :    url of the pypi repository
    [Arguments]    ${package_name}     ${repository_url}
    ${result}=    Run Process    pip search ${package_name} --index ${repository_url}    shell=True    stderr=STDOUT 
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0 

install python package
    [Documentation]     install python package from pypi repository
    ...    This keyword accepts the following arguments:
    ...    repository_url                  :    url of the pypi repository
    ...    package_name                    :    package name that needs to be installed from the pypi repository
    ...    package_version                 :    [Optional]
    ...                                         package version that needs to be installed from the pypi repository
    ...    from_local                      :    [Optional]
    ...                                         If true, will install from the pypi repository
    ...                                         If false, will install the package from local path which contains the downloaded wheel packages
    [Arguments]    ${repository_url}    ${package_name}    ${package_version}=""    ${from_local}=${False}
    IF    ${from_local}    
        IF    ${package_version} != ""
            ${result}=    Run Process    pip install ${package_name}\=\=${package_version} --no-index --find-links .    shell=True    stderr=STDOUT
        ELSE
            ${result}=    Run Process    pip install ${package_name} --no-index --find-links .    shell=True    stderr=STDOUT
        END
    ELSE
        IF    ${package_version} != ""
            ${result}=    Run Process    pip install ${package_name}\=\=${package_version} --index-url ${repository_url}    shell=True    stderr=STDOUT
        ELSE
            ${result}=    Run Process    pip install ${package_name} --index-url ${repository_url}    shell=True    stderr=STDOUT  
        END  
    END
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0
    
uninstall python package
    [Documentation]     uninstall python package 
    ...    This keyword accepts the following arguments:
    ...    package_name                    :    package name that needs to be uninstalled
    [Arguments]    ${package_name}
    ${result}=    Run Process    pip uninstall ${package_name} -y    shell=True    stderr=STDOUT 
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0

download python package 
    [Documentation]     download python package  
    ...    This keyword accepts the following arguments:
    ...    repository_url                  :    url of the pypi repository
    ...    package_name                    :    package name that needs to be downloaded from the pypi repository
    ...    package_version                 :    [Optional]
    ...                                         package version that needs to be downloaded from the pypi repository
    [Arguments]    ${repository_url}    ${package_name}    ${package_version}=""
    IF    "${package_version}" != ""
            ${result}=    Run Process    pip download ${package_name} --index-url ${repository_url}    shell=True  
    ELSE        
            ${result}=    Run Process    pip download ${package_name}\=\=${package_version} --index-url ${repository_url}    shell=True    stderr=STDOUT  
    END
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0

upgrade python package
    [Documentation]     upgrade python package 
    ...    This keyword accepts the following arguments:
    ...    repository_url                  :    url of the pypi repository
    ...    package_name                    :    package name that needs to be installed from the pypi repository
    ...    package_version                 :    [Optional]
    ...                                         package version that needs to be installed from the pypi repository
    [Arguments]    ${repository_url}    ${package_name}      ${package_version}=""
    IF    ${package_version} != ""
        ${result}=    Run Process    pip install --upgrade ${package_name}\=\=${package_version} --index-url ${repository_url} -y    shell=True    stderr=STDOUT  
    ELSE
        ${result}=    Run Process    pip install --upgrade ${package_name} --index-url ${repository_url}    shell=True    stderr=STDOUT  
    END
    Log    ${result.stdout}
    Should Be Equal As Integers	${result.rc}	0