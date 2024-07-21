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
export def main [dir: string@"nu-complete xdg"] {
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
