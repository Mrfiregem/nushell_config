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

# Determine the correct $XDG_RUNTIME_DIR value
def xdg-runtime [] {
    match $nu.os-info.name {
        'macos' => { $nu.home-path | path join 'Library' 'Caches' 'TemporaryItems' }
        'windows' => { $env.LOCALAPPDATA | path join 'Temp' }
        'linux' => $env.XDG_RUNTIME_DIR?
        _ => null
    }
}

# Completions for the function below
def "nu-complete xdg" [] { [config cache data state runtime] }

# Get the corrent value for the specified XDG User Directory
export def xdg [dir: string@"nu-complete xdg"] {
    match $dir {
        'config' => { $env.XDG_CONFIG_HOME? | default ($nu.home-path | path join '.config') },
        'cache' => { $env.XDG_CACHE_HOME? | default ($nu.home-path | path join '.cache') },
        'data' => { $env.XDG_DATA_HOME? | default ($nu.home-path | path join '.local' 'share') },
        'state' => { $env.XDG_STATE_HOME? | default ($nu.home-path | path join '.local' 'state') },
        'runtime' => { xdg-runtime }
        _ => {
            error make {
                msg: 'given path not valid'
                label: {text: 'unknown path', span: (metadata $dir).span}
            }
        }
    }
}

# Wraps any non-list pipeline input into a list
export def "into list" []: any -> list<any> {
    let input = $in
    if ($input | describe -d).type == 'list' {
        return $input
    } else {
        return [$input]
    }
}

# If pipeline contains a list with one item,
# return that item, otherwise return the pipeline object
export def unwrap []: [
    list<any> -> any
    list<any> -> list<any>
    list<nothing> -> nothing
    any -> any
] {
    let item = $in
    if ($item | describe -d).type == 'list' {
        match ($item | length) {
            0 => null
            1 => { $item | first }
            _ => $item
        }
    } else {
        return $item
    }
}
