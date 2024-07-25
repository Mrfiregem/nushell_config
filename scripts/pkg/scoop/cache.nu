# View cached files and their size
export def show [
    --full(-f) # Show size for each package version instead of total size
] {
    if not $full {
        ^scoop cache show
        | parse "Total: {files} files, {size}"
        | into int files | into filesize size
        | into record
    } else {
        let cmd = ^pwsh -NoProfile -Command 'scoop cache show 6>$null | ConvertTo-Json' | complete
        if ($cmd.stdout | is-empty) { return [] }

        $cmd.stdout | from json | rename -b { str downcase } | rename -c {length: size}
        | into filesize size
    }
}

def "nu-complete cache names" [] { show --full | get name? | default [] }

# Remove cached downloads
export extern rm [
    app?: string # Remove downloads for this app
    --all(-a) # Clear everything in cache
]
