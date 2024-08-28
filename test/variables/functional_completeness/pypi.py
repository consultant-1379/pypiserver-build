import os

# TEST DATA DIR
test_data_dir = os.getenv("TEST_DATA_DIR", "/home/exxrakr/codebase-mxe/pypiserver-build/test/testdata")
test_dir = os.getenv("ROBOT_TESTS_DIR", "/home/exxrakr/codebase-mxe/pypiserver-build/test/")

#PyPi Testcase variables

#Package 1: This python package built on python 3.8 with versions 1.1/2.1 and have one dependant library,atomicwrites. 
# Metadata given while buiding the package
'''
Name: single-dependant-python-3.8
Version: 1.1/2.1
Summary: A lightweight package with one dependency
Author: KP
Author-email: KP@gmail.com
Requires: atomicwrites 
'''
sample_package_1_name = 'single_dependant_python_3.8'
sample_package_1_version_1 = '1.1'
sample_package_1_wheel_version_1 = f'{test_data_dir}/wheelpackages/single_dependant_python_3.8-1.1-py3-none-any.whl'
sample_package_1_version_2 = '2.1'
sample_package_1_wheel_version_2 = f'{test_data_dir}/wheelpackages/single_dependant_python_3.8-2.1-py3-none-any.whl'

#Package 2: This python package supported only above python 3.11, version as 1.1 and have one dependant library,atomicwrites
# Metadata given while buiding the package
'''
Name: single-dependant-python-3.10
Version: 1.1
Summary: A lightweight package with one dependency
Author: KP
Author-email: KP@gmail.com
Requires: atomicwrites 
Required-by: python>3.11
'''
sample_package_2_name = 'single_dependant_python_3.10'
sample_package_2_version = '1.1'
sample_package_2_wheel = f'{test_data_dir}/wheelpackages/single_dependant_python_3.10-1.1-py3-none-any.whl'

#Package 3: This python package supported only above python 3.9, version as 1.1 and have one dependant library,atomicwrites
# Metadata given while buiding the package
'''
Name: single-dependant-python-3.6
Version: 1.1
Summary: A lightweight package with one dependency
Author: KP
Author-email: KP@gmail.com
Requires: atomicwrites 
Required-by: python<=3.6
'''
sample_package_3_name = 'single_dependant_python_3.6'
sample_package_3_version = '1.1'
sample_package_3_wheel = f'{test_data_dir}/wheelpackages/single_dependant_python_3.6-1.1-py3-none-any.whl'

#Dependant package downloaded from global PyPi server
sample_package_4_name = 'atomicwrites'
sample_package_4_version = '1.3.0'
sample_package_4_wheel = f'{test_data_dir}/wheelpackages/atomicwrites-1.3.0-py2.py3-none-any.whl'

#Dependant package downloaded from global PyPi server
sample_package_5_name = 'pathlib'
sample_package_5_version = '1.0.1'
sample_package_5_wheel = f'{test_data_dir}/wheelpackages/pathlib-1.0.1-py3-none-any.whl'

#Preloaded package name
sample_preloaded_package = 'watchdog'
sample_preloaded_package_version = '3.0.0'
