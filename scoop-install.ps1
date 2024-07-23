# Setting default installation path
$defaultPath = "C:\Applications\Scoop"

# Prompt user for installation path
$installPath = Read-Host -Prompt "Please enter the installation path or press Enter to use the default path $defaultPath"

# Use default path if no input
if (-not $installPath) {
    $installPath = $defaultPath
}

# Open folder selector if path is not set
if (-not $installPath) {
    $folderBrowser = New-Object -ComObject Shell.Application
    $selectedFolder = $folderBrowser.BrowseForFolder(0, "Please select the installation path", 0)
    if ($selectedFolder -ne $null) {
        $installPath = $selectedFolder.Self.Path
    }
}

# Set environment variable
try {
    $env:SCOOP = $installPath
    [Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
    Write-Host "The installation path has been set to: $installPath"
} catch {
    Write-Error "Failed to set environment variable: $_"
    exit 1
}

# Set PowerShell execution policy for the current session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Set default install proxy
$defaultInstallProxy = "http://127.0.0.1:7890"

# Prompt user for proxy settings
$proxy = Read-Host -Prompt "Please enter your proxy settings or press Enter to use the default install settings $defaultInstallProxy"

# Use default proxy if no input
if (-not $proxy) {
    $proxy = $defaultInstallProxy
}

# Function to install Scoop with retry logic
function Install-Scoop {
    param (
        [string]$proxy
    )
    $maxRetries = 3
    $retryCount = 0
    $success = $false

    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            iex "& {$(irm -Proxy $proxy -Uri 'https://get.scoop.sh')} -RunAsAdmin"
            $success = $true
        } catch {
            $retryCount++
            Write-Warning "Attempt to install Scoop failed. Retry $retryCount/$maxRetries ..."
            Start-Sleep -Seconds 5
        }
    }

    if (-not $success) {
        throw "Installation of Scoop failed. Please check network connection and proxy settings."
    }
}

# Install Scoop
Install-Scoop -proxy $proxy

# Set default scoop proxy
$defaultScoopProxy = "127.0.0.1:7890"

# Prompt user for proxy settings
$proxy = Read-Host -Prompt "Please enter your proxy settings or press Enter to use the default scoop settings $defaultScoopProxy"

# Use default proxy if no input
if (-not $proxy) {
    $proxy = $defaultScoopProxy
}

# Configure Scoop proxy
scoop config proxy $proxy
Write-Host "The proxy is set to: $proxy"

# Install Git
scoop install git

# Add common buckets
$scoopBuckets = @(
    "versions",
    "extras",
    "nonportable",
    "java",
    @{ Name = "dorado"; URL = "https://github.com/chawyehsu/dorado" }
    @{ Name = "MorFans-apt"; URL = "https://github.com/Paxxs/Cluttered-bucket.git" }
    @{ Name = "spoon"; URL = "https://github.com/FDUZS/spoon.git" }
    @{ Name = "scoop-bucket-lee"; URL = "https://github.com/zuluion/scoop-bucket-lee" }
)

foreach ($bucket in $scoopBuckets) {
    if ($bucket -is [string]) {
        # Add default buckets
        try {
            scoop bucket add $bucket
            Write-Host "Successfully added bucket: $bucket"
        } catch {
            Write-Warning "Failed to add bucket: $bucket. Error: $_"
        }
    } elseif ($bucket -is [hashtable]) {
        # Add buckets with URLs
        try {
            scoop bucket add $bucket.Name $bucket.URL
            Write-Host "Successfully added bucket: $($bucket.Name)"
        } catch {
            Write-Warning "Failed to add bucket: $($bucket.Name). Error: $_"
        }
    }
}


# Display added buckets
Write-Host "Added bucket list:"
scoop bucket list

Write-Host "To delete unwanted buckets, use the following command:"
Write-Host "scoop bucket remove [bucket_name]"

# Install optimized search tool
scoop install scoop-search

# Clear Scoop cache
scoop cache rm *

Write-Host "Scoop installation is complete!"
Write-Host "Next, you can install applications using the following command:"
Write-Host "scoop install [app_name]"
Write-Host "Replace [app_name] with the name of the application you want to install."

Write-Host "To list all available applications, use the following command:"
Write-Host "scoop search [app_name]"
Write-Host "Optimized search tools are also available, e.g., scoop-search [app_name]."
Write-Host "For more help, visit https://scoop.sh/ or https://github.com/lukesampson/scoop/wiki for more information."

# Wait for user to press Enter before closing
Write-Host "Press the Enter key to close the window."
Read-Host
