# Samory

[![Godot Engine](https://img.shields.io/badge/Godot-%23FFFFFF.svg?logo=godot-engine)](#)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](#)
[![Windows](https://custom-icon-badges.demolab.com/badge/Windows-0078D6?logo=windows11&logoColor=white)](#)

[![Itch.io](https://img.shields.io/badge/itch.io-%23FF0B34.svg?logo=Itch.io&logoColor=white)](https://xanatos.itch.io/samory)

A memory like game which does allow you to side load custom decks. This game was developed as a hobby, mostly for my son.
But feel free to test it out. The game can be played alone vs the AI or you can play against human players in a local coop mode.

The game is shipped with a build in deck, no need to create a custom one.

If you want to give it a try check it out on [Itch.io][itch-io]. You could also download the latest build on GitHub if you wish.

## Installation from GitHub

If you do want to download the game from GitHub go to [release][latest-release] page and download the zip file for your system. Unzip the content to your machine into an directory. Open up that directory and execute the `samory` binary.

### Arch Linux

If you are on Arch you can get the game via the AUR. To do so head over to [samory-bin][samory-aur] or if you do have `yay` installed run

```bash
yay samory-bin
```

## Build the project

### Requirements

- [Godot 4.4][godot4_4]

### How to build the project

To build the project clone the repository to yout machine. After cloing start Godot and open the `project.godot` file. Use the
import button inside of the Godot project overview to do so.

Now you should be able to run the game by starting the debug. 

## Special Thanks

Special Thank to [Kenney][kenney] for making so many assets free to use. This game does use sound effects and image assets.
Also a big thank to "Abstraction" for making his awesome [music][music] free to use.

Thank you [Axuree][axuree] for creating some really unique assets for the game, this really does make it pop. Thank you so much for your effort.


## License

The code for this project is licensed with an [MIT][license-code] license. This license is only valid for all the code, scripts and shaders.
To check the license for the assets, like music, effects or sprite sheets please go to the special thanks section and follow the links to the
creators of those assets.

All assets contained inside of the [Axuree directory][axuree-directory] are licensed with the [Attribution-NonCommercial-ShareAlike 4.0 International license][axuree-license]. The license is part of the folder containing the asset if you need more information.


[itch-io]: https://xanatos.itch.io/samory
[godot4_4]: https://godotengine.org/download/archive/4.4-stable/
[latest-release]: https://github.com/D-Generation-S/Samory/releases/latest
[samory-aur]: https://aur.archlinux.org/packages/samory-bin
[kenney]: https://www.kenney.nl/
[axuree]: https://axuree.myportfolio.com/
[axuree-directory]: ./assets/sprites/Axuree/
[axuree-license]: ./assets/sprites/Axuree/LICENSE
[music]: https://tallbeard.itch.io/music-loop-bundle
[license-code]: ./LICENSE

