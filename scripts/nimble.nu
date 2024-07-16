# If a '.nimble' file is present, get a list of tasks in that file
def get-tasks [] {
  let cmd = (^nimble tasks | complete)
  if (($cmd.exit_code > 0) or ($cmd.stderr | is-not-empty)) {
    return []
  } else {
    $cmd.stdout | lines | parse -r '^(?P<name>\S+)\s+(?P<description>.*)$'
  }
}

# Get nimble metadata
export def get-config [] {
  return {
    home: ($env.NIMBLE_DIR? | default ($nu.home-path | path join '.nimble'))
    tasks: (get-tasks)
  }
}

# Get a list of all packages available
export def list [--to-table (-t)] {
  let df = polars open ((get-config).home | path join "packages_official.json")
  if ($to_table) { $df | polars into-nu } else { $df }
}

# Get a list of installed packages
export def "list installed" [--long (-l)] {
  if ($long) {
    (get-config).home | path join pkgs2 | ls $in
    | select name | rename path | insert meta {
      get path | path basename | split column '-' name version checksum
    } | insert meta.metadata {
      get path | path join 'nimblemeta.json' | open | get metaData
    } | get meta | flatten
  } else {
    ^nimble list -i | collect { lines } | parse "{name}  [(version: {version}, checksum: {checksum})]"
  }
}

# Search the package database for packages whose name or tags match 'query'
export def search [query: string] {
  # Get all packages as dataframe
  let df = list
  # Create mask filtering when query matches a tag or partially matches a name
  let m_name = (($df.name | polars lowercase) =~ ($query | str downcase))
  let m_tags = ($query | polars into-df | polars is-in $df.tags)
  let m_desc = (($df.name | polars lowercase) =~ ($query | str downcase))
  let mask = ($m_name or $m_tags or $m_desc)
  
  # Apply mask and convert results to table
  $df | polars filter-with $mask | polars into-nu
}

def pkgname_completer [] { list | polars get name | polars into-nu | get name }
# Get specific package metadata in the official database
export def info [name: string@pkgname_completer] {
  # Get full list as dataframe
  let df = list
  # Filter to 1-record table
  let result = (
    $df
    | polars filter-with (($df.name | polars lowercase) == ($name | str downcase))
    | polars into-nu
  )
  # Get list of columns with no data
  let empty_cols = (
    $result | columns | wrap name
    | insert remove {|it|
      $result | get $it.name
      | compact | is-empty
    } | where remove
    | get name
  )

  # Convert 1-item table to record without empty columns
  $result | reject ...$empty_cols | into record
}
