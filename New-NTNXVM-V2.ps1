
############################################################
##
## Function: New-NTNXVM-V2
## Author: Sandeep MP
## Description: Create ESXi VM via Nutanix
## Language: PowerShell
##
############################################################
$ErrorActionPreference = "SilentlyContinue"

function New-NTNXVM-V2{


<#
.NAME
	New-NTNXVM-V2
.SYNOPSIS
	Create ESXi VM via Nutanix
.DESCRIPTION
	Create ESXi VM via Nutanix
.NOTES
	Authors:  sandeep.mp@nutanix.com
	
	Logs: C:\Users\<USERNAME>\AppData\Local\Temp\NutanixCmdlets\logs
.LINK
	www.nutanix.com
.EXAMPLE
    New-NTNXVM-V2 -Server "10.10.10.10" -UserName "User_name" -Password "Password" -VM "VM_name" -Transition "VM_State"
#> 

            param(
                  [Parameter(Position=0,Mandatory=$True)][String]$Server,
                  [Parameter(Mandatory=$True)][String]$UserName,
                  [Parameter(Mandatory=$True)][String]$Password,
                  [Parameter(Mandatory=$True)][string]$VMname,
                       [Parameter(Mandatory=$True)][ValidateSet("CentOS 4/5/6/7","CentOS 4/5/6/7 (64-bit)","Debian GNU/Linux 4","Debian GNU/Linux 4 (64 bit)","Debian GNU/Linux 5","Debian GNU/Linux 5 (64 bit)","Debian GNU/Linux 6","Debian GNU/Linux 6 (64 bit)","MS-DOS","OpenSUSE Linux (64 bit)","Red Hat Enterprise Linux 2","Red Hat Enterprise Linux 3","Red Hat Enterprise Linux 3 (64 bit)","Red Hat Enterprise Linux 4","Red Hat Enterprise Linux 4 (64 bit)","Red Hat Enterprise Linux 5","Red Hat Enterprise Linux 5 (64 bit) (experimental)","Red Hat Enterprise Linux 6","Red Hat Enterprise Linux 6 (64 bit)","Red Hat Enterprise Linux 7","Red Hat Enterprise Linux 7 (64 bit)","Red Hat Linux 2.1","Solaris 6","Solaris 7","Solaris 8","Solaris 9","Ubuntu Linux","Ubuntu Linux (64 bit)","Windows 2000 Advanced Server","Windows 2000 Professional","Windows 2000 Server","Windows 7","Windows 7 (64 bit)","Windows 8","Windows 8 (64 bit)","Windows Millenium Edition","Windows NT 4","Windows Server 2003, Enterprise Edition","Windows Server 2003, Enterprise Edition (64 bit)","Windows Server 2003, Standard Edition","Windows Server 2003, Standard Edition (64 bit)","Windows Server 2003, Web Edition","Windows Server 2008 R2 (64 bit)","Windows Server 2012 (64 bit)","Windows XP Home Edition","Windows XP Professional","Windows XP Professional Edition (64 bit)")][System.String]$OSType
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
switch($OStype)
{
"CentOS 4/5/6/7" {$type = "centosGuest"}
"CentOS 4/5/6/7 (64-bit)" {$type = "centos64Guest"}
"Debian GNU/Linux 4" {$type = "Debian GNU/Linux 4"}
"Debian GNU/Linux 4 (64 bit)" {$type = "debian4_64Guest"}
"Debian GNU/Linux 5" {$type = "debian5Guest"}
"Debian GNU/Linux 5 (64 bit)" {$type = "debian5_64Guest"}
"Debian GNU/Linux 6" {$type = "debian6Guest"}
"Debian GNU/Linux 6 (64 bit)" {$type = "debian6_64Guest"}
"MS-DOS" {$type = "dosGuest"}
"OpenSUSE Linux (64 bit)" {$type = "opensuseGuest"}
"Red Hat Enterprise Linux 2" {$type = "rhel2Guest"}
"Red Hat Enterprise Linux 3" {$type = "rhel3Guest"}
"Red Hat Enterprise Linux 3 (64 bit)" {$type = "rhel3_64Guest"}
"Red Hat Enterprise Linux 4" {$type = "rhel4Guest"}
"Red Hat Enterprise Linux 4 (64 bit)" {$type = "rhel4_64Guest"}
"Red Hat Enterprise Linux 5" {$type = "rhel5Guest"}
"Red Hat Enterprise Linux 5 (64 bit) (experimental)" {$type = "rhel5_64Guest"}
"Red Hat Enterprise Linux 6" {$type = "rhel6Guest"}
"Red Hat Enterprise Linux 6 (64 bit)" {$type = "rhel6_64Guest"}
"Red Hat Enterprise Linux 7" {$type = "rhel7Guest"}
"Red Hat Enterprise Linux 7 (64 bit)" {$type = "rhel7_64Guest"}
"Red Hat Linux 2.1" {$type = "redhatGuest"}
"Solaris 6" {$type = "solaris6Guest"}
"Solaris 7" {$type = "solaris7Guest"}
"Solaris 8" {$type = "solaris8Guest"}
"Solaris 9" {$type = "solaris9Guest"}
"Ubuntu Linux" {$type = "ubuntuGuest"}
"Ubuntu Linux (64 bit)" {$type = "ubuntu64Guest"}
"Windows 2000 Advanced Server" {$type = "win2000AdvServGuest"}
"Windows 2000 Professional" {$type = "win2000ProGuest"}
"Windows 2000 Server" {$type = "win2000ServGuest"}
"Windows 7" {$type = "windows7Guest"}
"Windows 7 (64 bit)" {$type = "windows7_64Guest"}
"Windows 8" {$type = "windows8Guest"}
"Windows 8 (64 bit)" {$type = "windows8_64Guest"}
"Windows Millenium Edition" {$type = "winMeGuest"}
"Windows NT 4" {$type = "winNTGuest"}
"Windows Server 2003, Enterprise Edition" {$type = "winNetEnterpriseGuest"}
"Windows Server 2003, Enterprise Edition (64 bit)" {$type = "winNetEnterprise64Guest"}
"Windows Server 2003, Standard Edition" {$type = "winNetStandardGuest"}
"Windows Server 2003, Standard Edition (64 bit)" {$type = "winNetStandard64Guest"}
"Windows Server 2003, Web Edition" {$type = "winNetWebGuest"}
"Windows Server 2008 R2 (64 bit)" {$type = "windows7Server64Guest"}
"Windows Server 2012 (64 bit)" {$type = "windows8Server64Guest"}
"Windows XP Home Edition" {$type = "winXPHomeGuest"}
"Windows XP Professional" {$type = "winXPProGuest"}
"Windows XP Professional Edition (64 bit)" {$type = "winXPPro64Guest"}
}
                    $pwd = ConvertTo-SecureString $password -AsPlainText -Force
                       
                    #Disconnect session if any
                    Disconnect-NTNXCluster -Servers *

                    #Connect to nutanix cluster and gather vm UUID
                    $Clusterout = Connect-NTNXCluster -Server $server -username $username -Password $pwd -AcceptInvalidSSLCerts -ErrorAction SilentlyContinue
                    if($Clusterout)
                        {
                            $vmid = (Get-NTNXVM | where{$_.vmname -ceq $vm}).uuid
                            if($vmid)
                                {
                                Write-host "VM already available with same name"
                             
                                break
                                }

                        }else
                        {
                            write-host "Unable to connect to cluster : $server"
                            break
                        }

                  }

            Process{
                
                    #Create VM

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

