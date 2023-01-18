######################
###Users in AD#####
##################

#New-ADOrganizationalUnit -Name "syncedO365" -Path "DC=f0r3,DC=LOCAL" -ProtectedFromAccidentalDeletion $False


#CSV - local_AD.csv


$ou_name = "syncedO365"
$ou_path = "DC=f0r3,DC=LOCAL"
$ou_full_path = "OU=$ou_name," + $ou_path


New-ADOrganizationalUnit -Name $ou_name -Path $ou_path -ProtectedFromAccidentalDeletion $False

#get the ADForest suffixes in an Powersehll array
$my_suffix2= Get-adforest | select UPNSuffixes -ExpandProperty UPNSuffixes

#looping throug the array with the index of the suffix

for ($counter=0; $counter -lt $my_suffix2.Length; $counter++){Write-host $counter,$my_suffix2[$counter]}

#read the input from user 
$my_choice = [int](Read-Host "Enter the number of the domain: ")


#save the suffix in a variable
$suffix = "@" + $my_suffix2[$my_choice]

#creating the password for the users
$pwd1 = ConvertTo-SecureString "1" -AsPlainText -Force

Import-Csv -Path "C:\Users\Administrator\Desktop\local_AD.csv"| Select-Object -Property `
@{Name="UserPrincipalName";Expression={$_.UserPrincipalName + $suffix}},
@{Name="Name";Expression={$_.DisplayName}},
@{Name="Country";Expression={$_.UsageLocation}} | foreach{New-ADUser -Name $_.Name `
-AccountPassword $pwd1 `
-UserPrincipalName $_.UserPrincipalName `
-Enabled $True `
-Country $_.Country `
-Path $ou_full_path
}


#Remove-ADOrganizationalUnit -Identity "OU=syncedO365,DC=f0r3,DC=LOCAL" -Recursive -Confirm:$False
