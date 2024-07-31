use listutils/tables.nu "compact column"

# === Package data commands ===

export use alias.nu
export use bucket.nu
export use cache.nu
export use status.nu

# List installed packages
export def list [query?: string] {
    ^pwsh -NoProfile -Command $"scoop list ($query) 6>NUL | ConvertTo-Json"
    | from json | rename -b { str downcase }
    | move version source updated info --after name
    | into datetime updated
}

# Search all known buckets for packages. Uses scoop-search if installed
export def search [
    query: string = '' # Package name to search for
    --force-default (-f) # Use default 'scoop search' even if scoop-search is installed
] {
    if ((not $force_default) and (which scoop-search | into record | is-not-empty)) {
        ^scoop-search.exe $query | lines
        | str trim | split list '' | each { |lst|
            {
                source: ($lst.0 | str replace -r `^'([^']+)' bucket:` `$1`)
                pkgs: (
                    $lst | range 1..
                    | parse -r `(?P<name>\S+) \((?P<version>\S+)\)(?: --> includes '(?P<binaries>[^']+))?`
                )
            }
        } | flatten --all
        | move source --after version
    } else {
        let cmd = [
            $"scoop search ($query) 6>$null",
            'ForEach-Object {
                Add-Member -Name Version -Value $_.Version.GetString() `
                -MemberType NoteProperty -InputObject $_ -PassThru -Force
            }',
            'ConvertTo-Json'
        ]
        ^pwsh -NoProfile -Command ($cmd | str join ' | ')
        | from json | rename -b { str downcase }
        | move version source binaries --after name
        | update binaries { split row ' | ' | compact -e }
    }
}

# Show information for a specific package
export def info [name: string] {
    let cmd = ^pwsh -NoProfile -Command $"scoop info ($name) 6>NUL | ConvertTo-Json" | complete

    if $cmd.exit_code > 0 {
        error make {
            msg: $"Couldn't find any results for the package '($name)'"
            label: {
                text: "No matches"
                span: (metadata $name).span
            }
            help: "Make sure you've spelled the package name correctly"
        }
    }

    $cmd.stdout
    | from json | rename -b { str downcase }
    | rename -c {'updated at': updated, 'updated by': updater}
    | into datetime updated
    | upsert binaries { split row ' | ' }
    | upsert shortcuts { split row ' | ' }
    | upsert installed { split row (char newline) }
    | upsert "path added" { split row (char newline) }
    | rename -c {"path added": paths}
    | compact column -e
}

# === Alias command ===
# Completer for `help` subcommand
def "nu-complete scoop commands" [] {
    ^pwsh -NoProfile -Command 'scoop help 6>$null | ConvertTo-Json'
    | from json | get Command
}
