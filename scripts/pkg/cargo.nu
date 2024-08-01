# List installed cargo binary packages
export def list [
    --upgradable(-u) # Show packages whose local version is lower than remote
] {
    if $upgradable {
        ^cargo install-update -l
        | lines | skip 2
        | str join (char nl)
        | from ssv
        | rename -b { str snake-case }
        | where needs_update == 'Yes'
        | reject needs_update
    } else {
        ^cargo install --list
        | str replace -ma `(.*:)$` "\n$1"
        | lines | split list ''
        | par-each {|lst|
            $lst.0
            | parse `{name} v{version}:`
            | insert binaries { $lst | range 1.. | str trim }
        } | flatten
    }
}