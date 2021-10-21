use file
use path

# Edit the current command buffer using the default editor
fn external_edit_command {
  var temp-file = (path:temp-file)
  print $edit:current-command > $temp-file
  try {
    (external $E:EDITOR) $temp-file[name] </dev/tty >/dev/tty 2>&1
    set edit:current-command = (slurp < $temp-file[name])[..-1]
  } finally {
    file:close $temp-file
    rm $temp-file[name]
  }
}

{{- if ne .chezmoi.os "windows" }}{{/* Modules don't work on Windows */}}

fn cd [@a]{
  use github.com/zzamboni/elvish-modules/dir
  dir:cd $@a
}
{{- end }}
