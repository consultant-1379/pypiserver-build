*** Settings ***
Documentation    Test file
Library    Process
Library    OperatingSystem
Library    Collections
Library    String
Variables    variables/pypi_repository_details.py
Variables    variables/functional_completeness/pypi.py
Resource    keywords/pypi_keywords.robot

*** Variables ***

*** Test Cases ***
sample testcase
    [Documentation]    test
    [Tags]    tc1
    enable access to pypi repository    repository_hostname=${repository_hostname}    repository_url=${repository_url}    username=${username}    password=${password}
    upload python package to pypi repositry    repository_url=${repository_url}    package=${sample_package_3_wheel}
    upload python package to pypi repository    repository_url=${repository_url}    package=${sample_package_1_wheel_version_1}
    #install python package    repository_url=${repository_url}    package_name=${sample_package_1_name}    
    #package_version=${sample_package_1_version_1} 
    remove python package from pypi repository    repository_url=${repository_url}    package_name=${sample_package_1_name}    package_version=${sample_package_1_version_1}    username=${username}    password=${password}
    #uninstall python package    package_name=${sample_package_1_name}