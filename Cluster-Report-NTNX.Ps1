
############################################################
##
## Function: Cluster-Report-NTNX
## Author: Sandeep MP
## Description: Gather Cluster stats and exports to mentioned path
## Language: PowerShell
##
############################################################

function Cluster-Report-NTNX{
<#
.NAME
	Cluster-Report-NTNX
.SYNOPSIS
	Gather Cluster stats and exports to mentioned path
.DESCRIPTION
	Gather Cluster stats and exports to mentioned path
.NOTES
	Authors:  sandeep.mp@nutanix.com
	
	Logs: C:\Users\<USERNAME>\AppData\Local\Temp\NutanixCmdlets\logs
.LINK
	www.nutanix.com
.EXAMPLE
    Cluster-Report-NTNX -Server '10.10.10.10' -UserName 'Username' -Password 'Password' -Metric 'Hypervisor CPU Usage (%)' -Startdate '04/10/2017 10:00' -Enddate '04/10/2017 11:00' -Interval 60 -OutFile 'C:\Script\CPU_usage.csv'
    
.SYNTAX
    Cluster-Report-NTNX [-Server] <string> -UserName <string> -Password <string> -Metric <string> {Hypervisor CPU Usage (%) | Hypervisor Memory Usage (%) | Hypervisor I/O Latency | Hypervisor I/O Bandwidth | Hypervisor IOPS | Physical Usage} -Startdate 
    <datetime> -Enddate <datetime> -Interval <int> -OutFile <string>  [<CommonParameters>]

#> 
param(
      [Parameter(Position=0,Mandatory=$True)][String]$Server,
      [Parameter(Mandatory=$True)][String]$UserName,
      [Parameter(Mandatory=$True)][String]$Password,
      [Parameter(Mandatory=$True)][ValidateSet("Hypervisor CPU Usage (%)","Hypervisor Memory Usage (%)","Hypervisor I/O Latency","Hypervisor I/O Bandwidth","Hypervisor IOPS","Physical Usage")][String]$Metric,
      [Parameter(Mandatory=$True)][DateTime]$Startdate,
      [Parameter(Mandatory=$True)][DateTime]$Enddate,
      [Parameter(Mandatory=$True)][Int]$Interval,
      [Parameter(Mandatory=$True)][String]$OutFile
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
        switch($metric)
              {
               "Hypervisor CPU Usage (%)"{$metric_selected ="hypervisor_cpu_usage_ppm"}
               "Hypervisor Memory Usage (%)"{$metric_selected ="hypervisor_memory_usage_ppm"}
               "Hypervisor I/O Latency"{$metric_selected ="hypervisor_avg_io_latency_usecs "}
               "Hypervisor I/O Bandwidth"{$metric_selected ="hypervisor_io_bandwidth_kBps"}
               "Hypervisor IOPS"{$metric_selected ="hypervisor_num_iops"}
               "Physical Usage"{$metric_selected ="storage.usage_bytes"}
              }
         $pwd = ConvertTo-SecureString $password -AsPlainText -Force
         $data = @()
         [int64]$start_time = ((New-TimeSpan -Start $epoch -End $startdate).TotalMilliseconds)*1000
         [int64]$end_time = ((New-TimeSpan -Start $epoch -End $enddate).TotalMilliseconds)*1000
    }
process{
        Disconnect-NTNXCluster -Servers *
        $clusterout = Connect-NTNXCluster -Server $server -UserName $UserName -Password $pwd -AcceptInvalidSSLCerts -ForcedConnection
        $out = ""
        $out = (Get-NTNXClusterStat -Metrics $metric_selected -StartTimeInUsecs $start_time -EndTimeInUsecs $end_time -IntervalInSecs $Interval).values
        foreach($val in $out)
         {
            $into = new-object PSObject
            Add-member -inputobject $into -membertype Noteproperty -Name Date $startdate
            Add-member -inputobject $into -membertype Noteproperty -Name Value $val
            $data +=$into
            $Startdate = $startdate.AddSeconds($Interval)
         }
       }
End{
        if($out)
          {
            $data | export-csv $OutFile
            Write-Host "Report saved in path : $OutFile"
          }Else
          {
          Write-Host "No data available for export"
          }
    Disconnect-NTNXCluster -Servers *
   }
}
