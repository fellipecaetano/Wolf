# Wolf

[![CI Status](http://img.shields.io/travis/Fellipe Caetano/Wolf.svg?style=flat)](https://travis-ci.org/Fellipe Caetano/Wolf)
[![Version](https://img.shields.io/cocoapods/v/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)
[![License](https://img.shields.io/cocoapods/l/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)
[![Platform](https://img.shields.io/cocoapods/p/Wolf.svg?style=flat)](http://cocoapods.org/pods/Wolf)

Wolf is a collection of solutions to common problems faced when developing iOS apps. Currently it features an opinionated networking layer and type-safe routines to ease management of reusable views and storyboards, but the list will hopefully grow in the near future.

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

If you [Argo](https://github.com/thoughtbot/Argo) is your option for JSON decoding, you can define a `HTTPResource` for a `Decodable` value that may fail with an `ArgoResponseError` and the `ResponseSerializers` come for free:

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


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Wolf is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Wolf"
```

## Author

Fellipe Caetano, fellipe.caetano@movile.com

## License

Wolf is available under the MIT license. See the LICENSE file for more info.
