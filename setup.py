
from distutils.core import setup

setup(
    name='boto_util',
    version='0.1',
    description='boto_util tests for py.test.',
    author='Austin Ouyang',
    author_email='austin@insightdataengineering.com',
    packages=['util'],
    install_requires=['boto3', 'schema', 'moto']
    )
