# Functions that replace subcommands
export use info.nu
export use list.nu
export use outdated.nu
export use search.nu

# Externs that wrap subcommands
export use install.nu

# Main arguments without a subcommand

# Display Homebrew's download cache
export extern '--cache' [
    name?: string # Display the file or directory used to cache app
    --os: string # Show cache file for the given operating system
    --arch: string # Show cache file for the given CPU architecture
    --build-from-source(-s) # Show the cache file used when building from source
    --force-bottle # Show the cache file used when pouring a bottle
    --bottle-tag # Show the cache file used when pouring a bottle for the given tag
    --HEAD # Show the cache file used when building from HEAD
    --formula # Only show cache files for formulae
    --cask # Only show cache files for casks
]

# Display Homebrew's Caskroom path
export extern '--caskroom' [
    cask?: string # display the location in the Caskroom where cask would be installed
]

# Display Homebrew's Cellar path. Default: "$(brew --prefix)/Cellar"
export extern '--cellar' [
    ...formula: string # Display location in Cellar where formula would be installed
]

# Summarise Homebrew's build environment as a plain list
export extern '--environment' [
    --shell: string # Generate list of environment variables for the specified shell (or 'auto')
    --plain # Generate plain output even when piped
]

# Display Homebrew's install path
export extern '--prefix' [
    ...formula: string # Display the location where formula is or would be installed
    --unbrewed # List files in Homebrew's prefix not installed by Homebrew
    --installed # Outputs nothing and returns a failing status code if formula is not installed
]

# Display where Homebrew's Git repository is located
export extern '--repository' [
    ...tap: string # Display where tap user/repo's directory is located.
]

export extern main [
    --version(-v) # Print the version numbers of Homebrew, Homebrew/homebrew-core and Homebrew/homebrew-cask
]
