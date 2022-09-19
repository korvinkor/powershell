Import-Module activedirectory
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

#определение констант
$Maildb = $null

#$Base = "OU=Users,OU=domain,DC=domain,DC=local"
$Base = "OU=Users,OU=domain,DC=domain,DC=local"

$cred = Get-Credential
###########################################################################
while($true){
Write-host "Введите имя" -ForegroundColor Green        #ввод учетных данных
$FirstName = Read-Host

Write-host "Введите Фамилию" -ForegroundColor Green
$LastName = Read-Host

$NameProfile = $LastName + " " + $FirstName

#функция транслитерации
function global:Translit {

  param([string]$inString)
  $Translit = @{

    [char]'а' = "a"
    [char]'А' = "A"
    [char]'б' = "b"
    [char]'Б' = "B"
    [char]'в' = "v"
    [char]'В' = "V"
    [char]'г' = "g"
    [char]'Г' = "G"
    [char]'д' = "d"
    [char]'Д' = "D"
    [char]'е' = "e"
    [char]'Е' = "E"
    [char]'ё' = "yo"
    [char]'Ё' = "Yo"
    [char]'ж' = "zh"
    [char]'Ж' = "Zh"
    [char]'з' = "z"
    [char]'З' = "Z"
    [char]'и' = "i"
    [char]'И' = "I"
    [char]'й' = "j"
    [char]'Й' = "J"
    [char]'к' = "k"
    [char]'К' = "K"
    [char]'л' = "l"
    [char]'Л' = "L"
    [char]'м' = "m"
    [char]'М' = "M"
    [char]'н' = "n"
    [char]'Н' = "N"
    [char]'о' = "o"
    [char]'О' = "O"
    [char]'п' = "p"
    [char]'П' = "P"
    [char]'р' = "r"
    [char]'Р' = "R"
    [char]'с' = "s"
    [char]'С' = "S"
    [char]'т' = "t"
    [char]'Т' = "T"
    [char]'у' = "u"
    [char]'У' = "U"
    [char]'ф' = "f"
    [char]'Ф' = "F"
    [char]'х' = "h"
    [char]'Х' = "H"
    [char]'ц' = "c"
    [char]'Ц' = "C"
    [char]'ч' = "ch"
    [char]'Ч' = "Ch"
    [char]'ш' = "sh"
    [char]'Ш' = "Sh"
    [char]'щ' = "sch"
    [char]'Щ' = "Sch"
    [char]'ъ' = ""
    [char]'Ъ' = ""
    [char]'ы' = "y"
    [char]'Ы' = "Y"
    [char]'ь' = ""
    [char]'Ь' = ""
    [char]'э' = "e"
    [char]'Э' = "E"
    [char]'ю' = "yu"
    [char]'Ю' = "Yu"
    [char]'я' = "ya"
    [char]'Я' = "Ya"

  }
  
  $outCHR=""
  foreach ($CHR in $inCHR = $inString.ToCharArray()){
    
    if ($Translit[$CHR] -cne $Null ){

      $outCHR += $Translit[$CHR]
      
    }else{

      $outCHR += $CHR
    }

  }

  Write-Output $outCHR

}

$Login = ($FirstName.Chars(0) + $LastName).ToLower()     #перевод логина в нормальный вид
$Login = Translit([string]$Login)




#Проверить логин
$aduser = $null
$aduser = Get-ADUser -Identity $Login -ErrorAction SilentlyContinue
while ($aduser -ne $null){
    $message = "Username " + $login + " exists"
    write-host $message -ForegroundColor Yellow
    write-host "Select a username: "
    $Login = read-Host

    #повтрная проверка
    $aduser = $null
    $aduser = Get-ADUser -Identity $Login -ErrorAction SilentlyContinue
}



#размещение пользователя в AD

Write-Host "0 Developers" -ForegroundColor Green

$choice = Read-Host 

#Заполнение дополнительных полей
Switch($choice){

 1{
    $Otdel = "Developers"
    $Path = "OU=Developers,OU=domain,DC=domain,DC=local" 
    $Maildb = "Developers"
    }
  default{
    Write-Host "Otdel is null"
    }
}


#Var отвечает за смену пароля при первом входе, Var2 пароль не имеет срока  
#mail - предложение создать почту

#UPN
$LoginD = $Login + "@domain.local"

#генератор паролей
$PassLength = 3                                              
function PassABC {
    return -join (1..$PassLength | % { [char[]]'abcdefghjkmnpqrstuvwxyz' | Get-Random })
}

function Pass123 {
    return -join (1..$PassLength | % { [char[]]'123456789' | Get-Random })
}

$PasswordPlain = (PassABC).ToUpper()+(Pass123)+(PassABC)

#преобразование пароля
$Password = ConvertTo-SecureString -String $PasswordPlain -AsPlainText -Force


#создание учетной записи
Try{

    #New-ADUser -FirstName $NameProfile -DisplayName $NameProfile -GivenName $Name -SurName $LastName -AccountPassword $Password -Enabled $true -UserPrincipalName $LoginD -SamAccountName $Login -Department $Otdel -Title $Dolgnost -Manager $Boss -ChangePasswordAtLogon $Var -PasswordNeverExpires $Var2 -Path $Base #создание учетки

    $NewUserAD = @{

      Name = $NameProfile
      DisplayName = $NameProfile
      GivenName = $FirstName
      SurName = $LastName
      AccountPassword = $Password
      Enabled = $true
      UserPrincipalName = $LoginD
      SamAccountName = $Login
      Department = $Otdel
      ChangePasswordAtLogon = $var
      PasswordNeverExpires = $Var2
      Path = $Path

    }

    New-ADUser @NewUserAD

}Catch{

    Write-host $Error
    break
}

#Присваивание групп доступа
if ($Otdel -eq $null) {

}else ($Otdel -eq "Developers"){

  Add-ADGroupMember -Identity "Developer_Coffe" -Members $Login
  Add-ADGroupMember -Identity "Developer_share" -Members $Login

}
