use user
def get-memedir [] { user videos | path join memes }

def needs-remux []: string -> bool {
  let url = $in
  let whitelist = [
    'tiktok.com'
  ]

  return ((($url | url parse).host | str replace -r `^www\.` '') in $whitelist)
}

def gen-args [url: string, title: string]: nothing -> list<string> {
  mut args = [
    '-P'
    (get-memedir)
    '-o'
    ($title | str trim | append '.%(ext)s' | str join)
  ]

  if ($url | needs-remux) {
    $args = (
      $args
      | append [
        '--use-postprocessor'
        'FFmpegCopyStream'
        '--ppa'
        'CopyStream:-c:v libx264 -c:a aac -f mp4'
      ]
    )
  }

  return $args
}

export def main [url: string, title: string]: nothing -> record {
  let args = (gen-args $url $title)
  ^yt-dlp ...$args -- $url

  if ($env.LAST_EXIT_CODE == 0) {
    let filepath = (^yt-dlp --get-filename ...$args -- $url)
    ls -f $filepath | into record
  } else {
    error make -u {msg: 'error downloading meme'}
  }
}
