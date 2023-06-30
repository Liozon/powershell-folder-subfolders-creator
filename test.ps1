$Folders = ""
$Folders = Import-Csv FolderNames.csv -Delimiter ';'

$forbiddenElements = @("CON", "words", "<", ">", ":", '“', "/", "\", "|", "?", "*")

function CheckForbiddenElements {
    param (  
        [string[]]$ForbiddenElements,  
        [string[]]$InputArray  
    )

    $i = 1  
    foreach ($InputString in $InputArray) {   
        foreach ($ForbiddenElement in $ForbiddenElements) {
            if ($InputString.Contains($ForbiddenElement)) { 
                #Write-Output 
                return "'$ForbiddenElement' is not allowed on line $($i + 1), please remove this forbidden character in the CSV file."
            }   
        }
        $i++
    }  
    #Write-Output    
    return "Input array is valid."
} 

CheckForbiddenElements $forbiddenElements $Folders.Name 