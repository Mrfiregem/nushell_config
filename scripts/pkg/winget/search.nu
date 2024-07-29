# Search all available packages for your query
export def main [
    query: string # The text to search
    --id          # Filter results by id
    --name        # Filter results by name
    --moniker     # Filter results by moniker
    --tag         # Filter results by tag
] {
    # Determine if more than one flag is set
    if ([$id $name $moniker $tag] | where {|bool| $bool} | length) > 1 {
        error make -u {msg: 'Flags are mutually exclusive'}
    }

    # Arguments for the Select-Object command
    let search_flags = if $id {
        '-Id'
    } else if $name {
        '-Name'
    } else if $moniker {
        '-Moniker'
    } else if $tag {
        '-Tag'
    } else {
        []
    } | append $query


    let selectobj_list = [
        # This is needed since direct conversion results in decode errors for some reason
        `@{name='Name'; expr={[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($_.Name))}}`
        Id
        Version
        Source
    ] | str join ', '

    let cmdline = [
        $'Find-WinGetPackage ($search_flags | str join " ")'
        $'Select-Object -Property ($selectobj_list)'
        'ConvertTo-Json'
    ] | str join ' | '

    let cmd = ^pwsh -NoProfile -Command $cmdline | complete
    if ($cmd.exit_code > 0) or ($cmd.stderr | is-not-empty) {
        error make -u {msg: "Error running 'winget search'"}
    }

    if ($cmd.stdout | is-empty) { return [] }
    
    $cmd.stdout | from json
    | rename -b { str snake-case }
    # Decode the encoded name to bypass conversion error
    | update name { decode base64 --binary | decode }
}
