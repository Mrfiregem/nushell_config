# List installed buckets
export def list [] {
    ^pwsh -NoProfile -Command 'scoop bucket list 6>NUL | ConvertTo-Json'
    | from json | into value | rename -b { str downcase }
}

# List buckets known to scoop by name
export def known [] {
    ^scoop bucket known | collect { lines | wrap name }
}

# Add a repository or known bucket
export def add [name: string, repo?: string] {
    if ($repo | is-not-empty) {
        ^scoop bucket add $name $repo
    } else {
        if ($name not-in (known).name) {
            error make {
                msg: $"'($name)' is not a known repo"
                label: {text: 'unknown value', span: (metadata $name).span}
                help: "Run 'scoop bucket known' or provide a repo url"
            }
        }
        ^scoop bucket add $name
    }
}

# Bucket name completer
def "nu-complete scoop buckets" [] { list | get name }

# Remove a bucket
export extern rm [
    name: string@"nu-complete scoop buckets"
]
