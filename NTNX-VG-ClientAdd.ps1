############################################################
##
## Function: New-NTNXVM-V2
## Author: Sandeep MP
## Description: Create ESXi VM via Nutanix
## Language: PowerShell
##
############################################################
$ErrorActionPreference = "SilentlyContinue"

function NTNX-VG-ClientAdd{


<#
.NAME
	NTNX-VG-ClientAdd
.SYNOPSIS
	Add/Remove VG Client IP/IQN
.DESCRIPTION
	Add/Remove VG Client IP/IQN
.NOTES
	Authors:  sandeep.mp@nutanix.com
	
	Logs: C:\Users\<USERNAME>\AppData\Local\Temp\NutanixCmdlets\logs
.LINK
	www.nutanix.com
.EXAMPLE
    NTNX-VG-ClientAdd -Server "10.10.10.10" -UserName "User_name" -Password "Password" -VGName "VG_name" -Operation "Add/Remove" -VCpu 1 -ClientAddress "IQN/IP"

.SYNTAX
    
#> 

            param(
                  [Parameter(Position=0,Mandatory=$True)][String]$Server,
                  [Parameter(Mandatory=$True)][String]$UserName,
                  [Parameter(Mandatory=$True)][String]$Password,
                  [Parameter(Mandatory=$True)][string]$VGName,
                  [Parameter(Mandatory=$True)][ValidateSet('Attach','Detach')][string]$Operation,
                  [Parameter(Mandatory=$True)][string]$ClientAddress
                 
                  )

                  Begin {
                    $pwd = ConvertTo-SecureString $password -AsPlainText -Force
                     #Disconnect session if any
                    Disconnect-NTNXCluster -Servers *

                    #Connect to nutanix cluster and gather vm UUID
                    $Clusterout = Connect-NTNXCluster -Server $server -username $username -Password $pwd -AcceptInvalidSSLCerts -ErrorAction SilentlyContinue
                    if($Clusterout)
                        {
                            $vgid = (Get-NTNXVolumeGroups | Where-Object {$_.name -ceq "$VGName"}).uuid
                            if($vgid.count -ne 1)
                                {
                                Write-host "Either VG not present or Multiple VGs present"
                             
                                break
                                }

                        }else
                        {
                            write-host "Unable to connect to cluster : $server"
                            break
                        }

                           
                       }
                    
                   

process{

$body = "{""iscsi_client"":
{
       ""client_address"": ""$ClientAddress""
   },
   ""operation"": ""$Operation""
   }"

   switch($Operation)
   {
   "Attach" {$action = 'open'}
   "Detach" {$action = 'close'}
   }

 $creds = New-Object System.Management.Automation.PSCredential ($username,$pwd)  
 $Header = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$pwd ))}

$url = "https://${server}:9440/PrismGateway/services/rest/v2.0/volume_groups/${vgid}/$action"

#$out = 
 $out = Invoke-RestMethod -Method POST -Uri $Url -Credential $creds -Headers $Header -Body $body -ContentType application/json 
}

End{
if($out.value -eq $true)
{
Write-host "Update $ClientAddress on VG : $VGName successfully!!!" -ForegroundColor Green
}else
{
Write-Host " Unable to update VG : $VGName" -ForegroundColor Red
}
Disconnect-NTNXCluster -Servers *
}
}