# Functions that replace existing subcommands
export use search.nu
export use list.nu
export use show.nu

def "complete scopes" [] { [user, machine] }
def "complete authmodes" [] { [silent, silentPreferred, interactive] }

# Define externs for the other subcommands
export extern main [
    --version(-v) # Display the version of the tool
    --info # Display general info of the tool
    --help(-?) # Shows help about the selected command
    --wait # Prompts the user to press any key before exiting
    --logs # Open the default logs location
    --verbose # Enables verbose logging for winget
    --nowarn # Suppresses warning outputs
    --disable-interactivity # Disable interactive prompts
    --proxy # Set a proxy to use for this execution
    --no-proxy # Disable the use of proxy for this execution
]

# Installs the given package
export extern install [
    ...query: string
    --manifest(-m): path # The path to the manifest of the package
    --id # Filter results by id
    --name # Filter results by name
    --moniker # Filter results by moniker
    --version(-v): string # Use the specified version; default is the latest version
    --source(-s): string # Find package using the specified source
    --scope: string@"complete scopes" # Select install scope (user or machine)
    --architecture(-a): string # Select the architecture
    --installer-type: string # Select the installer type
    --exact(-e) # Find package using exact match
    --interactive(-i) # Request interactive installation; user input may be needed
    --silent(-h) # Request silent installation
    --locale: string # Locale to use (BCP47 format)
    --log(-o): path # Log location (if supported)
    --custom: string # Arguments to be passed on to the installer in addition to the defaults
    --override: string # Override arguments to be passed on to the installer
    --location(-l): path # Location to install to (if supported)
    --ignore-security-hash # Ignore the installer hash check failure
    --allow-reboot # Allows a reboot if applicable
    --skip-dependencies # Skips processing package dependencies and Windows features
    --ignore-local-archive-malware-scan # Ignore the malware scan performed as part of installing an archive type package from local manifest
    --dependency-source: string # Find package dependencies using the specified source
    --accept-package-agreements # Accept all license agreements for packages
    --no-upgrade # Skips upgrade if an installed version already exists
    --header: string # Optional Windows-Package-Manager REST source HTTP header
    --authentication-mode: string@"complete authmodes" # Specify authentication window preference (silent, silentPreferred or interactive)
    --authentication-account: string # Specify the account to be used for authentication
    --accept-source-agreements # Accept all source agreements during source operations
    --rename(-r): string # The value to rename the executable file (portable)
    --uninstall-previous # Uninstall the previous version of the package during upgrade
    --force # Direct run the command and continue with non security related issues
    --help(-?) # Shows help about the selected command
    --wait # Prompts the user to press any key before exiting
    --logs # Open the default logs location
    --open-logs # Open the default logs location
    --verbose # Enables verbose logging for winget
    --verbose-logs # Enables verbose logging for winget
    --nowarn # Suppresses warning outputs
    --ignore-warnings # Enables verbose logging for winget
    --disable-interactivity # Disable interactive prompts
    --proxy: string # Set a proxy to use for this execution
    --no-proxy # Disable the use of proxy for this execution
]

# Manage sources of packages
export extern source []

# Shows and performs available upgrades
export extern upgrade []

# Uninstalls the given package
export extern uninstall []

# Helper to hash installer files
export extern hash []

# Validates a manifest file
export extern validate []

# Open settings or set administrator settings
export extern settings []

# Shows the status of experimental features
export extern features []

# Exports a list of the installed packages
export extern export []

# Installs all the packages in a file
export extern import []

# Manage package pins
export extern pin []

# Configures the system into a desired state
export extern configure []

# Downloads the installer from a given package
export extern download []

# Repairs the selected package
export extern repair []