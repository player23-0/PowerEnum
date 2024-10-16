# PowerEnum
AD enumeration using Powershell and .NET classes

## Overview
The `LDAPSearch` PowerShell script allows you to perform LDAP queries against Active Directory and retrieve specified attributes of user accounts, computers, and groups. The results can be displayed in the terminal or saved to a text file.

## Features
- Perform LDAP queries with customizable filters.
- Retrieve specific or all properties of queried objects.
- Output results to a text file or display in the terminal.
- Verbose mode for detailed execution information.
- Silent mode to suppress terminal output.

## Installation
To use this script, ensure you have PowerShell installed on your system. You can run the script directly in PowerShell or save it as a `.ps1` file.

## Usage

### Parameters
- `-LDAPQuery` (Required): The LDAP query string to execute.  
  Example: `(samAccountType=805306368)` to get all users.

- `-PropertiesToLoad` (Optional): An array of attributes to retrieve.  
  Default: `samAccountName`, `lastlogon`.

- `-SearchScope` (Optional): The search scope for the query.  
  Options: `Base`, `OneLevel`, `Subtree` (default).

- `-Username` (Optional): Username for authentication when querying a secured Active Directory.

- `-Password` (Optional): Password for the specified username.

- `-OutputFile` (Optional): File to export results.  
  Default: `LDAPResults.txt`.

- `-Verbose` (Optional): Show detailed information during execution.

- `-ShowAllProperties` (Optional): Display all available attributes of each object found.

- `-Silent` (Optional): Suppress terminal output; results will only be written to the specified output file.

- `-Help` (Optional): Displays help information about the script and its usage.

### Common LDAP Queries
- Get all users: `(samAccountType=805306368)`
- Get all computers: `(samAccountType=805306369)`
- Get all groups: `(objectCategory=group)`
- Get a user by name: `(samAccountName=username)`

### Popular samAccountType Values
- `805306368`: Regular User
- `805306369`: Computer
- `805306370`: Group
- `268435456`: Contact
- `536870912`: Domain

### Example Usages
1. **Basic Query to Get All Users**:
   ```powershell
   LDAPSearch -LDAPQuery '(samAccountType=805306368)'
