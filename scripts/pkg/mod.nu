# Use all non-platform specific package modules
export use nimble.nu
export use pipx.nu

export def "cargo list" [] {
    ^cargo install --list
    | str replace -ma `(.*:)$` "\n$1"
    | lines | split list ''
    | par-each {|lst|
        $lst.0
        | parse `{name} v{version}:`
        | insert binaries { $lst | range 1.. | str trim }
    } | flatten
}

