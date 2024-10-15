# Create a new deck

Navigate to the game deck folder, check the [create a custom deck][create-custom-deck] document to learn which folder is relevant for your operation system.

Please create a file structure like this

```
Samory/
├─ decks/
│  ├─ your-unique-deck-name/
│  │  ├─ cards/
│  │  ├─ cover.png
│  │  ├─ description.txt
│  │  ├─ description.de_DE.txt
│  │  ├─ name.txt
│  │  ├─ name.de_DE.txt
```

The root of your new deck in the example above will be `Samory/decks/your-unique-deck-name/`.
Let's explain the files and directories of this structure down below

| File/Directory          | Description                                                                                                                        | Required           |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ------------------ |
| `cards/`                 | This directory will contain your cards, you will learn later on how to create them                                                 | :heavy_check_mark: |
| `cover.png`             | The image shown as card back if not revealed, if nothing was provided the default one is used                                      | :x:                |
| `description.txt`       | The description of that deck, this will only be visible in the deck viewer or in the game lobby                                    | :heavy_check_mark: |
| `description.de_DE.txt` | The description of the deck translated into German. You can change the localization string to get translations for other languages | :x:                |
| `name.txt`              | The name of the deck, this will be displayed in the deck viewer or the game lobby                                                  | :heavy_check_mark: |
| `name.de_DE.txt`        | The name of the deck translated into German. You can change the localization string to get translations for other languages        | :x:                |

>:information_source: Translation's are optional, the game will try to find a localized text for the data field, but if nothing was found the default one will be used

>:information_source: Your cover image must be 500x550 pixel in size, if this is not the case it will not fully cover the card content. Since this is not required you can simple use the default card back.

You deck will also need at least two cards to be valid. To learn how to create cards check the [create custom card][create-custom-cards] documentation. Those cards will be placed insaide the `cards/` directory. So if you want to create a deck named `My first deck` with a description `This is my first custom Samory deck` you will add the following files to the `Samory/decks/your-unique-deck-name/` folder


>name.txt
```
My first deck
```

>description.txt
```
This is my first custom Samory deck
```

>:information_source: All the file and directory names are case sensitive and need to be writte as shown above.

You will also create a `cards/` directory inside the root directory to place [cards][create-custom-cards] in it.

Go back to the [manual][manual-entry]


[create-custom-cards]: ./create-custom-card.md
[create-custom-deck]: ./index.md
[manual-entry]: ../../README.md