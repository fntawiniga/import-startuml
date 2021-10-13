<#
.SYNOPSIS
This script will merge two StarUML files

.DESCRIPTION
-The scripts merges two StarUML files in a non destructive way as the results is saved in a new file
-The scripts fixes the references in the new file

Sample execution command
  .\Merge-StarUml.ps1 -SrcFile <file1.mdj> -FromLine <fromLine> -ToLine <toLine> -DstFile <file2.mdj> -AfterLine <afterLine> -OutFile <file3.mdj>
#>

Param
(
    [String]$SrcFile = $(Throw "Source File (-SrcFile) Required"),
    [Int]$FromLine = $(Throw "Starting at line number (-FromLine) Required"),
    [Int]$ToLine = $(Throw "Ending at line number (-ToLine) Required"),
    [String]$DstFile = $(Throw "Destination File (-DstFile) Required"),
    [Int]$AfterLine = $(Throw "After the line number (-AfterLine) Required"),    
    [String]$OutFile = $(Throw "Output File (-DstFile) Required")
)

$SrcFileContent = Get-Content $SrcFile

If (($FromLine -lt 1) -Or ($FromLine -gt $SrcFileContent.Length)) {
    Throw "FromLine = $($FromLine) is not in the range of the lines of the Source File $($SrcFile) [1 .. $($SrcFileContent.Length)]"
}

If (($ToLine -lt 1) -Or ($ToLine -gt $SrcFileContent.Length)) {
    Throw "ToLine = $($ToLine) is not in the range of the lines of the Source File $($SrcFile) [1 .. $($SrcFileContent.Length)]"
}

$DstFileContent = Get-Content $DstFile
If (($AfterLine -lt 0) -Or ($AfterLine -gt $DstFileContent.Length)) {
    Throw "AfterLine = $($AfterLine) is not in the range of the lines of the Destination File $($DstFile) [1 .. $($DstFileContent.Length)]"
}

Try {
    # Merge
    $SubSrcFileContent = $SrcFileContent[($FromLine - 1) .. ($ToLine -1)]
    $OutputFileContent = @()
    
    $OutputFileContent += , $DstFileContent[0 .. ($AfterLine -1)]
    $OutputFileContent += , $SubSrcFileContent
    $OutputFileContent += , $DstFileContent[$AfterLine .. ($DstFileContent.Length -1)]
    
    Set-Content -Path $OutFile -Value $OutputFileContent
}
Catch {

}


