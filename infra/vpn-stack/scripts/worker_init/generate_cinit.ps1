$ErrorActionPreference = "Stop"

try {
  Get-Content .env.shell | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
      $env:$($matches[1].Trim()) = $matches[2].Trim()
    }
  }

  python render.py worker-cloudinit.tpl.yaml user-data.yaml

    if ($LASTEXITCODE -ne 0) {
        throw "render.py failed with exit code $LASTEXITCODE"
    }

    Write-Host "✅ Script Successful"
}
catch {
  Write-Error "❌ Execution failed: $_"
  exit 1
}
