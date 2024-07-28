# List all installed packages
export def main [
    --formula (-f) # Only include formulae
    --cask (-c) # Only include casks
    --short (-s) # Only return name, type, and version
] {
    if ($formula and $cask) {
        error make {
            msg: "'--formula' and '--cask' are conflicting flags"
            label: {text: 'conflicting flag', span: (metadata $cask).span}
        }
    }

    ^brew info --installed --json=v2 | from json
    | update formulae {|it|
        insert version { get installed.version | first }
        | select name tap desc version
    } | update casks {
        select token tap desc version
        | rename -c {token: name}
    } | rename -c {formulae: formula, casks: cask}
    | transpose type _ | flatten --all _
    | if $short { select name version type } else {}
    | if $formula { where type == 'formula' } else if $cask { where type == 'cask' } else {}
}
