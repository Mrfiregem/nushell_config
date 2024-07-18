# Get all outdated packages
export def outdated [] {
    ^brew outdated --json=v2 | from json
    | rename -c {formulae: formula, casks: cask}
    | transpose type value | flatten --all
    | each { |it|
        {
            name: $it.name
            current: $it.installed_versions.0
            new: $it.current_version
            pinned: $it.pinned_version
        }
    }
}

# Search for available packages
export def search [query: string] {
    let formulae = ^brew search --formula $query | complete
    let casks = ^brew search --cask $query | complete

    {
        formula: ($formulae.stdout | lines)
        cask: ($casks.stdout | lines)
    } | transpose type name
    | flatten
}

# List all installed packages
export def list [
    --formula (-f) # Only include formulae
    --cask (-c) # Only include casks
] {
    if ($formula and $cask) {
        error make {
            msg: "'--formula' and '--cask' are conflicting flags"
            label: {text: 'conflicting flag', span: (metadata $cask).span}
        }
    }

    if ($formula) {
        return (^brew list --formula | lines)
    } else if ($cask) {
        return (^brew list --cask | lines)
    } else {
        return {
            formulae: (^brew list --formula | lines)
            casks: (^brew list --cask | lines)
        }
    }
}

# Get information about a specific package
export def info [
    name: string
    --formula (-f)
    --cask (-c)
] {
    if ($formula and $cask) {
        error make {
            msg: "'--formula' and '--cask' are conflicting flags"
            label: {text: 'conflicting flag', span: (metadata $cask).span}
        }
    }

    let cmd = (^brew info --json=v2 $name | complete)
    if ($cmd.exit_code > 0) {
        error make -u {msg: $cmd.stderr}
    }

    let res = (brew info --json=v2 $name | from json)

    let out = (
        if ($res.casks | is-not-empty) {
            $res.casks | into record
            | select token tap name desc version homepage depends_on conflicts_with caveats
            | insert type 'cask' | move type --before token
        } else if ($res.formulae | is-not-empty) {
            $res.formulae | into record
            | select name tap desc versions homepage license dependencies build_dependencies caveats
            | update caveats { default "" | str trim }
            | insert type 'formula' | move type --before name
        } else {
            {}
        }
    )

    if ($formula and $out.type != 'formula') { return {} }
    if ($cask and $out.type != 'cask') { return {} }

    return $out
}
