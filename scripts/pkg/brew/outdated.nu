# Get all outdated packages
export def main [] {
    ^brew outdated --json=v2 | from json
    | rename -c {formulae: formula, casks: cask}
    | transpose type _ | flatten --all _
    | where not pinned
    | rename -c {installed_versions: current, current_version: latest}
    | update current { first }
    | select type name current latest
}
