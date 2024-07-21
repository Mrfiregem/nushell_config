use listutils unwrap

def id [] {
    ^id | str replace --all ' ' (char newline)
    | lines | split column '=' key value
    | update value { split row ',' | parse `{id}({name})` | unwrap }
    | transpose -rd
}
