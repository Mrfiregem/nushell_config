# List installed packages
export def list [--upgradable (-u)] {
  let cmd = ^pwsh -NoProfile -Command `Get-WinGetPackage | ConvertTo-Json` | complete
  if $cmd.exit_code > 0 {
    error make -u {msg: 'error getting lit of installed packages'}
  }

  let tbl = $cmd.stdout | from json | rename -c {InstalledVersion: version, AvailableVersions: avail} | rename -b { str downcase }

  if $upgradable {
    $tbl | rename -c {avail: latest, version: current}
    | where isupdateavailable
    | update latest { first }
    | reject isupdateavailable
    | move current latest --before source
  } else {
    $tbl
    | reject isupdateavailable avail
    | move version --after name
  }
}
