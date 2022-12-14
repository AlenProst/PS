#####Create multiple users in AD for testing####

#get the ADForest suffixes in an Powersehll array
$my_suffix2= Get-adforest | select UPNSuffixes -ExpandProperty UPNSuffixes

#looping throug the array with the index of the suffix

for ($counter=0; $counter -lt $my_suffix2.Length; $counter++){Write-host $counter,$my_suffix2[$counter]}

#read the input from user 
$my_choice = [int](Read-Host "Enter the number of the domain: ")


#save the suffix in a variable
$suffix = $my_suffix2[$my_choice]

$val = [int](Read-Host "Enter number of test users")
$count_of_users = 0
$name_of_user = Read-Host "Name of test user"
while($count_of_users -ne $val)
{
    $count_of_users++
    
    $created_user = $name_of_user + $count_of_users.ToString()
   
    $pwd1 = ConvertTo-SecureString "1" -AsPlainText -Force
    $upn_suffix = $created_user + $suffix
    New-ADUser `
        -Name $created_user `
        -AccountPassword $pwd1 `
	    -UserPrincipalName $upn_suffix `
        -Title "CEO" `
        -State "California" `
        -City "San Francisco" `
        -Description "Test Account Creation" `
        -Department "Engineering" `
        -Enabled $True
Write-Host $created_user "created"
#-Path "OU=synced_user,DC=f0r3,DC=local" - given as an example
}
