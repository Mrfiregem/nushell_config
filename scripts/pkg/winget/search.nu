export def main [
    query: string # The text to search
    --ensure-contains(-e) # Ensure each result contains the query exactly
    --no-split(-n) # Don't split the query into seperate words during search
] {
    let response = (
        {
            scheme: https
            host: api.winget.run
            path: /v2/packages
            query: (
                {
                    query: $query
                    ensureContains: (if $ensure_contains { 'true' } else { 'false' })
                    splitQuery: (if $no_split { 'false' } else { 'true' })
                } | url build-query
            )
        } | url join
        | http get $in
    )

    if $response.Total == 0 { return [] }

    $response.Packages | flatten Latest
    | rename -b { str downcase }
    | insert version { get versions | first }
    | select name id version description
}
