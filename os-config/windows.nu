overlay use --prefix pkg/winget
overlay use --prefix pkg/scoop

def id [--long (-l)] {
    let cmd = ^whoami /ALL /FO CSV | complete
    mut result = (
        $cmd.stdout | lines
        | split list '' | each {
            str join (char newline)
            | from csv | rename -b { str downcase }
        }
        | {
            user: ($in.0 | into record)
            group: $in.1
            privileges: $in.2
        }
    )

    $result.user = ($result.user | rename -c {'user name': name})
    $result.group = ($result.group | rename -c {'group name': name} | update attributes { split row ', ' })
    $result.privileges = ($result.privileges | rename -c {'privilege name': name, state: enabled} | update enabled { $in == 'Enabled' })

    if $long {
        return $result
    } else {
        return $result.user
    }
}
