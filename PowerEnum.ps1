function LDAPSearch {
    param (
        [string]$LDAPQuery,
        [string[]]$PropertiesToLoad = @("samAccountName", "lastlogon"), # Default properties
        [string]$SearchScope = "Subtree",
        [string]$Username,
        [string]$Password,
        [string]$OutputFile = "LDAPResults.txt", # Updated output file
        [switch]$Verbose,
        [switch]$ShowAllProperties,  # New switch to display all properties
        [switch]$Silent,  # New switch to suppress terminal output
        [switch]$Help  # New Help switch
    )

    if ($Help) {
        Show-Help
        return
    }

    try {
        $PDC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
        $DistinguishedName = ([adsi]'').distinguishedName

        if ($Username -and $Password) {
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)
            $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$PDC/$DistinguishedName", $Username, $Password)
        } else {
            $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$PDC/$DistinguishedName")
        }

        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher($DirectoryEntry, $LDAPQuery)
        $DirectorySearcher.SearchScope = [System.DirectoryServices.SearchScope]::$SearchScope
        $DirectorySearcher.PageSize = 1000

        # Only add properties to load if ShowAllProperties switch is not set
        if (-not $ShowAllProperties) {
            foreach ($property in $PropertiesToLoad) {
                $DirectorySearcher.PropertiesToLoad.Add($property)
            }
        }

        if ($Verbose) {
            Write-Host "Executing LDAP query: $LDAPQuery"
            Write-Host "Connecting to Domain Controller: $PDC"
        }

        $results = $DirectorySearcher.FindAll()

        if ($results.Count -eq 0) {
            Write-Host "No results found for query: $LDAPQuery"
            return
        } 

        # Clear previous content of the output file
        Clear-Content -Path $OutputFile -ErrorAction SilentlyContinue

        # Iterate through results and write to the text file
        foreach ($entry in $results) {
            $entryOutput = ""

            if ($ShowAllProperties) {
                foreach ($prop in $entry.Properties.PropertyNames) {
                    $values = $entry.Properties[$prop]

                    # Check if it's a FileTime attribute and convert it
                    if ($prop -in @("pwdLastSet", "lastLogon", "accountExpires", "lastLogonTimestamp")) {
                        try {
                            $convertedDate = [DateTime]::FromFileTimeUtc($values[0])
                            $entryOutput += "${prop}: $convertedDate`n" # Add to output string
                        } catch {
                            $entryOutput += "${prop}: Error converting time`n"
                        }
                    } else {
                        $entryOutput += "${prop}: $values`n" # Add to output string
                    }
                }
            } else {
                foreach ($prop in $PropertiesToLoad) {
                    if ($entry.Properties[$prop]) {
                        if ($prop -in @("pwdLastSet", "lastLogon", "accountExpires", "lastLogonTimestamp")) {
                            try {
                                $convertedDate = [DateTime]::FromFileTimeUtc($entry.Properties[$prop][0])
                                $entryOutput += "${prop}: $convertedDate`n" # Add to output string
                            } catch {
                                $entryOutput += "${prop}: Error converting time`n"
                            }
                        } else {
                            $entryOutput += "${prop}: $($entry.Properties[$prop])`n" # Add to output string
                        }
                    } else {
                        $entryOutput += "${prop}: Not found`n" # Add to output string
                    }
                }
            }

            # Write output to the text file
            Add-Content -Path $OutputFile -Value $entryOutput
            
            # Write to the terminal only if Silent switch is not set
            if (-not $Silent) {
                Write-Host $entryOutput
                Write-Host "--------------------------------------------------------------"
            }

            # Also write a separator line to the file
            Add-Content -Path $OutputFile -Value "--------------------------------------------------------------"
        }

        Write-Host "Results exported to $OutputFile" -not $Silent
    }
    catch {
        Write-Host "Error: $_"
    }
}

function Show-Help {
    Write-Host "Usage: LDAPSearch -LDAPQuery <query> [optional parameters]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "t-LDAPQuery: The LDAP query to execute. (Required)"
    Write-Host "t-PropertiesToLoad: Specify which attributes to retrieve. Default is 'samAccountName' and 'displayName'."
    Write-Host "t-SearchScope: Search scope for the query ('Base', 'OneLevel', or 'Subtree'). Default is 'Subtree'."
    Write-Host "t-Username: Optional username for authentication."
    Write-Host "t-Password: Optional password for authentication."
    Write-Host "t-OutputFile: File to export results. Default is 'LDAPResults.txt'."
    Write-Host "t-Verbose: Show detailed information during execution."
    Write-Host "t-ShowAllProperties: Display all attributes of each object found."
    Write-Host "t-Silent: Suppress terminal output, only write to file."
    Write-Host "t-Help: Show this help message."
    Write-Host ""
    Write-Host "Common LDAP Queries:"
    Write-Host "tGet all users: (samAccountType=805306368)"
    Write-Host "tGet all computers: (samAccountType=805306369)"
    Write-Host "tGet all groups: (objectCategory=group)"
    Write-Host "tGet a user by name: (samAccountName=username)"
    Write-Host ""
    Write-Host "Popular samAccountType Values:"
    Write-Host "t805306368: Regular User"
    Write-Host "t805306369: Computer"
    Write-Host "t805306370: Group"
    Write-Host "t268435456: Contact"
    Write-Host "t536870912: Domain"
    Write-Host ""
    Write-Host "Example Usages:"
    Write-Host "tLDAPSearch -LDAPQuery '(samAccountType=805306368)'"
    Write-Host "tLDAPSearch -LDAPQuery '(samAccountType=805306368)' -ShowAllProperties"
    Write-Host "tLDAPSearch -LDAPQuery '(samAccountType=805306368)' -PropertiesToLoad 'name', 'lastlogon'"
}
