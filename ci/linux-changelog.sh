#!/bin/bash

# Read current godot version
projectGodotPath="project.godot"
currentVersion=$(grep 'config/version=' "$projectGodotPath" | sed -n 's/.*config\/version="\([^"]*\)".*/\1/p')

if [ -z "$currentVersion" ]; then
    echo "Error: Konnte config/version in project.godot nicht finden!" >&2
    exit 1
fi

echo "Current game version: $currentVersion"
directory="shared/resources/changelog"

# Request git tags
mapfile -t tags < <(git tag --sort=-v:refname)

# Generate a changelog for each version
for ((i=${#tags[@]}-1; i>0; i--)); do
    currentTag="${tags[$i]}"
    nextTag="${tags[$((i-1))]}"
    filename="$directory/$nextTag.txt"
    echo "Generate changelog from $currentTag to $nextTag"
    git cliff "$currentTag..$nextTag" --output "$filename"
done

if [ "${tags[0]}" != "$currentVersion" ]; then
	# Generate the last changelog
	echo "Generate last changelog from ${tags[0]} to $currentVersion"
	git cliff "${tags[0]}..HEAD" --tag "$currentVersion" --output "$directory/$currentVersion.txt"
fi