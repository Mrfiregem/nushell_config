export def list [--short(-s)] {
    if $short {
        ^pipx list --short | collect { lines | parse '{name} {version}' }
    } else {
        ^pipx list --json
        | from json | get venvs
        | transpose name value
        | update value {
            get metadata
            | {
                binaries: $in.main_package.apps
                dependencies: ($in.main_package.app_paths_of_dependencies | columns)
                version: $in.main_package.package_version
                python: $in.python_version
            }
        } | flatten value
    }
}
