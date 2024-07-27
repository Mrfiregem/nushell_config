# Get path to note file
def get-path [] { $nu.data-dir | path join 'note' 'notes.json' }

# Get a list of user notes
export def list [
    --expired (-e)
    --long (-l)
] {
    let file = get-path
    let dir = ($file | path dirname)

    if (not ($dir | path exists)) { mkdir $dir }

    mut res = try {
        open (get-path) | default [] | into value
    } catch {
        []
    }

    if (not $long) {
        $res = ($res | select due body)
    }

    if ($expired) { return ($res | where due < (date now)) }
    return $res
}

# Provide id completion for `note rm`
def "nu-complete note ids" [] { list -l | each {|it| {value: $it.id description: $it.body} } }

# Remove a specific note by id
export def rm [id: string@"nu-complete note ids"] {
    list -l | where id != $id | save -f (get-path)
}

# Remove all expired notes
export def "rm expired" [] {
    list -l
    | where {|n| ($n.due | is-empty) or ($n.due >= (date now)) }
    | save -f (get-path)
}

# Import a note table to file
export def import [
    --overwrite (-o) # Replace currently stored notes instead of appending
]: table<id: string, body: string, posted: datetime, due: datetime> -> nothing {
    let new_notes = $in
    if $overwrite {
        $new_notes | save -f (get-path)
    } else {
        $new_notes ++ (list -l) | save -f (get-path)
    }
}

# Add a note to the file
export def main [
    --due (-d): string
    ...note: string
] {
    let body = ($note | str join ' ')
    if ($body | is-empty) {
        error make -u {
            msg: "Note body cannot be empty"
        }
    }

    let due_date = if ($due | is-empty) {
        null
    } else {
        $due | into datetime
    }

    let user_note = {
        id: (random uuid)
        body: $body
        posted: (date now)
        due: $due_date
    }

    list -l | append $user_note | tee { echo } | save -f (get-path)
}
