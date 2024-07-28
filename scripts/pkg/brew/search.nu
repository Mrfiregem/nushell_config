use std null-device
export def main [query: string] {
    ^brew search --formula $query e> (null-device) | lines | each {|n| {type: formula, name: $n}}
    | append (^brew search --cask $query e> (null-device) | lines | each {|n| {type: cask, name: $n}})
}
