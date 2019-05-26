param($SourceFolderPath,$OutputFolderPath,$LanguageCode = "kan")
Function Get-Folder($rootFolder,$DialogBoxTitleMessage)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $DialogBoxTitleMessage
    $foldername.SelectedPath = $rootFolder

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}
if($OutputFolderPath.length -gt 3 -and (!(test-path $OutputFolderPath)))
{
    new-item -Path $OutputFolderPath -ItemType Directory
}
if(!($SourceFolderPath -and $OutputFolderPath))
{
    $rootFolderForSelector = "$env:userprofile\desktop"
    $SourceFolderPath = Get-Folder -rootFolder $rootFolderForSelector -DialogBoxTitleMessage "Please select Source folder with images"
    $OutputFolderPath = Get-Folder -rootFolder $rootFolderForSelector -DialogBoxTitleMessage "Please select folder to save the converted files"
}
if($SourceFolderPath -and $OutputFolderPath)
{
    $filterFiles = "*.jp*g","*.png","*.bmp"

    foreach($filterString in $($filterFiles | select -Unique))
    {
        Write-Information -MessageData "Getting files of type $filterString" -InformationAction Continue
        $inputFiles += Get-ChildItem $SourceFolderPath -Filter $filterstring
    }
    $totalFiles = $inputfiles.Count
    $count = 0;
    $inputFiles | ForEach-Object{
        $inputFileFullName = $_.FullName
        $outputfileName = Join-Path $OutputFolderPath "$($_.BaseName)"
        try {
            #Write-Information -MessageData "Converting file $inputFileFullName" -InformationAction Continue
            $count++
            $perc = (100*$count)/$totalfiles
            Write-Progress -Activity "OCR conversion" -PercentComplete $perc -Status "$perc %" -currentoperation "Converting $inputfilefullname"
            start-process tesseract.exe -argumentlist  $inputFileFullName,$outputfileName,"-l",$LanguageCode -nonewwindow -wait

        }
        catch {
            Write-Warning "Error while converting $inputFileFullName"
            Write-Warning $_
        }
    } 
}
