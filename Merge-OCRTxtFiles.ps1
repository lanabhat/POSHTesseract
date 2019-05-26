param($SourceFolderPath,$OutputFolderPath,$MergedFileName = "MergedFile")
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
    $filterFiles = "*.txt"

    foreach($filterString in $filterFiles)
    {
        Write-Information -MessageData "Getting files of type $filterString" -InformationAction Continue
        $inputFiles += Get-ChildItem $SourceFolderPath -Filter $filterstring
    }
    $outputfileName = Join-Path $OutputFolderPath "$mergedfilename.txt"
    $totalFiles = $inputfiles.Count
    $count = 0;
    $mergedContent = ""
    $inputFiles | ForEach-Object{
        $inputFileFullName = $_.FullName        
        try {
            #Write-Information -MessageData "Converting file $inputFileFullName" -InformationAction Continue
            $count++
            $perc = (100*$count)/$totalfiles
            Write-Progress -Activity "Mergin in progress" -PercentComplete $perc -Status "$perc %" -currentoperation "Merging $inputfilefullname"
            $currentFileContent = Get-Content -Path $inputFileFullName
            $mergedContent += $currentFileContent + "
            __________________________________________END OF PAGE__________________________________________
            
            "
        }
        catch {
            Write-Warning "Error while merging $inputFileFullName"
            Write-Warning $_
        }
    } 

    $mergedContent | Out-File $outputfileName -Encoding default
}
