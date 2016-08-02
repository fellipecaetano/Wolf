# Wolf

[![CI Status](http://img.shields.io/travis/fellipecaetano/Wolf.svg?style=flat)](https://travis-ci.org/fellipecaetano/Wolf)
[![Version](https://img.shields.io/cocoapods/v/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)
[![License](https://img.shields.io/cocoapods/l/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)
[![Platform](https://img.shields.io/cocoapods/p/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)

Wolf is a collection of solutions to common problems faced when developing iOS apps. Currently it features an opinionated networking layer and type-safe routines to ease management of reusable views and storyboards, and the list is likely to grow in the near future.

## Contents

- [Principles](#principles)
- [Usage](#usage)
    - [Networking](#networking)
    - [Reusable views](#reusable-views)
    - [Storyboards](#storyboards)
- [Example](#example)
- [Testing](#testing)
- [Requirements](#requirements)
- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Principles

A good deal of effort and energy spent on app development is dedicated to common tasks that are observed across almost all kinds of projects. There are many ways to address this duplication, but for most teams they are not standard and sometimes the wheel is re-invented for various reasons. Wolf aims to provide at least a starting point and a healthy baseline for the average iOS developer's everyday boilerplate. Its features include:

- **JSON-capable networking**: JSON APIs are commonplace in app development, so it's important to work over a solid networking layer that plays nicely with JSON.
- **Reusable view management**: arguably the most commonly used UIKit components are `UITableViews` and `UICollectionViews`, and Wolf packs a solution to registration and dequeuing of reusable cells that is concise and elegant.
- **Storyboard management**: programatic access to storyboards tends to become verbose quickly. Wolf presents a type-safe, protocol-based approach that strives for clarity while avoiding bloat.

## Usage

All of Wolf's features can be used in the same project or be integrated individually. It's up to you.

### Networking

The `HTTPResource` protocol formally defines [Alamofire](https://github.com/Alamofire/Alamofire) requests:

```swift
enum Resource: HTTPResource {
    typealias Value = // ...
    typealias Error = // ...

    // ... 
    
    var path: String {
        return "..."
    }

    var method: Alamofire.Method {
        return .GET
    }

    var parameters: [String: AnyObject]? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return .URL
    }
    
    func serialize(data: NSData?, error: NSError?) -> Result<Value, Error> {
        return .Success(/*...*/)
    }

    func serializeArray(data: NSData?, error: NSError?) -> Result<[Value], Error> {
        return .Success([/*...*/])
    }
}
```

You would typically describe a `HTTPClient` responsible for performing requests:

```swift
class ExampleClient: HTTPClient {
    var baseURL: NSURL {
        return NSURL(string: "https://example.com")!
    }
    
    let manager = Manager()
}
```

A `HTTPResource` knows how to create an Alamofire `ResponseSerializer`, so responses are automatically decoded:

```swift
//...

client.sendRequest(Resource.get) { (response: Alamofire.Response<Value, Error>) in
    // ...
}

//...
```

If [Argo](https://github.com/thoughtbot/Argo) is your option for JSON decoding, you can define a `HTTPResource` for a `Decodable` value. If the described request may fail with an `ArgoResponseError`, the `ResponseSerializers` come for free:

```swift
struct DecodableValue: Decodable {
    // ...
}

enum Resource: HTTPResource {
    typealias Value = DecodableValue
    typealias Error = ArgoResponseError

    // ... 
    
    var path: String {
        return "..."
    }

    var method: Alamofire.Method {
        return .GET
    }

    var parameters: [String: AnyObject]? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return .URL
    }
}
```

### Reusable views

The `Reusable` protocol defines a reusable resource. The `reuseIdentifier` is optional since its default implementation is the name of the resource's type:

```swift
class TableViewCell: UITableViewCell, Reusable {}
```

An extension to `UITableView` and `UICollectionView` allows type-safe cell dequeuing that's powered by inference:

```swift
func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell: CollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
    // ...
    return cell
}
```

Optionally, you may also provide conformance to a `NibLoadable` protocol that defines NIB-based resources. The name of the `UINib` that describes the resource is the conforming type's name by default:

```swift
class TableViewCell: UITableViewCell, Reusable, NibLoadable {}
```

`UITableViewCells` and `UICollectionViewCells` that conform to both `Reusable` and `NibLoadable` can be registered efforlessly with another extension to `UITableView` and `UICollectionView`:

```swift
class ViewController: UITableViewController {
    // ...
    override func viewDidLoad() {
        // ...
        tableView.register(TableViewCell)
    }
    // ...
}
```

### Storyboards

A type conforming to `StoryboardConvertible` describes a `.storyboard` file with a `name` and a `bundle`, which is the main bundle by default. If your `StoryboardConvertible` is a `String`-based `RawRepresentable`, the default implementation for `name` is the `rawValue`:

```swift
enum Storyboard: String, StoryboardConvertible {
    case Main
}
```

`StoryboardConvertible` instances can instantiate view controllers that conform to `Identifiable` using type inference, which greatly reduces verbosity. If the `Identifier` type of the `Identifiable` view controller is a `String`, its default implementation is the type's name:

```swift
class ViewController: UIViewController, Identifiable {}

// ...

let viewController: ViewController = Storyboard.Main.instantiateViewController()

```

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

## Author

Fellipe Caetano, fellipe.caetano4@gmail.com

## License

Wolf is available under the MIT license. See the LICENSE file for more info.
