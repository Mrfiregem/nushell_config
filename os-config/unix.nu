$env.user_info = (
    ^id | str replace --all ' ' (char nl)
    | lines | split column '=' key value
    | update value { split row ',' | parse `{id}({name})` }
    | update 0.value { into record }
    | update 1.value { into record }
    | transpose -rd
)
