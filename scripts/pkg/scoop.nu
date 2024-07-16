export def list [query?: string] {
  ^pwsh -NoProfile -Command $"scoop list ($query) 6>NUL | ConvertTo-Json"
  | from json | rename -b { str downcase }
  | move version source updated info --after name
  | into datetime updated
}

export def search [query?: string] {
  ^pwsh -NoProfile -Command $"scoop search ($query) 6>NUL | ForEach-Object { Add-Member -Name Version -Value $_.Version.GetString\() -MemberType NoteProperty -InputObject $_ -PassThru -Force } | ConvertTo-Json"
  | from json | rename -b { str downcase }
  | move version source binaries --after name
}
