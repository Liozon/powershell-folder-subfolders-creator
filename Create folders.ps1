# Script developped by Julien Muggli - 2022 - v2.0
# In case of questions, please contact me on GitHub: https://github.com/Liozon

# Global variables
$ScriptVersion = 2.0
$Folders = ""
$Folderscount = 0
$Subfolderscount = 0
[bool] $StopScript = $false

# Clear the current windows and display credits
Clear-Host
Write-Host "Script developped by Julien Muggli - 2022/2023 - v$ScriptVersion" -ForegroundColor Cyan
Write-Host
Write-Host "In case of questions, please contact me on GitHub: https://github.com/Liozon" -ForegroundColor Cyan
Write-Host " "

# Beginning of script
function startScript() {
    # Import the CSV file into a variable
    $Folders = Import-Csv FolderNames.csv -Delimiter ';'

    # Count how many folders and subfolders are declared in file
    $Folderscount = $Folders | Where-Object { $_.Type -eq 'Folder' }
    $Subfolderscount = $Folders | Where-Object { $_.Type -eq 'Subfolder' }

    for ($i = 0; $i -le ($Folders.length - 1); $i++) {

        # Check if the line is a 'Folder' type
        if ($Folders[$i].Type -eq "Folder") {

            # Check if name contains illegal characters
            if (checkValidFileName $Folders[$i].Name) {
            }
            else {
                Write-Host "The folder '" $Folders[$i].Name "' (line $($i+2)) contains invalid characters. Please avoid using illegal characters and restart the script." -ForegroundColor Red
                $StopScript = $true
                #closeScript
            }
        
        }
        # Check if the line is a 'Subfolder' type
        elseif ($Folders[$i].Type -eq "Subfolder") {
            # Check if name contains illegal characters
            if (checkValidFileName $Folders[$i].Name) {
            }
            else {
                Write-Host "The subfolder '" $Folders[$i].Name "' (line $($i+2)) contains invalid characters. Please avoid using illegal characters and restart the script." -ForegroundColor Red
                $StopScript = $true
            }
        }
        else {
            # Feedback in console with the error line
            Write-Host "An error occurred while reading the CSV file on line $($i + 2). Please specify 'Folder' or 'Subfolder'...." -ForegroundColor Red
            $StopScript = true
        }
    }
    if (!$StopScript) {
        userPrompt
    }
    else {
        Write-Host
        Write-Host
        stopScript
    }
   
}

# User prompt
function userPrompt() {
    # Promt to warn user prior to start script
    # Call to action
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "The script will run and create $($Folderscount.length) folders and $($Subfolderscount.length) subfolders in the current directory."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No file creation will be carried out will be stopped."
    $cancel = New-Object System.Management.Automation.Host.ChoiceDescription "&Cancel", "No file creation will be carried out will be stopped."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $cancel)

    # Prompt message
    $title = "Script to create folders and subfolders"
    $message = @"
WARNING: this script will create $($Folderscount.length) folders and $($Subfolderscount.length) subfolders.
If folders or files already exist, they may be overwritten or the script will not run.
Would you like to run the file creation script ?
"@

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
            stopScript
        }
        2 {
            # Feedback in console
            Write-Host "Operation cancelled"

            # Call function
            stopScript
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
            Write-Host "An error occurred while reading the CSV file on line $($i + 2). Please specify 'Folder' or 'Subfolder'...." -ForegroundColor Red
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
    ForEach-Object {
        $percent = $_ * 100 / $seconds
        Write-Progress -Activity "Closing" -Status "Closing window in $($seconds - $_) seconds..." -PercentComplete $percent
        Start-Sleep -Seconds 1
    }
}

# Function to check if file is a valid name
function checkValidFileName {
    param([string]$FileName)

    $IndexOfInvalidChar = $FileName.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars())

    # IndexOfAny() returns the value -1 to indicate no such character was found
    return $IndexOfInvalidChar -eq -1
}

# Function to stop the script
function stopScript {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

# Script initiator
startScript