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
  PATH: {
    from_string: {|s| $s | split row (char esep) | uniq | compact }
    to_string: {|v| $v | str join (char esep) }
  }
  CARAPACE_BRIDGES: {
    from_string: {|s| $s | split row ',' }
    to_string: {|v| $v | str join ',' }
  }
}

# Add more directories to $PATH
$env.PATH = (
  $env.PATH
  | prepend '/usr/local/bin'
  | prepend $"($nu.home-path)/.local/bin"
  | append $"($nu.home-path)/.nimble/bin"
  | append $"($nu.home-path)/.cargo/bin"
)

# Carapace completion setup
$env.CARAPACE_BRIDGES = ['zsh' 'fish' 'bash' 'inshellisense']

# Set default text editor
$env.VISUAL = nvim
$env.EDITOR = nvim
