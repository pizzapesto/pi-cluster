Get-Content .env.shell | ForEach-Object {
  if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
    $env:$($matches[1].Trim()) = $matches[2].Trim()
  }
}

python render.py worker-cloudinit.tpl.yaml user-data.yaml