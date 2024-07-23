use listutils/lists.nu "into list"
# Creates a table with non-empty columns.
export def "compact column" [
    --empty (-e) # Also compact empty items like "", {}, and []
    ...rest: string # The columns to compact from the table
]: [
    record -> record
    table -> table
    list<any> -> table
] {
    let result = $in
    let input_type = $result | describe

    let cols = if ($rest | length) > 0 { $rest } else { $result | columns }
    mut drops = ($cols | wrap name | insert empty false)

    if ($input_type | str starts-with 'record') {
        $drops = (
            $drops | update empty { |it|
                let val = ($result | get $it.name)
                if ($empty) {
                    $val == null or $val == [] or $val == {} or $val == ""
                } else {
                    $val == null
                }
            }
        )
    } else if (($input_type | str starts-with 'table') or ($input_type | str starts-with 'list<any>')) {
        $drops = (
            $drops | update empty { |it|
                let lst = ($result | get $it.name)
                ($lst | compact --empty=$empty | length) == 0
            }
        )
    } else {
        error make -u {msg: "input type must be one of [record, table]"}
    }

    $result | reject ...($drops | where empty).name
}
