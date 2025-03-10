# Add custom decks to your game

This game does allow you to add custom card decks to it. To create such a deck, please read the documentation below.
Those decks will be loaded on game start, if your image files or the number of files are huge the initial loading process will take
longer. Keep in mind that all the data will be loaded to your RAM and kept there until the game is getting closed.

As a first step please navigate to one of the following paths to create your new deck files.

| Operation System | Path                                                            |
| ---------------- | --------------------------------------------------------------- |
| Windows          | `%APPDATA%\Godot\app_userdata\Samory\decks`                     |
| macOS            | `~/Library/Application Support/Godot/app_userdata/Samory/decks` |
| Linux            | `~/.local/share/godot/app_userdata/Samory/decks`                                                                |

Check the [Godot manuel][godot-file-paths] for more information

First of all you will ned to [create a new deck][create-a-new-deck] after that you can add cards to them, read the [create a new card][create-a-new-card] section
of the manuel to get some help.

Go back to the [manual][manual-entry]

[godot-file-paths]: https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
[create-a-new-deck]: ./create-custom-deck.md
[create-a-new-card]: ./create-custom-card.md
[manual-entry]: ../../README.md