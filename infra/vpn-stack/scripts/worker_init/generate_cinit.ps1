$ErrorActionPreference = "Stop"

try {
  Get-Content .env.shell | ForEach-Object {
    if ($_ -match '^\s*$' -or $_ -match '^\s*#') { return }
    if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
      $name  = $matches[1]
      $value = $matches[2].Trim()
      if (
        ($value.StartsWith('"') -and $value.EndsWith('"')) -or
        ($value.StartsWith("'") -and $value.EndsWith("'"))
      ) {
        $value = $value.Substring(1, $value.Length - 2)
      }

      Set-Item -Path "Env:$name" -Value $value
    }
  }

  python render.py worker-cloudinit.tpl.yaml user-data
  if ($LASTEXITCODE -ne 0) {
    throw "render.py failed with exit code $LASTEXITCODE"
  }

  Write-Host "✅ Script Successful"
}
catch {
  Write-Error "❌ Execution failed: $_"
  exit 1
}
