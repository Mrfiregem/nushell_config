export def main [
    id: string # ID of the package to view
] {
    let cmd = ^winget show -e --id $id | complete

    if $cmd.exit_code > 0 {
        print --stderr "Error running `winget show`"
        error make -u {msg: $cmd.stderr}
    }

    if ($cmd.exit_code > 0) or ($cmd.stdout | str trim | is-empty) {
        return {}
    }

    $cmd.stdout
    | lines | skip 1 |str join (char nl)
    | from yaml
    | rename -b { str downcase }
    | update installer {
        rename -b { str downcase }
        | rename -c {
            'installer type': 'type'
            'installer locale': 'locale'
            'installer url': 'url'
            'installer sha256': 'sha256'
            'release date': 'released'
            'offline distribution supported': 'supportsOffline'
        } | into datetime released
    } | rename -c {
        moniker: 'name'
        'release notes url': 'notes'
    } | select name publisher version license homepage notes tags installer
    | update tags { split row ' ' }
}