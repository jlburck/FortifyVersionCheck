# FortifyVersionCheck
Checks HP Fortify for projects and project versions.  If the project doesn't exist, then the task is capable of creating the project and an initial version.  If the project version doesn't exist, then the task is capable of creating the version and also capable of copying issues/suppressions from previous versions.

## To use this task with your own installed version of HP Fortify, you will need an API Key.  Below are instructions on how to create one.
### Create an API Key Pair or a Personal Access Token in Fortify on Demand
The Fortify on Demand Plugin connects to Fortify on Demand through the Fortify on Demand API. Authentication requires an API key and secret pair or a personal access token.
#### To create an API key and secret pair: Within Fortify on Demand, navigate to the Settings page under the Administration view, and then to the  API tab. Create an API key with the Start Scans permission. Make sure to copy the secret as it is only shown once. Note that only Security Leads can create API keys. 
#### To create a personal access token: Within Fortify on Demand, select your account name > . Create a personal access Personal Access Tokens token with the api-tenant scope. Make sure to copy the token as it is only shown once.

## Brief description of each parameter
### Fortify Base URL
This is the base url you would use to access your HP Fortify.  For example, https://fortify/ssc
### HP Fortify API Key
The api key you setup in steps above.
### Allow New Projects
If the project name isn't found in Fortify, this parameter will allow or disallow the creation of a new project.  Enter either true or false.
### Allow New Project Versions
If the project version isn't found in Fortify, this parameter will allow or disallow the creation of a new project version.  Enter either true or false.
### Project Name
This is the name that the task will search for in Fortify.  You will want it to match exactly what is in Fortify.
### Application Version
This is usually major.minor.patch, for example 1.0.0
### Version to Copy
This entry is similar to Application Version parameter, but this version is the one you intend to copy existing issues/suppressions from.  If this version is not found, then this task defaults to using the latest existing version if one exists.

## Helpful Content
For creating your own custom extension, I found the following blog to be particularly helpful as a step-by-step tutorial:
http://socraticprogrammer.com/custom-azure-pipeline-build-task/ 
