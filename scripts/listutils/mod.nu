# Wraps any non-list pipeline input into a list
export def "into list" []: any -> list<any> {
    let input = $in
    if ($input | describe -d).type == 'list' {
        return $input
    } else {
        return [$input]
    }
}

# If pipeline contains a list with one item,
# return that item, otherwise return the pipeline object
export def unwrap [] {
    let item = $in
    if ($item | describe -d).type == 'list' {
        match ($item | length) {
            0 => null
            1 => { $item | first }
            _ => $item
        }
    } else {
        return $item
    }
}

export def "compact column" [
    --empty (-e) # Also compact empty items like "", {}, and []
    ...rest: string # The columns to compact from the table
] {
    mut result = $in
    let cols = if ($rest | length) > 0 { $rest } else { $result | columns }

    for col in $cols {
        if ($result | get $col | compact --empty=$empty | length) == 0 {
            $result = ($result | reject $col)
        }
    }

    return $result
}
