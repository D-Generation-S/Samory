# Add custom decks to your game

> :warning: Custom decks are only available on the Desktop version of the game.

There are currently two methods to add custom decks to your game. Those are explained down there. To use those, first of all make sure that custom decks are active for your game.

![Active custom deck screenshot](https://i.imgur.com/7f5fxyu.png)

## Game UI

>:information_source: This is only available in version 0.19.0 and above.

### Create a deck

Click the `Create a custom deck` Button

![Create a custom deck](https://i.imgur.com/2jjNcSu.png)

Enter a deck name and optional a description

![Create new deck](https://i.imgur.com/QH5rfyf.png)

You can also add a custom card back if wanted, simply select an image via the `Load card back` button. The image will be scaled automatically if needed.

After entering this information press the `Create new custom deck` button to create your deck

### Add cards to deck

After you did create your deck you need to add cards to it. This will be explained in this part of the documentation.

![Empty deck](https://i.imgur.com/NbYHNiG.png)

Click the `Create new card` button to start adding a new card. Enter a card name, optional description and select an card image. The image size will automatically scaled to match the cards.

![Add new card](https://i.imgur.com/VQLznEf.png)

Press the `Save card` button if done.

> :information_source: You need to add at least 2 cards to an deck to make it playable.

![Final deck](https://i.imgur.com/qIVOylH.png)

If done click the `Save` button to complete your deck. After a short waiting time, depending on the number of cards you will be brought back to the main menu.

### Edit a already created deck

As before click the `Create a custom deck` and click the `Load a custom deck` button. Select your deck and load it.

### Add a deck from the internet

Get a `.sdeck` file from a trustworthy source on the internet and download it to your machine. Inside of the game main menu click the `open custom deck directory` button

![Open custom deck](https://i.imgur.com/I9oRD35.png)

This will bring up a directory, place the sdeck file there.

## Legacy via the file system

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