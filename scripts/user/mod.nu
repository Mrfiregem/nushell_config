# Get a record of all user directories
export def list []: nothing -> record {
  return {
    desktop: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir DESKTOP),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `Desktop`).value
      _ => ($nu.home-path | path join 'Desktop')
    })
    documents: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir DOCUMENTS),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `Personal`).value
      _ => ($nu.home-path | path join 'Documents')
    })
    download: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir DOWNLOAD),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `{374DE290-123F-4565-9164-39C4925E467B}`).value
      _ => ($nu.home-path | path join 'Downloads')
    })
    music: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir MUSIC),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `My Music`).value
      _ => ($nu.home-path | path join 'Music')
    })
    pictures: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir PICTURES),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `My Pictures`).value
      _ => ($nu.home-path | path join 'Pictures')
    })
    public: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir PUBLICSHARE),
      'macos' => ($nu.home-path | path join 'Public')
      _ => null
    })
    templates: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir TEMPLATES),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `Templates`).value
      _ => ($nu.home-path | path join 'Templates')
    })
    videos: (match $nu.os-info.name {
      'linux' => (^xdg-user-dir VIDEOS),
      'windows' => (registry query --hkcu `Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` `My Video`).value
      'macos' => ($nu.home-path | path join 'Movies')
      _ => ($nu.home-path | path join 'Videos')
    })
  }
}

def "complete dirs" [] { list | columns }
# Get a specific user directory
export def main [
  path: string@"complete dirs" # the user directory to return
]: nothing -> path {
  let result = list | get -i $path
  if ($result | is-not-empty) { $result } else {
    error make {
      msg: $"($path) is not a valid path"
      label: {
        text: 'invalid path'
        span: (metadata $path).span
      }
    }
  }
}

# A module to retrieve user directories (i.e. 'videos', 'documents', 'desktop', ...)
export use user/xdg.nu
