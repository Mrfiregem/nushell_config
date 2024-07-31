use std "path add"

def --wrapped brewup [...args] {
    ^brew update
    ^brew upgrade ...$args
    ^brew cleanup
    ^brew doctor
}

# Load unix configuration, too
source unix.nu

# Add completions and custom functions for brew
overlay use --prefix pkg/brew

# If uutils are installed by brew, use them over BSD ones
let uutil_path = $"(^brew --prefix)/opt/uutils-coreutils/libexec/uubin"
if ($uutil_path | path exists) {
    path add $uutil_path
}
