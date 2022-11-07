# Script developped by Julien Muggli - 2022 - v1.1
# In case of questions, please contact me on GitHub: https://github.com/Liozon
$ScriptVersion = 1.1

# Clear the current windows and display credits
Clear-Host
Write-Host "Script developped by Julien Muggli - 2022 - v$ScriptVersion" -ForegroundColor Cyan
Write-Host
Write-Host "In case of questions, please contact me on GitHub: https://github.com/Liozon" -ForegroundColor Cyan
Write-Host " "

# Import the CSV file into a variable
$Folders = Import-Csv FolderNames.csv -Delimiter ';'

# Count how many folders and subfolders are declared in file
$Folderscount = $Folders | Where-Object { $_.Type -eq 'Folder' }
$Subfolderscount = $Folders | Where-Object { $_.Type -eq 'Subfolder' }

# Promt to warn user prior to start script
# Call to action
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "The script will run and create $($Folderscount.length) folders and $($Subfolderscount.length) subfolders in the current directory."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No file creation will be carried out will be stopped."
$cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "No file creation will be carried out will be stopped."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)

# Prompt message
$title = "Creating folders and subfolders"
$message = @"
WARNING: this script will create $($Folderscount.length) folders and $($Subfolderscount.length) subfolders.
If folders or files already exist, they may be overwritten or the script will not run.
Would you like to run the file creation script ?
"@

# Beginning of the script
function startScript() {
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)

    switch ($result) {
        0 {
            # Feedback in console
            Write-Host "Starting script..."

            # Call function
            createFolders
        }
        1 {
            # Feedback in console
            Write-Host "Operation cancelled"

            # Call function
            closeScript
        }
        2 {
            # Feedback in console
            Write-Host "Operation cancelled"

            # Call function
            closeScript
        }
    }
}

# Function to create the folders, based on data in CSV file
function createFolders() {
    for ($i = 0; $i -le ($Folders.length - 1); $i++) {

        # Check if the line is a 'Folder' type
        if ($Folders[$i].Type -eq "Folder") {
            
            # Store the current object's Name in $ParentName.
            $ParentName = $Folders[$i].Name
    
            # Create a new directory named $ParentName.
            New-Item "$ParentName" -ItemType Directory
    
            Write-Host "Folder $ParentName created"
        }
        # Check if the line is a 'Subfolder' type
        elseif ($Folders[$i].Type -eq "Subfolder") {
            
            # Store the current object's Name in $ChildName.
            $ChildName = $Folders[$i].Name
    
            # Create a new subfolder in $ParentName called $ChildName.
            Set-Location -Path .\$ParentName
            New-Item "$ChildName" -ItemType Directory
    
            # Feedback in console
            Write-Host "Subfolder $ChildName in folder $ParentName created"

            # Go to the folder on upper level
            Set-Location ..
        }
        else {
            # Feedback in console with the error line
            Write-Host "An error occurred while reading the CSV file on line $($i+2)...." -ForegroundColor Red
        }
    }

    # CLose the script after loop
    closeScript
}

# Create a progress bar to whow the remaining time before closing windows
function closeScript() {
    # Feedback in console
    Write-Host "This window will close automatically in 10 seconds..." -ForegroundColor Green

    # Visual loop to create the countown in console
    $seconds = 10
    1..$seconds |
    ForEach-Object { $percent = $_ * 100 / $seconds
        Write-Progress -Activity "Closing" -Status "Closing window in $($seconds - $_) seconds..." -PercentComplete $percent
        Start-Sleep -Seconds 1
    }
}

# Script initiator
startScript