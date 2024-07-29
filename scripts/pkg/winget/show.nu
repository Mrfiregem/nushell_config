export def main [
    id: string # ID of the package to view
    --short (-s) # Show brief information
] {
    let cmd = ^winget show -e --id $id | complete

    if $cmd.exit_code > 0 {
        print --stderr "Error running `winget show`"
        error make -u {msg: $cmd.stderr, help: "Make sure the ID is correct"}
    }

    if ($cmd.stdout | str trim | is-empty) {
        return {}
    }

    $cmd.stdout
    | str replace -ma '^([\w\s]+:)' $"(char nul)\n$1"
    | lines | str trim
    | skip until {|s| $s =~ '^\w'}
    | split list (char nul)
    | each { str join (char nul) }
    | parse -r `(?P<key>[^:]+):\s*(?P<value>.*)`
    | update value { str replace --all (char nul) (char nl) }
    | str trim | str snake-case key
    | where {|it| $it.value | is-not-empty }
    | transpose -r | into value | into record
    | if 'tags' in ($in | columns) { update tags { lines } } else {}
    | if 'description' in ($in | columns) { update description { str replace --all (char nl) ' ' } } else {}
    | if $short { select -i moniker version description homepage license } else {}
}
