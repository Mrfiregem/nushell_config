# Open the config directory in lazygit
export def "config git" [] { lazygit --path $nu.default-config-dir }

# Take path elements, join them, then cd to the resulting path
export def --env cdl [...rest: string] {
    cd ($in | append $rest | path join)
}

# Convert cells containing empty '', [], {} into nothing
export def nullify [...columns: string] {
    if ($columns | length) > 0 {
        $in | update cells -c $columns {|v| if ($v | is-empty) { null } else { $v } }
    } else {
        $in | update cells {|v| if ($v | is-empty) { null } else { $v } }
    }
}

# Create, then immediately open, a new directory
export def --env mkcd [path: string] {
    mkdir $path
    cd $path
}

# Rename a file using brace expansion
export def rname [expansion: string] { mv ...($expansion | str expand --path) }

# Open a random file in the specified path. Useful for media directories
export def "start random" [path: path = .] {
    let file = ls $path -f | where type == file | shuffle | first
    print "Opening file:"
    print $file
    start $file.name
}

# "update cells" but for records
export def "update items" [
    closure: closure
    --columns(-c): list<string>
]: record -> record {
    if ($columns | is-not-empty) {
        update cells --columns $columns $closure | first
    } else {
        update cells $closure | first
    }
}

# Output tables similar to Powershell's "Format-List"
export def out-list []: any -> nothing { each { print } | ignore }

# Print `tldr` page examples as a table
export def usage [cmd: string, --no-ansi(-A), --update(-u)] {
    if $update {
        ^tldr -u --raw $cmd
    } else {
        ^tldr --raw $cmd
    } | lines | compact -e
    | skip until { str starts-with '- ' }
    | chunks 2 | each { str join ' ' }
    | parse '- {desc}: `{example}`'
    | update example {
        str replace -a '{{' (ansi u) # Underline shown for user input
        | str replace -a '}}' (ansi reset) # Turn off underline
        | str replace -r '^(\w\S*)' $'(ansi bo)$1(ansi reset)' # Make first word (usually command) bold
        | str replace -ar ' (-{1,2}\S+)' $' (ansi d)$1(ansi reset)' # Make cli flags dim
    } | if $no_ansi { update example { ansi strip } } else {}
    | move desc --after example
}
