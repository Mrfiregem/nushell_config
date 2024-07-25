# Open the config directory in lazygit
export def "config git" [] { lazygit --path $nu.default-config-dir }

# Take path elements, join them, then cd to the resulting path
export def --env cdl [...rest: string] {
    cd ($in | append $rest | path join)
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
