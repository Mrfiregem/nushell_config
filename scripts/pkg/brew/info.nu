# Get information about a specific package
export def main [
    name: string
    --formula (-f) # Treat name as formula; ignore casks
    --cask (-c) # Treat name as cask; ignore formulae
    --full (-F) # Return all fields
] {
    # Generate command arguments
    let args = [
        (if $formula {'--formula'})
        (if $cask {'--cask'})
        '--json=v2'
        $name
    ] | compact

    # Run command and collect result & exit code
    let cmd = ^brew info ...$args | complete
    if $cmd.exit_code > 0 {
        error make -u {msg: $cmd.stderr, help: "Make sure the package name is correct"}
    }

    # Show user warning messages
    if ($cmd.stderr | is-not-empty) { $cmd.stderr | print --stderr }

    # Return an empty record if nothing was found
    if ($cmd.stdout | is-empty) { return {} }

    # Return value to pipeline
    echo $cmd.stdout | from json
    | rename -c {formulae: formula, casks: cask}
    | if ($in.formula | is-empty) { reject formula } else {}
    | if ($in.cask | is-empty) { reject cask } else {}
    | transpose type _
    | flatten --all
    | into record
    | if $full { return $in } else {
        if $in.type == 'formula' {
            select type name tap desc license versions homepage installed outdated pinned dependencies build_dependencies
        } else {
            select type token tap name desc version homepage installed outdated depends_on conflicts_with auto_updates
        }
    }
}
