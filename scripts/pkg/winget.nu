# List installed packages
export def list [--upgradable (-u)] {
    let cmd = ^pwsh -NoProfile -Command `Get-WinGetPackage | ConvertTo-Json` | complete
    if $cmd.exit_code > 0 {
        error make -u {msg: 'error getting lit of installed packages'}
    }

    let tbl = $cmd.stdout | from json | rename -c {InstalledVersion: version, AvailableVersions: avail} | rename -b { str downcase }

    if $upgradable {
        $tbl | rename -c {avail: latest, version: current}
        | where isupdateavailable
        | update latest { first }
        | reject isupdateavailable
        | move current latest --before source
    } else {
        $tbl
        | reject isupdateavailable avail
        | move version --after name
    }
}

# Search for available packages matching your query
export def search [...query: string] {
    # Exit if no query provided
    if ($query | is-empty) {
        error make {
            msg: 'Missing search query'
            label: {text: 'Expected value', span: (metadata $query).span}
        }
    }

    # Collect json output from Powershell module
    let cmd = [
        $"Find-WingetPackage -Query ($query | str join ',') 6>$null"
        'ConvertTo-Json'
    ]
    let out = ^pwsh -NoProfile -Command ($cmd | str join ' | ') | complete

    # If there's no output, return an empty list
    if ($out.stdout | is-empty) {
        return []
    }

    # Otherwise, return a table
    $out.stdout | decode utf-8 | from json
    | rename -b { str downcase }
    | move version id source --after name
    | reject isupdateavailable availableversions
    | update version { if $in == "Unknown" { null } else { $in } }
}
