# Import user modules
use functions.nu * # Simple functions that aren't part of any module
use util * # Private functions
use user.nu # Module to retreive XDG user directories
use nimble.nu # Nim package manager
use note.nu # Simple note-taking module
use meme.nu # Video-downloader

const WINDOWS_CONF = "./os-config/windows.nu"
const MACOS_CONF = "./os-config/macos.nu"
const UNIX_CONF = "./os-config/unix.nu"
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

# Carapace completion setup
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
source ~/.cache/carapace/init.nu
