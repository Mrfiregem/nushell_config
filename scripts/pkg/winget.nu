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
export def search [query: string] {
    let out = (
        ^pwsh -NoProfile -Command $"Find-WinGetPackage -Query ($query) | ConvertTo-Json"
        | decode utf-8
        | from json
    )

    if ($out | is-empty) {
        return {}
    } else {
        $out
        | rename -b { str downcase }
        | move version id source --after name
        | reject isupdateavailable availableversions
        | update version {
            match $in { "Unknown" => { null }, _ => { $in } }
        }
    }
}
