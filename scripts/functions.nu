# Take path elements, join them, then cd to the resulting path
export def --env cdl [...rest: string] {
    let pre = $in
    cd ($pre | append $rest | path join)
}

# Create, then immediately open, a new directory
export def --env mkcd [path: string] {
    mkdir $path
    cd $path
}

# Open a random file in the specified path. Useful for media directories
export def "start random" [path: string] {
    ls $path | where type == file
    | shuffle | first | start $in.name
}
