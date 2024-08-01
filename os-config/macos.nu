def --wrapped brewup [...args] {
    ^brew update
    ^brew upgrade ...$args
    ^brew cleanup
    ^brew doctor
}

# Add completions and custom functions for brew
overlay use -p 'pkg/brew'

# If uutils are installed by brew, use them over BSD ones
let uutil_path = $"(^brew --prefix)/opt/uutils-coreutils/libexec/uubin"
if ($uutil_path | path exists) {
    $env.PATH = ($env.PATH | split row (char esep) | prepend $uutil_path)
}
