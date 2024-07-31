export def main [] {
    ^scoop update | print
    ^pwsh -NoProfile -Command 'scoop status 6>$null | ConvertTo-Json'
    | from json
    | rename -b { str snake-case }
    | rename -c {
        installed_version: current
        latest_version: latest
        missing_dependencies: new_deps
    }
}
