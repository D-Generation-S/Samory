#Request tags
$tags = git tag --sort=-v:refname
$directory = "shared/resources/changelog"
$projectGodotPath = "project.godot"
$versionLine = Select-String -Path $projectGodotPath -Pattern 'config/version="([^"]+)"'
if (-not $versionLine) {
    Write-Error "Konnte config/version in project.godot nicht finden!"
    exit 1
}
$currentVersion = $versionLine.Matches.Groups[1].Value
Write-Output "Current game version: $currentVersion"

# Generate changelog for each tag
for ($i = $tags.Count - 1; $i -gt 0; $i--) {
    $currentTag = $tags[$i]
    $nextTag = $tags[$i - 1]
    $filename = "$directory\$nextTag.txt"
	Write-Output "Generate changelog from $currentTag to $nextTag"
    git cliff "$currentTag..$nextTag" --output $filename

}


Write-Output "Generate last changelog from $($tags[0]) to $currentVersion"
git cliff "$($tags[0])..HEAD" --tag $currentVersion --output "$directory\$currentVersion.txt"
