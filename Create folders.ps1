# Script developped by Julien Muggli - 2022
# In case of questions, please contact me on GitHub: https://github.com/Liozon

<# Clear the current windows and display credits #>
Clear-Host
Write-Host "Script developped by Julien Muggli - 2022" -ForegroundColor Cyan
Write-Host
Write-Host "In case of questions, please contact me on GitHub: https://github.com/Liozon" -ForegroundColor Cyan
Write-Host " "

# Import FoldersNames.csv into a variable called $Folders
# This will create an array of objects which have the Name and Type properties as defined in the CSV.
$Folders = Import-Csv FolderNames.csv -Delimiter ';';
$Folderscount = $Folders | Where-Object { $_.Type -eq 'Folder' };
$Subfolderscount = $Folders | Where-Object { $_.Type -eq 'Subfolder' };

# Promt to warn user prior to start script
## The following four lines only need to be declared once in your script.
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "The script will run and create $($Folderscount.length) folders and $($Subfolderscount.length) subfolders in the current directory."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No file creation will be carried out will be stopped."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "No file creation will be carried out will be stopped."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)

## Use the following each time your want to prompt the use
$title = "Creating folders and subfolders";
$message = @"
WARNING: this script will create $($Folderscount.length) folders and $($Subfolderscount.length) subfolders.
If folders or files already exist, they may be overwritten or the script will not run.
Would you like to run the file creation script ?
"@;


function startScript() {
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)

    switch ($result) {
        0 {
            Write-Host "Starting script..."
            createFolders
        }
        1 {
            Write-Host "Operation cancelled"
            closeScript
        }
        2 {
            Write-Host "Operation cancelled"
            closeScript
        }
    }
}

function createFolders() {
    for ($i = 0; $i -le ($Folders.length - 1); $i++) {
        #Write-Host $Folders[$i].Name
        if ($Folders[$i].Type -eq "Folder") {
            
            # Store the current object's Name in $ParentName.
            $ParentName = $Folders[$i].Name;
    
            # Create a new directory named $ParentName.
            New-Item "$ParentName" -ItemType Directory;
            <# Set-Location . #>
    
            Write-Host "Folder $ParentName created";
        }
        elseif ($Folders[$i].Type -eq "Subfolder") {
            
            # Store the current object's Name in $ChildName.
            $ChildName = $Folders[$i].Name;
    
            # Create a new subfolder in $ParentName called $ChildName.
            Set-Location -Path .\$ParentName;
            New-Item "$ChildName" -ItemType Directory
    
            Write-Host "Subfolder $ChildName in folder $ParentName created";
            Set-Location ..
        }
        else {
            Write-Host "An error occurred while reading the CSV file...." -ForegroundColor Red
        }
    }
    closeScript
}

<# Create a progress bar to whow the remaining time before closing windows #>
function closeScript() {
    Write-Host "This window will close automatically in 10 seconds..." -ForegroundColor Green
    $seconds = 10
    1..$seconds |
    ForEach-Object { $percent = $_ * 100 / $seconds; 
        Write-Progress -Activity "Closing" -Status "Closing window in $($seconds - $_) seconds..." -PercentComplete $percent;
        Start-Sleep -Seconds 1
    }
}

startScript