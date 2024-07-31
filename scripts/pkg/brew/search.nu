use std null-device

# Search for a package by text or regex
export def main [query: string] {
    [formula cask] | par-each { |s|
        ^brew search $'--($s)' $query e> (null-device)
        | lines | wrap name
        | insert type { $s }
    } | flatten
}
