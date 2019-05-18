$FilterComputers = "(&((objectcategory=computer)(name=$env:computername)(!operatingsystem=Windows Server*)(!name=ESX*)))"
$ErrorActionPreference = "SilentlyContinue"
$strName = $env:username
$strComputerName = $env:ComputerName
$LastLogon=Get-Date -format "dd.MM.yyy HH:mm:ss"
$Comp=(([adsisearcher]"$FilterComputers").findall()).properties
$OS = $Comp.operatingsystem
$CompOU = $Comp.distinguishedname
$byManaged =  $Comp.managedby
if ($byManaged)	{ $byManaged=$byManaged.Split(",") 
                  $byManaged=$byManaged.Replace("CN=", "")
                  $byManaged=$byManaged[0]
                  } else {$byManaged = "Владелец компьютера не назначен ТП"}
#$LastLogon + ","  + $strName + "," + $strComputerName 
$User = (([adsisearcher]"(&(objectCategory=User)(samaccountname=$strName))").findall()).properties
$UserName = $User.displayname
$UserDepartment=$User.department
$UserCompany=$User.company	
if (( $OS -notlike "*Server*") -and ( $CompOU -notlike "*OU=Servers*")) {
	$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	$root = $dom.GetDirectoryEntry()
	$search = [System.DirectoryServices.DirectorySearcher]$root
	$search.Filter = "(cn=$strComputerName)"
	$result = $search.FindOne()
	$ChangeComp=[ADSI]$result.Path
	if (($UserName -ne "")  -and  ($LastLogon -ne  "" )) {
		$descr = "Logged on: "   +  $UserName  + " " +  $LastLogon    #, "  ManagedBy" $byManaged
		$ChangeComp.UserPrincipalName=$descr
	}
	if (($byManaged -ne "") -and ($byManaged -ne $null)){ 
		$ChangeComp.Description=$byManaged 
	}
	if (($UserDepartment -ne "") -and ($UserDepartment -ne $null)){ 
		$ChangeComp.Department=$UserDepartment
	}
	if (($UserCompany -ne "") -and ($UserCompany -ne $null)) { 
		$ChangeComp.Company=$UserCompany
	}
	$ChangeComp.SetInfo()
 }