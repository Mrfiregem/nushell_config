# Fish-style path shortening
def "path shrink" [] {
  # Split input path into listlet parts = $in | str replace
  let $parts = $in | str replace $nu.home-path '~' | path split

  # Only shorten path if there is a middle part
  if (($parts | length) > 2) {
    $parts | range 1..<(-1)
    | each {|s|
      # Split current part into character array
      let c_arr = ($s | split chars)

      if ($c_arr.0 == '.') {
        # If current part is hidden (starts with '.') keep 2 letters
        $c_arr | take 2 | str join
      } else {
        # Otherwise just return the first character
        $c_arr.0
      }
    } | prepend $parts.0 | append ($parts | last) # Add back each end
    | path join
  } else {
    $parts | path join
  }
}

# Set left prompt text
$env.PROMPT_COMMAND = {|| $"($env.PWD | path shrink) "}

# How certain ENVVARS should be converted when passed between nu and other programs
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink | uniq }
    to_string: { |v| $v | path expand --no-symlink | uniq | str join (char esep) }
  }
  PATHEXT: {
    from_string: {|s| $s | split row (char esep) }
    to_string: {|v| $v | str join (char esep) }
  }
  CARAPACE_BRIDGES: {
    from_string: {|s| $s | split row ',' }
    to_string: {|v| $v | str join ',' }
  }
}

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# Add more directories to $PATH
use std "path add"
if $nu.os-info.family == "unix" {
  path add "/usr/local/bin"
}
path add ($nu.home-path | path join ".local" "bin")
path add -a ($env.NIMBLEDIR? | default ($nu.home-path | path join ".nimble") | path join "bin")
path add -a ($env.CARGO_HOME? | default ($nu.home-path | path join ".cargo") | path join "bin")
$env.Path = ($env.Path | uniq)

# Add Powershell files to PATHEXT
if $nu.os-info.family == "windows" {
  $env.PATHEXT = (
    $env.PATHEXT
    | split row (char esep)
    | append '.PS1'
    | uniq
  )
}

# Carapace completion setup
$env.CARAPACE_BRIDGES = ['zsh' 'fish' 'bash' 'inshellisense']

# Set default text editor
$env.VISUAL = nvim
$env.EDITOR = nvim
