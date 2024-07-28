# Import helpful custom functions
use functions.nu * # Simple functions that aren't part of any module
use listutils * # Functions for working with lists in pipelines
use user # Module to retreive XDG user directories
use commands *

const WINDOWS_CONF = "./os-config/windows.nu"
const MACOS_CONF = "./os-config/macos.nu"
const OS_CONFIG = if $nu.os-info.name == "windows" {
    $WINDOWS_CONF
} else if $nu.os-info.name == "macos" {
    $MACOS_CONF
}
source $OS_CONFIG

alias :o = overlay use
alias :h = overlay hide

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
