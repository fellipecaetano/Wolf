# IBentifiers

[![CI Status](http://img.shields.io/travis/fellipecaetano/IBentifiers.svg?style=flat)](https://travis-ci.org/fellipecaetano/IBentifiers)
[![Version](https://img.shields.io/cocoapods/v/IBentifiers.svg?style=flat)](http://cocoapods.org/pods/IBentifiers)
[![License](https://img.shields.io/cocoapods/l/IBentifiers.svg?style=flat)](http://cocoapods.org/pods/IBentifiers)
[![Platform](https://img.shields.io/cocoapods/p/IBentifiers.svg?style=flat)](http://cocoapods.org/pods/IBentifiers)

## Testing

Inside the `Example` directory you will find a project holding the tests for IBentifiers. To run them:

1. Clone the repository
2. Enter the `Example` directory
3. Open the `IBentifiers.xcworkspace` file in Xcode 8.0
4. Select the `IBentifiers-Example` target in the target selection dropdown near the `Stop` button
5. Press `⌘U` or click `Test` from the `Product` menu

## Requirements

- iOS 9.0+
- Xcode 8.0+

## Installation

### CocoaPods

IBentifiers is available through [CocoaPods](http://cocoapods.org), a dependency manager for Cocoa projects. CocoaPods can be downloaded as a stand-alone app and can also be installed through [RubyGems](https://rubygems.org/):

```bash
$ gem install cocoapods
```

To integrate IBentifiers into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target '<target_name>' do
  pod 'IBentifiers'
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

To integrate IBentifiers into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "fellipecaetano/IBentifiers"
```

Run `carthage update` to build the framework and drag the built `IBentifiers.framework` into your Xcode project.

## Author

Fellipe Caetano, fellipe.caetano4@gmail.com.

## License

IBentifiers is available under the MIT license. See the LICENSE file for more info.
