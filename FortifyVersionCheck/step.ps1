[CmdletBinding()]
param()

# For more information on the Azure DevOps Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation
try {
    $ErrorActionPreference = "SilentlyContinue";

    $fortifyUrl= Get-VstsInput -Name baseUrl -Require
    $apikey= Get-VstsInput -Name apiKey -Require
    $n= Get-VstsInput -Name projectName -Require
    $v= Get-VstsInput -Name version -Require
    $lv= Get-VstsInput -Name copyFromVersion -Require
    $createnewproj= Get-VstsInput -Name createProject -Require
    $createnewversion= Get-VstsInput -Name createProjectVersion -Require

    if ($createnewproj -like "true"){$createnewproj=$true}
    if ($createnewversion -like "true"){$createnewversion=$true}

    $Headers = @{
        Accept            = 'application/json, text/plain, */*'
        'Cache-Control'   = 'no-cache'
        Authorization     = "Basic $($apikey)"
        'Content-Type'    = "application/json;charset=UTF-8"
        'Accept-Encoding' = 'gzip, deflate'    
    }
    
    # Auth Request
    $ar = Invoke-WebRequest -Uri "$($fortifyUrl)/api/v1/auth/obtain_token" -Headers $Headers -Method Post | ConvertFrom-Json
    
    $Hs = @{
        Accept            = 'application/json, text/plain, */*'
        'Cache-Control'   = 'no-cache'
        Authorization     = 'FortifyToken ' + $ar.data.token
        'Content-Type'    = "application/json"
        'Accept-Encoding' = 'gzip, deflate'    
    }

    ### Create a new fortify project version
    function Copy-CurrentState($previousVersionId,$VersionId){
    $b= '{
			"copyCurrentStateFpr": true,
            "previousProjectVersionId": 12016,
            "projectVersionId": 12018
    }'
    $b=$b.Replace('12018',$versionId)
    $b = $b.Replace('12016',$previousVersionId)
    write-host "BODY: $b"
    Invoke-WebRequest -Uri "$($fortifyUrl)/api/v1/projectVersions/action/copyCurrentState" -Method Post -ContentType "application/json" -Headers $hs -Body $b
    }

    function Update-ProjectVersion($versionId){
    $b= '{
  "requests": [
    {
      "uri": "https:\/\/fortify\/ssc\/api\/v1\/projectVersions\/12009\/attributes",
      "httpVerb": "PUT",
      "postData": [
        {
          "attributeDefinitionId": 5,
          "values": [
            {
              "guid": "New"
            }
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 6,
          "values": [
            {
              "guid": "Internal"
            }
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 7,
          "values": [
            {
              "guid": "internalnetwork"
            }
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 10,
          "values": [
            
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 11,
          "values": [
            
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 12,
          "values": [
            
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 1,
          "values": [
            {
              "guid": "High"
            }
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 2,
          "values": [
            
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 3,
          "values": [
            
          ],
          "value": null
        },
        {
          "attributeDefinitionId": 4,
          "values": [
            
          ],
          "value": null
        }
      ]
    },
    {
      "uri": "https:\/\/fortify\/ssc\/api\/v1\/projectVersions\/12009\/responsibilities",
      "httpVerb": "PUT",
      "postData": [
        {
          "responsibilityGuid": "projectmanager",
          "userId": null
        },
        {
          "responsibilityGuid": "securitychampion",
          "userId": null
        },
        {
          "responsibilityGuid": "developmentmanager",
          "userId": null
        }
      ]
    },
    {
      "uri": "https:\/\/fortify\/ssc\/api\/v1\/projectVersions\/12009\/action",
      "httpVerb": "POST",
      "postData": [
        {
          "type": "COPY_FROM_PARTIAL",
          "values": {
            "projectVersionId": 12009,
            "previousProjectVersionId": -1,
            "copyAnalysisProcessingRules": true,
            "copyBugTrackerConfiguration": true,
            "copyCurrentStateFpr": false,
            "copyCustomTags": true
          }
        }
      ]
    },
    {
      "uri": "https:\/\/fortify\/ssc\/api\/v1\/projectVersions\/12009?hideProgress=true",
      "httpVerb": "PUT",
      "postData": {
        "committed": true
      }
    }
  ]
}'
    $newurl = $fortifyUrl.Replace('/','\/')
    $b=$b.Replace('12009',$versionid)
    $b=$b.Replace('https:\/\/fortify\/ssc',$newurl)
    $b
    Invoke-WebRequest -Uri "$($fortifyUrl)/api/v1/bulk" -Method Post -ContentType "application/json" -Headers $hs -Body $b

    }

    ### Create a new fortify project
    function Create-Project($version,$projectName){
    $b= '{
			"name": "1.0.0",
			"description": "",
			"active": true,
			"committed": true,
            "project": {
                "name": "RES-DC-TestProject",
                "description": "",
                "issueTemplateId": "Prioritized-HighRisk-Project-Template"
            },
            "issueTemplateId": "Prioritized-HighRisk-Project-Template"
    }'
    $b=$b.Replace('1.0.0',$version)
    $b = $b.Replace('RES-DC-TestProject',$projectName)
    
    $output =Invoke-WebRequest -Uri "$($fortifyUrl)/api/v1/projectVersions" -Method Post -ContentType "application/json" -Headers $hs -Body $b
    $versionid= ($output.content | ConvertFrom-Json).data.id
    write-host "URL: $($fortifyUrl)/api/v1/projectVersions"
    write-host "BODY: $b"
    write-host "VersionId: $versionid"
    Update-ProjectVersion -versionId $versionid
    }

    ### Create a new fortify project version
    function Create-ProjectVersion($version,$projectName,$projectId,$latestVersion){
    $b= '{
			"name": "1.0.0",
			"description": "",
			"active": true,
			"committed": false,
            "project": {
                "id": 374,
                "name": "RES-DC-TestProject",
                "description": "",
                "issueTemplateId": "Prioritized-HighRisk-Project-Template"
            },
            "issueTemplateId": "Prioritized-HighRisk-Project-Template"
    }'
    $b=$b.Replace('1.0.0',$version)
    $b = $b.Replace('RES-DC-TestProject',$projectName)
    $b = $b.Replace('374',$projectId)
    write-host "URL: $($fortifyUrl)/api/v1/projectVersions"
    write-host "BODY: $b"
    write-host "ProjectId: $projectid"
    $output =Invoke-WebRequest -Uri "$($fortifyUrl)/api/v1/projectVersions" -Method Post -ContentType "application/json" -Headers $hs -Body $b
    Write-Host "VersionId: $versionid"
    $versionid= ($output.content | ConvertFrom-Json).data.id
    Update-ProjectVersion -versionId $versionid
    Write-Host "Copying latest suppressions from versionid: $latestVersion"
    if($latestVersion -notlike ''){
    Copy-CurrentState -previousVersionId $latestVersion -VersionId $versionid}else{
    Write-Host "The previous suppressions will not be copied because there is no existing version to copy this version from."}
    }

        
    ### Where all the magic happens.
    $projid=$null
    $versionfound=$null
    $check=((((Invoke-webrequest -Uri "$($fortifyurl)/api/v1/projects?start=-1&limit=-1" -Method Get -Headers $Hs)).Content | ConvertFrom-Json).data | where {$_.name -like $n})
    if($check -ne $null){
        $result = (((Invoke-webrequest -Uri "$($fortifyUrl)/api/v1/projects/$($((((Invoke-webrequest -Uri "$($fortifyUrl)/api/v1/projects?start=-1&limit=-1" -Method Get -Headers $Hs)).Content | ConvertFrom-Json).data | where {$_.name -like "$n"}).id)/versions" -Method Get -Headers $Hs)).Content)
        (($result | ConvertFrom-Json).data) | ForEach-Object {
            $_.name + " version found."
            $id=$_.id
            if($projid -eq $null){$projid = (Invoke-WebRequest -Uri "$($fortifyUrl)/api/v1/projectVersions/$id" -Method Get -ContentType "application/json" -Headers $hs | ConvertFrom-Json).data.project.id}
            if($_.name -like $v){$versionFound=$true}
            if($_.name -like $lv){$latestVersion=[string]$_.id}else{$allv=[string]$_.id + ',' + $allv}
        }
        if($versionFound -eq $true){Write-Host "Application version $v exists in Fortify."}
        else{write-host "Application version does NOT exist in Fortify."
            if($createnewversion -eq $true -and $projid -ne $null){write-host "creating new project version $v for project $n using projectid $projid"
            if($latestVersion -like '' -and $allv -notlike ''){$latestVersion=($allv.Split(',') | measure -Maximum).Maximum}
            Create-ProjectVersion -version $v -projectName $n -projectId $projid -latestVersion $latestVersion
            }else{Write-Host "Fortify project version does not exist."
        exit 1}
        }
    }else{
        if($createnewproj -eq $true){write-host "creating new project version $v for project $n"
            Create-Project -version $v -projectName $n
        }else{Write-Host "Fortify project does not exist."
        exit 1}
    }
} 
finally {
    Trace-VstsLeavingInvocation $MyInvocation
}



