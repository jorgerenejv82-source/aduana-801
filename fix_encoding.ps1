
# Fix UTF-8 mojibake in Dart source files
# The corrupted files have Ã¡ instead of á, Ã© instead of é, etc.
# (UTF-8 bytes read as Latin-1, then re-saved)

$dartFiles = Get-ChildItem -Path "lib\" -Recurse -Filter "*.dart"
$fileCount = 0

# Build replacement map using proper 2-char strings
$map = @{}
# Format: corrupted pair [char]Hi + [char]Lo -> correct char
$pairs = @(
  @(0xC3, 0xA1, 0xE1),  # á
  @(0xC3, 0xA9, 0xE9),  # é
  @(0xC3, 0xAD, 0xED),  # í
  @(0xC3, 0xB3, 0xF3),  # ó
  @(0xC3, 0xBA, 0xFA),  # ú
  @(0xC3, 0xB1, 0xF1),  # ñ
  @(0xC3, 0xBC, 0xFC),  # ü
  @(0xC3, 0xA0, 0xE0),  # à
  @(0xC3, 0xA7, 0xE7),  # ç
  @(0xC3, 0x81, 0xC1),  # Á
  @(0xC3, 0x89, 0xC9),  # É
  @(0xC3, 0x8D, 0xCD),  # Í
  @(0xC3, 0x93, 0xD3),  # Ó
  @(0xC3, 0x9A, 0xDA),  # Ú
  @(0xC3, 0x91, 0xD1),  # Ñ
  @(0xC2, 0xBF, 0xBF),  # ¿
  @(0xC2, 0xA1, 0xA1),  # ¡
  @(0xC2, 0xB0, 0xB0),  # °
  @(0xC2, 0xB7, 0xB7),  # ·
  @(0xC2, 0xAB, 0xAB),  # «
  @(0xC2, 0xBB, 0xBB),  # »
  @(0xC2, 0xA0, 0xA0),  # non-breaking space
  @(0xC2, 0xB4, 0xB4)   # ´
)

foreach ($triple in $pairs) {
  $search = ([string][char]$triple[0]) + ([string][char]$triple[1])
  $replace = [string][char]$triple[2]
  $map[$search] = $replace
}

foreach ($file in $dartFiles) {
  $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
  $fixed = $content
  foreach ($search in $map.Keys) {
    $fixed = $fixed.Replace($search, $map[$search])
  }
  if ($fixed -ne $content) {
    [System.IO.File]::WriteAllText($file.FullName, $fixed, (New-Object System.Text.UTF8Encoding $false))
    $fileCount++
    Write-Host "Fixed: $($file.Name)"
  }
}
Write-Host ""
Write-Host "Done: $fileCount files corrected"
