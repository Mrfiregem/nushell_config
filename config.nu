# Define aliases
#
# Overlays
alias ':o' = overlay use
alias ':op' = overlay use --prefix
alias ':h' = overlay hide
alias ':l' = overlay list

# Import helpful custom functions
:o functions.nu # Simple functions that aren't part of any module
:o listutils # Functions for working with lists in pipelines
:op user # Module to retreive XDG user directories
:o commands # A module containing cutom commands including a note taker

const WINDOWS_CONF = "./os-config/windows.nu"
const MACOS_CONF = "./os-config/macos.nu"
const OS_CONFIG = if $nu.os-info.name == "windows" {
    $WINDOWS_CONF
} else if $nu.os-info.name == "macos" {
    $MACOS_CONF
}
source $OS_CONFIG

$env.config = {
    show_banner: false
    buffer_editor: 'nvim'
    table: {
        # 'basic' 'compact' 'compact_double' 'default' 'heavy' 'light' 'none' 'reinforced' 'rounded'
        # 'thin' 'with_love' 'psql' 'markdown' 'dots' 'restructured' 'ascii_rounded' 'basic_compact'
        mode: 'rounded'
        index_mode: 'always' # 'auto' 'never' 'always'
        show_empty: true
        header_on_separator: false
    }
}

def "cargo list" [] {
    ^cargo install --list
    | str replace -ma `(.*:)$` "\n$1"
    | lines | split list ''
    | each {|lst|
        $lst.0
        | parse `{name} v{version}:`
        | insert binaries { $lst | range 1.. | str trim }
    } | flatten
}
