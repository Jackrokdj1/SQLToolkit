﻿# this function runs a SQL backup against the supplied server and database
[CmdletBinding()]
Param()

Trace-VstsEnteringInvocation $MyInvocation

Try
	{
		Import-VstsLocStrings "$PSScriptRoot\Task.json"
		[string]$backupType = Get-VstsInput -Name backupType
		[string]$serverName = Get-VstsInput -Name serverName
		[string]$databaseName = Get-VstsInput -Name databaseName
		[string]$backupFile = Get-VstsInput -Name backupFile
		[string]$withInit = Get-VstsInput -Name withInit
		[string]$userName = Get-VstsInput -Name userName
		[string]$userPassword = Get-VstsInput -Name userPassword
		
		
		#Specify the Action property to generate a FULL backup
		switch($backupType.ToLower())
		{
			"full" {$backupAction = "DATABASE"}
			"log" {$backupAction = "LOG"}
			"differential" {$backupAction = "DATABASE"}
		}
		
		#Initialize the backup if set
		switch($withInit)
		{
			$false {$mediaInit = "NOINIT"}
			$true {$mediaInit = "INIT"}
		}
		
		#Set WITH options
		if($backupType -eq "differential")
		{
			$withOptions = "DIFFERENTIAL, " + $mediaInit;
		}
		else
		{
			$withOptions = $mediaInit
		}
		
		#Build the backup query using Windows Authenication
		$query = "BACKUP " + $backupAction + " " + $databaseName + " TO DISK = N'" + $backupFile + "' WITH " + $withOptions; 
		
		Write-Host "Starting $backupType backup of $databaseName to $backupFile"
		
		#Execute the backup
		if([string]::IsNullOrEmpty($userName))
		{
			Write-Host $query
			Invoke-Sqlcmd -ServerInstance $serverName -Query $query
		}
		else
		{
			Write-Host $query
			Invoke-Sqlcmd -ServerInstance $serverName -Query $query -Username $userName -Password $userPassword
		}
		
		Write-Host "Finished"
	}
	
Catch
	{
		Write-Error "Error running SQL backup";
		Write-Error $_.Exception.GetType().FullName;
		Write-Error $_.Exception.Message;
	}







