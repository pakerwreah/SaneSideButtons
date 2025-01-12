# Why this fork? 🤔
I needed something to fix my `Razer Orochi v2` which started to double click basically every button after a year of use (shame on you Razer).

I was already using [SensibleSideButtons](https://github.com/archagon/sensible-side-buttons) by [Alexei Baboulevitch](https://github.com/archagon) and I wanted to add **_debouncing_** to it, but the project is abandoned for a while and I didn't want to maintain it in Objective-C.

I thought about rewriting the parts I was interested in but then I found [SaneSideButtons](https://github.com/thealpa/SaneSideButtons) by [Jan Hülsmann](https://github.com/thealpa) which had already done the hardest part.

This fork is for my personal use, but if you have the same problem and don't want to compile it yourself, feel free to open an issue on this repository and I can provide you a working build.

# SaneSideButtons (original)
<p align="center">
	<img src="icon.png" width=150 />
</p>

macOS mostly ignores the M4/M5 mouse buttons, commonly used for navigation. Third-party apps can bind them to ⌘+[ and ⌘+], but this only works in a small number of apps and feels janky. With this tool, your side buttons will simulate 3-finger swipes, allowing you to navigate almost any window with a history. As seen in the Logitech MX Master!

## About SaneSideButtons

SaneSideButtons is a fork of the abandoned [SensibleSideButtons](https://github.com/archagon/sensible-side-buttons) by Alexei Baboulevitch. More information about SensibleSideButtons can be found on his [website](https://sensible-side-buttons.archagon.net/). Please consider using his [Amazon affiliate link](http://amzn.to/2tlwbAB) when making any purchase.

Starting with version 1.0.7 SaneSideButtons is maintained by [Jan Hülsmann](https://github.com/thealpa) and offers native Apple Silicon support.

## Installation

Download SaneSideButtons from [here](https://github.com/thealpa/SaneSideButtons/releases/download/1.1.0/SaneSideButtons.dmg) or install using Homebrew:

```bash
brew install --cask sanesidebuttons
```

## Compatibility

- macOS Ventura (13.0) and above
- Intel and Apple Silicon

## Automatic launch
To launch SaneSideButtons automatically when you log in on your Mac:

1. Click the `System Preferences` icon in the Dock or choose Apple menu  > System Preferences.
1. Open the `General` preference pane.
1. Click on `Login Items` in the right preference pane.
1. Click on the plus button at the bottom of the `Open at Login` pane.
1. Navigate to your Applications folder (or wherever you put the app) and double-click `SaneSideButtons`.
