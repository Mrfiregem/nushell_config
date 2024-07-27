def upgradable [] {
    let cmdline = [
        'Get-WinGetPackage'
        'Where-Object IsUpdateAvailable'
        'ConvertTo-Json'
    ] | str join ' | '

    let cmd = ^pwsh -NoProfile -Command $cmdline | complete

    if $cmd.exit_code > 0 {
        print --stderr "Error getting winget packages"
        error make -u {msg: $cmd.stderr}
    }

    if ($cmd.stdout | str trim | is-empty) { return [] }

    $cmd.stdout | from json
    | insert  available { get AvailableVersions | first }
    | rename -c {InstalledVersion: Version}
    | rename -b { str downcase }
    | select name id version available source
}

export def main [
    --upgrade-available(-u)
] {
    if $upgrade_available {
        return (upgradable)
    } else {
        let select_fields = [
            'Name'
            'Id'
            '@{name='Version'; expr={$_.InstalledVersion}}'
            'Source'
        ] | str join ','
        let cmdline = [
            'Get-WinGetPackage'
            $'Select-Object ($select_fields)'
            'ConvertTo-Json'
        ] | str join ' | '

        let cmd = ^pwsh -NoProfile -Command $cmdline | complete

        if $cmd.exit_code > 0 {
            print --stderr "Error getting winget packages"
            error make -u {msg: $cmd.stderr}
        }
    
        if ($cmd.stdout | str trim | is-empty) { return [] }

        $cmd.stdout | from json
        | rename -b { str downcase }
    }
} 