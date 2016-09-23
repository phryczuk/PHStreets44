<!--
 *  README.md
 *  PHStreets44 project - Streets '44 iOS app
 *
 *  Created by Pawel Hryczuk on 31.05.2015.
 *  Copyright (c) 2015 Pawel Hryczuk. All rights reserved.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
-->

# Streets '44

[![App Store](AppStoreBadge.jpg)](https://itunes.apple.com/pl/app/streets-44/id974553593)

Streets '44 is an app telling the story of [Warsaw Uprising](https://en.wikipedia.org/wiki/Warsaw_Uprising). It presents archival photos located on the original city map. They are followed by descriptions of key events and some less-known facts. The front line is updated daily. Narrative includes stories of civil inhabitants, thriving to survive the battle.

Streets '44 is a project consisting of this iOS app and its Android counterpart (available on [Google Play](https://play.google.com/store/apps/details?id=pl.zrodlapamieci.ulice44)). See our [home page](https://ulice44.wordpress.com) for details.

![](Screenshot.jpg "Screenshot")

## Features

- Well thought-out architecture with only one global state object and small view controllers
- Support for all iOS devices in portrait and landscape screen orientations (Auto Layout)
- UI implemented with Interface Builder (to simplify maintainability) and programmatically (where needed)
- Smooth animations of map regions (Core Graphics)
- Data store (NSUserDefaults) used to persist app state between launches
- Localized into English and Polish (other languages can be added easily)
- Google Analytics support

## Installation

Streets '44 compile in Xcode 8 and run on all iOS 8.1+ devices.

The app uses CocoaPods as a dependency manager. To get started type 

```
$ pod install
```

Now open PHStreets44.xcworkspace in Xcode and build the app. All classes should compile successfully without warnings.

## Development

This repository can be used as a template for similar apps which

- use a map as a key element
- have POIs with detailed descriptions and/or photos
- draw regions over the map
- have a timeline (POIs and regions may change over time)

### Note

Due to legal reasons certain assets are not available in this repository. Differences from the App Store version include

- Missing Warsaw map and historical photographs
- Missing launch image
- Less information on the Credits and Settings screens
- Disabled Google Analytics (put your tracking ID in PHAppDelegate.m)

## Contributing

Any pull request are welcome.

## Authors

Source code

- [Pawel Hryczuk](https://www.linkedin.com/in/pawel-hryczuk) - classes, storyboard and project files

Resources

- Artur Łysik and Łukasz Wojtach - historical assets
- Zofia Wojtach - graphics

## License

Source code is licensed under the terms of [GNU General Public License, version 3 or later](https://www.gnu.org/licenses/gpl.txt). Historical descriptions and graphical assets use [Creative Commons Attribution-ShareAlike 3.0 PL License](https://creativecommons.org/licenses/by-sa/3.0/pl). See [LICENSE](LICENSE) and [DEPENDENCIES.md](DEPENDENCIES.md) for details.

All contributors to this project agree to grant permission for Apple Inc. to re-license the GPL code under a non-GPL license for the purpose of distributing it in the iOS App Store.

## Contact

Tweet me ([@PawelHryczuk](https://twitter.com/PawelHryczuk)) or send an [email](mailto:aplikacjaulice44@gmail.com).