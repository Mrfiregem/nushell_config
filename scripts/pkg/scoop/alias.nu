use listutils/lists.nu "into list"

# List user-defined aliases
export def list [--verbose(-v)] {
    let aliases = (
        ^pwsh -NoProfile -Command 'scoop alias list -v 6>$null | ConvertTo-Json'
        | from json | default {} | rename -b { str downcase }
    )

    if $verbose {
        return $aliases
    }
    $aliases | reject summary
}

# Completer for alias names
def "nu-complete scoop aliases" [] { list | get name | into list }

# Create a new scoop alias
export extern add [
    name: string # Name of the command
    command: string # Actual scoop command being run
    description?: string # Description shown in `scoop alias list --verbose`
]

# Remove a user alias
export extern rm [
    name: string@"nu-complete scoop aliases"
]
