use std "path add"
source unix.nu

overlay use --prefix pkg/brew

let uutil_path = $"(^brew --prefix)/opt/uutils-coreutils/libexec/uubin"
if ($uutil_path | path exists) {
    path add $uutil_path
}
