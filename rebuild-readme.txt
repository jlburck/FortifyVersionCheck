http://socraticprogrammer.com/custom-azure-pipeline-build-task/


Step code in in step.ps1.  Parameters in step.ps1 must match names of inputs in task.json

To create a new version: 
- update step.ps1 code
- update task.json version numbers 
- update vss-extension.json version number
- run on command line: tfx extension create
