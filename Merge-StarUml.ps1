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


Function Traverse {
    Param (
        [PSCustomObject] $JsonObject,
        [String] $ParentId
	)

    Write-Host "$($ParentId)" -ForegroundColor Green
    Write-Host "$($JsonObject)" -ForegroundColor Yellow

    If(($JsonObject -ne $Null) -And ($JsonObject.GetType().Name -eq "PSCustomObject")){
        $InnerParentId = $Null
        ForEach ($Prop in $JsonObject.PSObject.Properties) {
            If($Prop.Name -eq "_id"){
                 $InnerParentId = $Prop.Value
            }

            If($Prop.Name -eq "_parent"){
                 $JsonObject._parent.'$ref' = $ParentId
            }

            If(($Prop.Name -eq "ownedElements") -Or ($Prop.Name -eq "ownedViews") -Or ($Prop.Name -eq "subViews")){
                ForEach($Element in $Prop.Value) {
                   Traverse -JsonObject $Element -ParentId $InnerParentId
                }
            }            
        }
    }    
}

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

    # Add , at the end
    $DstFileContent[($AfterLine -1)] = $DstFileContent[($AfterLine -1)] + ","
    
    $OutputFileContent += , $DstFileContent[0 .. ($AfterLine -1)]
    $OutputFileContent += , $SubSrcFileContent
    $OutputFileContent += , $DstFileContent[$AfterLine .. ($DstFileContent.Length -1)]

    
    Set-Content -Path $OutFile -Value $OutputFileContent

    $OutputFileContent = Get-Content $OutFile

    $JsonObject = ($OutputFileContent | ConvertFrom-Json)

    Traverse -JsonObject $JsonObject -ParentId $Null

    $OutputFileContent = $JsonObject | ConvertTo-Json 
    
}
Catch {

}


