# Creates a table with non-empty columns.
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
