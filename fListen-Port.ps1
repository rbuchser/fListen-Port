Function fListen-Port {
	<#
		.NOTES
			Author: Buchser Roger
			
		.SYNOPSIS
			Temporary creates a TCP Listener on a specific Port on Localhost. Stop Listening manually with Ctrl-C.
			
		.DESCRIPTION
			Temporarily listen on a given port for connections dumps connections to the screen. This is useful for troubleshooting firewall rules.
		
		.PARAMETER Port
			The TCP port that the listener should attach to.
		
		.EXAMPLE
			fListen-Port 5986
			Listening on port 5986, press CTRL+C to cancel
		
		.LINK
			https://gallery.technet.microsoft.com/scriptcenter/Listen-Port-powershell-8ed99e4
	#>
    
	PARAM (
		[Parameter(Mandatory=$False,Position=0)][Int]$Port = 443
	)
	
	[Bool]$ExistingListener = $False  
	Try {
		$EndPoint = New-Object System.Net.IPEndPoint ([system.net.ipaddress]::any, $Port)    
		$Listener = New-Object System.Net.Sockets.TcpListener $Endpoint
		$Listener.server.ReceiveTimeout = 3000
		$Listener.start()
		Write-Host "Listening on port $port, press CTRL+C to cancel"
		While ($True){
			If (!$Listener.Pending()) {
				Start-Sleep -Seconds 1 
				Continue
			}
			$Client = $Listener.AcceptTcpClient()
			$Client.Client.RemoteEndPoint | Add-Member -NotePropertyName DateTime -NotePropertyValue (Get-Date) -PassThru
			$Client.Close()
		}
    } Catch {
        #Write-Error $_
		fWrite-Info -cr "There is already an existing Listener for Port $Port" -f Yellow
		Write-Host
		$ExistingListener = $True
		#netstat -ano | Select-String 0.0.0.0:$Port
    } Finally {
		$Listener.Stop()
		If ($ExistingListener -eq $False) {Write-Host "`nTemporary Listener Closed Safely`n" -f Cyan}
    }

}
