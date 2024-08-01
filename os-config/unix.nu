def id [
    --groups(-g) # Show user groups instead
] {
    ^id | split row ' ' | split column '=' key value
    | if $groups {
        last | get value
        | split row ','
        | parse '{id}({name})'
        | into value
        | move id --after name
    } else {
        first 2
        | update value {
            parse '{value}({name})'
            | into value
            | move name --before value
            | into record
        } | transpose -rd
    }
}
