def "nu-complete id-groups" [] { [user groups privileges] }

# Show group and privilege info for the logged in user
def id [
    --type: string@"nu-complete id-groups" = 'user' # Choose data to output (default: user; [user, groups, privileges])
] {
    ^whoami /ALL /FO CSV
    | lines | split list ''
    | par-each { str join (char nl) | from csv | rename -b { str snake-case } }
    | match $type {
        'user' => { first | into record }
        'groups' => { get 1 | update attributes { split row ', ' | compact -e } }
        'privileges' => { last | rename -c {state: enabled} | update enabled { $in == 'Enabled' } }
        _ => {
            error make {
                msg: "Unknown flag"
                label: {
                    span: (metadata $type).span
                    text: "Value must be [user, groups, privileges]"
                }
            help: "Make sure you spelled the flag argument correctly"
            }
        }
    }
}

# Load package manager modules as overlays
overlay use -p 'pkg/winget'
overlay use -p 'pkg/scoop'
