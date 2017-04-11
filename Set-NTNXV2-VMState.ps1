############################################################
##
## Function: Set-NTNXV2-VMState
## Author: Sandeep MP
## Description: Change ESXi VM powerstate via Nutanix
## Language: PowerShell
##
############################################################

function Set-NTNXV2-VMState{
<#
.NAME
  Set-NTNXV2-VMState
.SYNOPSIS
  Change ESXi VM powerstate via Nutanix
.DESCRIPTION
  Change ESXi VM powerstate via Nutanix
.NOTES
  Authors:  sandeep.mp@nutanix.com
  
  Logs: C:\Users\<USERNAME>\AppData\Local\Temp\NutanixCmdlets\logs
.LINK
  www.nutanix.com
.EXAMPLE
    Set-NTNXV2-VMState -Server "10.10.10.10" -UserName "User_name" -Password "Password" -VM "VM_name" -Transition "VM_State"
#> 

            param(
                  [Parameter(Position=0,Mandatory=$True)][String]$Server,
                  [Parameter(Mandatory=$True)][String]$UserName,
                  [Parameter(Mandatory=$True)][String]$Password,
                  [Parameter(Mandatory=$True)][string]$VM,
                  [Parameter(Mandatory=$True)][ValidateSet("ON","OFF","RESET","SUSPEND","RESUME")][System.String]$Transition
                 )

            Begin{
                    #Add NutanixCMDletsPSSnapin
                    Add-PSSnapin NutanixCMDletsPSSnapin

                    #Prerequisites Check
                                        
                    $pssnapin = Get-PSSnapin
                    $pssnapincheck = $pssnapin.name -contains "NutanixCMDletsPSSnapin"
                    $psver = $PSVersionTable.PSVersion.Major -ge 3
                    if(($pssnapincheck -eq $false) -or ($psver -eq $false))
                         {

                            if($pssnapincheck -eq $false)
                                {
                                    write-host "Nutanix CMDlets not installed"
                                }
                            if($psver -eq $false)
                                {
                                    write-host "Powershell version should be 3.0 or above"
                                }
                           break
                         }


                    $pwd = ConvertTo-SecureString $password -AsPlainText -Force
                       
                    #Disconnect session if any
                    Disconnect-NTNXCluster -Servers *

                    #Connect to nutanix cluster and gather vm UUID
                    $Clusterout = Connect-NTNXCluster -Server $server -username $username -Password $pwd -AcceptInvalidSSLCerts -ErrorAction SilentlyContinue
                    if($Clusterout)
                        {
                            $vmid = (Get-NTNXVM | where{$_.vmname -ceq $vm}).uuid
                        }else
                        {
                            write-host "Unable to connect to cluster : $server"
                            break
                        }

                  }

            Process{
                
                    #Trigger Rest Action to power cycle VM

                    $creds = New-Object System.Management.Automation.PSCredential ($username, $pwd)  
                    $headers = @{"X-Requested-With"="powershell"}  
                    $Uri = "https://${server}:9440/api/nutanix/v2.0/vms/${vmid}/set_power_state/"
$body = "{
  ""transition"": ""$Transition""
}"

                    $out = Invoke-RestMethod -Method POST -Uri $Uri -Credential $creds -Headers $Header -Body $body -ContentType application/json
                   }

            End{
                return $out
               }
}