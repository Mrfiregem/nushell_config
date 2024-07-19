source unix.nu

use pkg/brew.nu
use std "path add"

let uutil_path = $"(^brew --prefix)/opt/uutils-coreutils/libexec/uubin"
if ($uutil_path | path exists) {
    path add $uutil_path
}
