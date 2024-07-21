use listutils unwrap
# === Package data commands ===

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
    | split list '' | each { |rw|
      {
        source: ($rw.0 | str replace -r `^'(.+)' bucket:$` '$1')
        pkgs: ($rw | range 1.. | str trim | parse `{name} ({version}){binaries}`)
      }
    } | flatten --all pkgs
    | update binaries { str trim | parse `--> includes '{bin}'` | get bin | unwrap }
    | move version source binaries --after name
  } else {
    ^pwsh -NoProfile -Command $"scoop search ($query) 6>NUL | ForEach-Object { Add-Member -Name Version -Value $_.Version.GetString\() -MemberType NoteProperty -InputObject $_ -PassThru -Force } | ConvertTo-Json"
    | from json | rename -b { str downcase }
    | move version source binaries --after name
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
}

# === Bucket commands ===

# List installed buckets
export def "bucket list" [] {
  ^pwsh -NoProfile -Command 'scoop bucket list 6>NUL | ConvertTo-Json'
  | from json | into value | rename -b { str downcase }
}

# List buckets known to scoop by name
export def "bucket known" [] {
  ^scoop bucket known | collect { lines }
}
