
$namesearchfolder = Read-Host


$folderrar = Get-ChildItem -Path $namesearchfolder -Include "*.rar" -Depth | select-object basename,fullname
$folderzip = Get-ChildItem -Path $namesearchfolder -Include "*.zip" -Depth | select-object basename,fullname
$foldername =  Get-ChildItem -Path $namesearchfolder -Attributes "Directory" -Depth | select-object basename,fullname




$delzip = Compare-Object $foldername.basename $folderzip.basename -ExcludeDifferent -IncludeEqual
$delrar = Compare-Object $foldername.basename $folderrar.BaseName -ExcludeDifferent -IncludeEqual


$delzip.inputobject | ForEach-Object {
    $namezip = $_ + ".zip"
    $var = Get-ChildItem -Path $namesearchfolder -Filter $namezip -Depth 3  
    Remove-Item -Path $var.FullName -ErrorAction SilentlyContinue

}


$delrar.inputobject | ForEach-Object {
    $namerar = $_ + ".rar"
    $var1 = Get-ChildItem -Path $namesearchfolder -Filter $namerar -Depth 3  
    Remove-Item -Path $var1.Fullname -ErrorAction SilentlyContinue
     
}