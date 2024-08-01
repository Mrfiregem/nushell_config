# List installed cargo binary packages
def "cargo list" [] {
    ^cargo install --list
    | str replace -ma `(.*:)$` "\n$1"
    | lines | split list ''
    | par-each {|lst|
        $lst.0
        | parse `{name} v{version}:`
        | insert binaries { $lst | range 1.. | str trim }
    } | flatten
}

# Define aliases
# Overlays
alias ':o' = overlay use
alias ':op' = overlay use --prefix
alias ':h' = overlay hide
alias ':l' = overlay list

# Import helpful custom functions
overlay use functions.nu # Simple functions that aren't part of any module
overlay use listutils # Functions for working with lists in pipelines
overlay use --prefix user # Module to retreive XDG user directories
overlay use commands # A module containing cutom commands including a note taker

$env.config = {
    show_banner: false
    buffer_editor: 'nvim'
    table: {
        # 'basic' 'compact' 'compact_double' 'default' 'heavy' 'light' 'none' 'reinforced' 'rounded'
        # 'thin' 'with_love' 'psql' 'markdown' 'dots' 'restructured' 'ascii_rounded' 'basic_compact'
        mode: 'rounded'
        index_mode: 'always' # 'auto' 'never' 'always'
        show_empty: true # Show representations of empty lists and records
        header_on_separator: false
    }
}

# Load platform-specific config
const OS_CONFIG = if $nu.os-info.name == "windows" {
    'os-config/windows.nu'
} else if $nu.os-info.name == "macos" {
    'os-config/macos.nu'
} else {
    'os-congig/unix.nu'
}
# Must be outside of a block because source is scoped for some reason
source $OS_CONFIG
