$base = 'C:\Users\USER'
Write-Host "BASE $base"
Get-ChildItem $base | Where-Object { $_.PSIsContainer } | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [PSCustomObject]@{ Name = $_.Name; SizeGB = '{0:N2}' -f ($size/1GB) }
} | Sort-Object {[double]$_.SizeGB} -Descending | Format-Table -AutoSize
