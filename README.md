# Wolf

[![CI Status](http://img.shields.io/travis/fellipecaetano/Wolf.svg?style=flat)](https://travis-ci.org/fellipecaetano/Wolf)
[![Version](https://img.shields.io/cocoapods/v/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)
[![License](https://img.shields.io/cocoapods/l/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)
[![Platform](https://img.shields.io/cocoapods/p/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)

Wolf approaches networking by bringing together the battle experience of Alamofire and the flexible power of Swift protocols. It enables developers to fully describe HTTP resources and it derives all HTTP communications out of those descriptions. Support for caching and JSON comes out of the box.

## Contents

- [Example](#example)
- [Testing](#testing)
- [Requirements](#requirements)
- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Example

Inside the `Example` directory you will find a sample application that presents a grid of popular TV shows, demonstrating how everything works together. To run it:

1. Clone the repository
2. Enter the `Example` directory
3. Open the `Wolf.xcworkspace` file in Xcode 7.3
4. Select the `Wolf-Example` target in the target selection dropdown near the `Stop` button
5. Build and run the application

## Testing

Inside the `Example` directory you will find a project holding the tests for Wolf. To run them:

1. Clone the repository
2. Enter the `Example` directory
3. Open the `Wolf.xcworkspace` file in Xcode 7.3
4. Select the `Wolf-Example` target in the target selection dropdown near the `Stop` button
5. Press `⌘U` or click `Test` from the `Product` menu

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

### CocoaPods

Wolf is available through [CocoaPods](http://cocoapods.org), a dependency manager for Cocoa projects. CocoaPods can be downloaded as a stand-alone app and can also be installed through [RubyGems](https://rubygems.org/):

```bash
$ gem install cocoapods
```

To integrate Wolf into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target '<target_name>' do
  pod 'Wolf'
end
```

Then, install your dependencies through the CocoaPods app or by running the following command in the same directory as your `Podfile`:

```bash
$ pod install
```
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following commands:

```bash
$ brew update
$ brew install carthage
```

To integrate Wolf into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "fellipecaetano/Wolf"
```

Run `carthage update` to build the framework and drag the built `Wolf.framework` into your Xcode project.

## Author

Fellipe Caetano, fellipe.caetano4@gmail.com

## License

Wolf is available under the MIT license. See the LICENSE file for more info.
