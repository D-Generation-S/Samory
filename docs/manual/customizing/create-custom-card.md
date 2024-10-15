# Create a custom card in your deck

Before starting with this documentation you should read the [create custom deck][create-a-custom-deck] document. After creating those files and adding the `cards/` directory you can continue with this part.

Open up the `cards/` folder inside of your root `Samory/decks/your-unique-deck-name/`. Add a new directory here for your first card. Lets call it `first-card`

```
Samory/
├─ decks/
│  ├─ your-unique-deck-name/
│  │  ├─ cards/
|  |  |  ├─ first-card/
│  │  ├─ description.txt
│  │  ├─ name.txt
```

Inside the `first-card` directory you will need to create other files to describe your card.

```
first-card/
├─ description.txt
├─ description.de_DE.txt
├─ front.jpg
├─ name.txt
├─ name.de_DE.txt
```

>:information_source: All the file and directory names are case sensitive and need to be writte as shown above.

>:information_source: Instead of `jpg` image you also can use `png` images

| File                     | Description                                                                                     | Required           |
| ------------------------ | ----------------------------------------------------------------------------------------------- | ------------------ |
| `description.txt`        | The description of the card, this will be visible in the deck viewer                            | :heavy_check_mark: |
| `description.de_DE.txt`  | The translated description of the card, in this case the translation is for the German language | :x:                |
| `front.jpg`, `front.png` | The image shown on the card itself, this is what is getting shown if you reveal a card          | :heavy_check_mark: |
| `name.txt`               | The name of the card, this will be shown below the front image                                  | :heavy_check_mark: |
| `name.de_DE.txt`         | The translated name of the card, in this case the translation is for the German language        | :x:                |

>:information_source: Translation's are optional, the game will try to find a localized text for the data field, but if nothing was found the default one will be used

As example a card named `My first card` with a description `This is my very first custom card` will have the following content on the given data sets:

>name.txt
```
My first card
```

>description.txt
```
This is my very first custom card
```

Each card does required there own directory and you will need to add at least two cards to your deck, otherwise the game will prevent it from loading.

Go back to the [manual][manual-entry]

[create-a-custom-deck]: ./create-custom-deck.md
[manual-entry]: ../../README.md