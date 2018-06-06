<p align="center"><img src="https://cloud.githubusercontent.com/assets/1567433/13918338/f8670eea-ef7f-11e5-814d-f15bdfd6b2c0.png" height="180"/>

<p align="center">
<img src="https://img.shields.io/cocoapods/v/Nuke.svg?label=version">
<img src="https://img.shields.io/badge/supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-green.svg">
<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg">
<a href="https://travis-ci.org/kean/Nuke"><img src="https://img.shields.io/travis/kean/Nuke/master.svg"></a>
</p>

A powerful **image loading** and **caching** system. It makes simple tasks like loading images into views extremely simple, while also supporting more advanced features for more demanding apps.

- Two [cache layers](https://kean.github.io/post/image-caching), fast LRU disk and memory caches
- Progressive image loading (progressive JPEG and WebP)
- Resumable downloads, request deduplication, prioritization, rate limiting and more
- [Alamofire](https://github.com/kean/Nuke-Alamofire-Plugin), [WebP](https://github.com/ryokosuge/Nuke-WebP-Plugin), [Gifu](https://github.com/kean/Nuke-Gifu-Plugin), [FLAnimatedImage](https://github.com/kean/Nuke-FLAnimatedImage-Plugin) extensions
- [RxNuke](https://github.com/kean/RxNuke) - [RxSwift](https://github.com/ReactiveX/RxSwift) extensions
- Automates [prefetching](https://kean.github.io/post/image-preheating) with [Preheat](https://github.com/kean/Preheat) (*deprecated in iOS 10*)

# <a name="h_getting_started"></a>Quick Start

> Upgrading from the previous version? Use a [**Migration Guide**](https://github.com/kean/Nuke/blob/master/Documentation/Migrations).

- Basic [**Usage Guide**](#h_usage), best place to start
  - [Load Image into Image View](#load-image-into-image-view)
  - [Placeholders, Transitions and More](#placeholders-transitions-and-more)
  - [Image Requests](#image-requests), [Process an Image](#process-an-image)
  - [Image Pipeline](#image-pipeline), [Configuring Image Pipeline](#configuring-image-pipeline)
- [**Advanced Usage Guide**](#advanced-usage)
  - [Memory Cache](#memory-cache), [HTTP Disk Cache](#http-disk-cache), [Aggressive Disk Cache (Beta)](#aggressive-disk-cache-experimental)
  - [Preheat Images](#preheat-images)
  - [Progressive Decoding](#progressive-decoding), [Animated Images](#animated-images), [WebP](#webp)
  - [RxNuke](#rxnuke)
- Detailed [**Image Pipeline**](#h_design) description
- Entire section dedicated to [**Performance**](#h_performance)
- List of [**Extensions**](#h_plugins), both official and built by the community
- [**Requirements**](#h_requirements)

More information is available in [**Documentation**](https://github.com/kean/Nuke/blob/master/Documentation/) directory and a full [**API Reference**](https://kean.github.io/Nuke/reference/7.0/index.html). When you are ready to install Nuke you can follow an [**Installation Guide**](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Installation%20Guide.md) - all major package managers are supported.

# <a name="h_usage"></a>Usage

#### Load Image into Image View

You can load an image into an image view with a single line of code:

```swift
Nuke.loadImage(with: url, into: imageView)
```

Nuke will automatically load image data, decompress it in the background, store image in memory cache and display it.
ƒ
> To learn more about the image pipeline [see the dedicated section](#h_design).

Nuke keeps track of each image view. When you request a new image for a view the previous outstanding request gets cancelled. The same happens automatically when the view is deallocated.

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    ...
    // Previous request for the image view gets cancelled. The view is
    // automatically prepared for reuse (image set to `nil`).
    Nuke.loadImage(with: url, into: cell.imageView)
    ...
}
```

#### Placeholders, Transitions and More

You can use an  `options` parameter (`ImageLoadingOptions`)  to customize the way images are loaded and displayed. You can provide a placeholder, select one of the built-in transitions or provide a custom one:

```swift
Nuke.loadImage(
    with: url,
    options: ImageLoadingOptions(
        placeholder: UIImage(named: "placeholder"),
        transition: .fadeIn(0.33)
    ),
    into: imageView
)
```

There is also a very common scenario when the placeholder (or the failure image) needs to be displayed with a content mode different from the one used for the loaded image. `ImageLoadingOptions` supports precisely that:

```swift
let options = ImageLoadingOptions(
    placeholder: UIImage(named: "placeholder"),
    failureImage: UIImage(named: "failure_image"),
    contentModes = .init(
        success: .scaleAspectFill,
        failure: .center,
        placeholder: .center
    )
)

Nuke.loadImage(with: url, options: options, into: imageView)
```

If you find yourself in a situation where you need some feature that is not implemented by `ImageLoadingOptions`, it might mean that you need to use `ImagePipeline` directly to fetch an image and then display it. 

> To make all image views in the app share the same behaviour modify `ImageLoadingOptions.shared`.

#### Image Requests

Each request is represented by an `ImageRequest` struct. A request can be created with either `URL` or `URLRequest`.

```swift
var request = ImageRequest(url: url)
// var request = ImageRequest(urlRequest: URLRequest(url: url))

// Change memory cache policy:
request.memoryCacheOptions.isWriteAllowed = false

// Update the request priority:
request.priority = .high

Nuke.loadImage(with: request, into: imageView)
```

#### Process an Image

Nuke can process images for you. The first option is to resize the image using a `Request`:

```swift
/// Target size is in pixels.
ImageRequest(url: url, targetSize: CGSize(width: 640, height: 320), contentMode: .aspectFill)
```

To perform a custom tranformation use a `processed(key:closure:)` method. Her's how to create a circular avatar using [Toucan](https://github.com/gavinbunney/Toucan):

```swift
ImageRequest(url: url).process(key: "circularAvatar") {
    Toucan(image: $0).maskWithEllipse().image
}
```

All of those APIs are built on top of `ImageProcessing` protocol. If you'd like to you can implement your own processors that adopt it. Keep in mind that `ImageProcessing` also requires `Equatable` conformance which helps Nuke identify images in memory cache.

> See [Core Image Integration Guide](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Core%20Image%20Integration%20Guide.md) for more info about using Core Image with Nuke

#### Image Pipeline

You can use `ImagePipeline` to load images directly without a view. `ImagePipeline` offers a convenience closure-based API for loading images:

```swift
let task = ImagePipeline.shared.loadImage(
    with: url,
    progress: { _, completed, total in
        print("progress updated")
    },
    completion: { response, error in
        print("task completed")
    }
)

// task.cancel()
// task.setPriority(.high)
```

Tasks can be used to track download progress, cancel the requests, and dynamically udpdate download priority.

#### Configuring Image Pipeline

`ImagePipeline` is initialized with a `Configuration` which makes it fully customizable:

```swift
let pipeline = ImagePipeline {
    $0.dataLoader = /* your data loader */
    $0.dataLoadingQueue = OperationQueue() /* your custom download queue */
    $0.imageCache = /* your image cache */
    /* etc... */
}

// When you're done you can make the pipeline a shared one:
ImagePipeline.shared = pipeline
```

# Advanced Usage

#### Memory Cache

Default Nuke's `ImagePipeline` has two cache layers.

First, there is a memory cache for storing processed images ready for display. You can get a direct access to this cache:

```swift
// Configure cache
ImageCache.shared.costLimit = 1024 * 1024 * 100 // 100 MB
ImageCache.shared.countLimit = 100
ImageCache.shared.ttl = 120 // Invalidate image after 120 sec

// Read and write images
let request = ImageRequest(url: url)
ImageCache.shared[request] = image
let image = ImageCache.shared[request]

// Clear cache
ImageCache.shared.removeAll()
```

#### HTTP Disk Cache

To store unprocessed image data Nuke uses a `URLCache` instance:

```swift
// Configure cache
DataLoader.sharedUrlCache.diskCapacity = 100
DataLoader.sharedUrlCache.memoryCapacity = 0

// Read and write responses
let request = ImageRequest(url: url)
let _ = DataLoader.sharedUrlCache.cachedResponse(for: request.urlRequest)
DataLoader.sharedUrlCache.removeCachedResponse(for: request.urlRequest)

// Clear cache
DataLoader.sharedUrlCache.removeAllCachedResponses()
```

#### Aggressive Disk Cache (Experimental)

Add a completely new custom LRU disk cache which can be used for fast and reliable *aggressive* data caching (ignores [HTTP cache control](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control)). The new cache lookups are up to 2x faster than `URLCache` lookups. You can enable it using pipeline's configuration:

When enabling disk cache you must provide a `keyEncoder` function which takes image request's url as a parameter and produces a key which can be used as a valid filename. The [demo project uses sha1](https://gist.github.com/kean/f5e1975e01d5e0c8024bc35556665d7b) to generate those keys.

```swift
$0.enableExperimentalAggressiveDiskCaching(keyEncoder: {
    guard let data = $0.cString(using: .utf8) else { return nil }
    return _nuke_sha1(data, UInt32(data.count))
})
```

The public API for disk cache and the API for using custom disk caches is going to be available in the future versions.

> Existing API already allows you to use custom disk cache [by implementing `DataLoading` protocol](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Third%20Party%20Libraries.md#using-other-caching-libraries), but this is not the most straightforward option.

#### Preheat Images

[Preheating](https://kean.github.io/post/image-preheating) (prefetching) means loading images ahead of time in anticipation of their use. Nuke provides a `ImagePreheater` class that does just that:

```swift
let preheater = ImagePreheater(pipeline: ImagePipeline.shared)

let requests = urls.map {
    var request = ImageRequest(url: $0)
    request.priority = .low
    return request
}

// User enters the screen:
preheater.startPreheating(for: requests)

// User leaves the screen:
preheater.stopPreheating(for: requests)
```

You can use Nuke in combination with [Preheat](https://github.com/kean/Preheat) library which automates preheating of content in `UICollectionView` and `UITableView`. On iOS 10.0 you might want to use new [prefetching APIs](https://developer.apple.com/reference/uikit/uitableviewdatasourceprefetching) provided by iOS instead.

> Check out [Performance Guide](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Performance%20Guide.md) to see what else you can do to improve performance

#### Progressive Decoding

To use progressive image loading you need a pipeline with progressive decoding enabled:

```swift
let pipeline = ImagePipeline {
    $0.isProgressiveDecodingEnabled = true
}
```

And that's it, you can start observing images as they are produced by the pipeline. The progress handler also works as a progressive image handler:

```swift
let imageView = UIImageView()
let task = ImagePipeline.shared.loadImage(
    with: url,
    progress: { image, _, _ in
        guard let image = image else { return }
        imageView.image = image
    },
    completion: { response, _ in
        guard let image = response?.image else { return }
        imageView.image = image
    }
)
```

The progressive decoding only kicks in when Nuke determines that the image data does contain a progressive JPEG. The decoder scans the data and only produces a new image when it receives a full new scan (progressive JPEGs normally have around 10 scans).

> See "Progressive Decoding" demo to see progressive JPEG in practice. You can also uncomment the code that blurs the first few scans of the image which makes them look a bit nicer.

#### Animated Images

Nuke extends `UIImage` with `animatedImageData` property. If you enable it by setting `ImagePipeline.Configuration.isAnimatedImageDataEnabled` to `true` the pipeline will start attaching original image data to the animated images (built-in decoder only supports GIFs for now).

> `ImageCache` takes  `animatedImageData` into account when computing the cost of cached items. `ImagePipeline` doesn't apply processors to the images with animated data.

There is no built-in way to render those images, there are though two integrations available: [FLAnimatedImage](https://github.com/kean/Nuke-FLAnimatedImage-Plugin) and [Gifu](https://github.com/kean/Nuke-Gifu-Plugin) which are both fast and efficient.

**Note:** `GIF` is not the most efficient format for transferring and displaying animated images. The current best practice is to [use short videos instead of GIFs](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/replace-animated-gifs-with-video/) (e.g. `MP4`, `WebM`). There is a PoC available in the demo project which uses Nuke to load, cache and dispay an `MP4` video.

#### WebP

WebP support is provided by [Nuke WebP Plugin](https://github.com/ryokosuge/Nuke-WebP-Plugin) built by [Ryo Kosuge](https://github.com/ryokosuge). Please follow the intructions from the repo to install it.

#### RxNuke

[RxNuke](https://github.com/kean/RxNuke) adds [RxSwift](https://github.com/ReactiveX/RxSwift) extensions for Nuke and enables many common use cases:

- [Going from low to high resolution](https://github.com/kean/RxNuke#going-from-low-to-high-resolution)
- [Loading the first available image](https://github.com/kean/RxNuke#loading-the-first-available-image)
- [Showing stale image while validating it](https://github.com/kean/RxNuke#showing-stale-image-while-validating-it)
- [Load multiple images, display all at once](https://github.com/kean/RxNuke#load-multiple-images-display-all-at-once)
- [Auto retry on failures](https://github.com/kean/RxNuke#auto-retry)
- And [more...](https://github.com/kean/RxNuke#use-cases)

Here's an example of how easy it is to load go flow log to high resolution:

```swift
let pipeline = ImagePipeline.shared
Observable.concat(pipeline.loadImage(with: lowResUrl).orEmpty,
                  pipeline.loadImage(with: highResUtl).orEmpty)
    .subscribe(onNext: { imageView.image = $0 })
    .disposed(by: disposeBag)
```

<a name="h_design"></a>
# Image Pipeline

Nuke's image pipeline consists of roughly five stages which can be customized using the following protocols:

|Protocol|Description|
|--------|-----------|
|`DataLoading`|Download (or return cached) image data|
|`ImageDecoding`|Convert data into image objects|
|`ImageProcessing`|Apply image transformations|
|`ImageCaching`|Store image into memory cache|

All those types come together the way you expect:

1. `ImagePipeline` checks if the image is in memory cache (`ImageCaching`). Returns immediately if finds it.
2. `ImagePipeline` uses underlying data loader (`DataLoading`) to fetch (or return cached) image data.
3. When the image data is loaded it gets decoded (`ImageDecoding`) creating an image object.
4. The image is then processed (`ImageProcessing`).
5. `ImagePipeline` stores the processed image in the memory cache (`ImageCaching`).

Nuke is fully asynchronous (non-blocking). Each stage is executed on a separate queue tailored specifically for it. Let's dive into each of those stages.

### Data Loading and Caching

A built-in `DataLoader` class implements `DataLoading` protocol and uses [`Foundation.URLSession`](https://developer.apple.com/reference/foundation/nsurlsession) to load image data. The data is cached on disk using a [`Foundation.URLCache`](https://developer.apple.com/reference/foundation/urlcache) instance, which by default is initialized with a memory capacity of 0 MB (Nuke stores images in memory, not image data) and a disk capacity of 150 MB.

The `URLSession` class natively supports the `data`, `file`, `ftp`, `http`, and `https` URL schemes. Image pipeline can be used with any of those schemes as well.

> See [Image Caching Guide](https://kean.github.io/post/image-caching) to learn more about image caching

> See [Third Party Libraries](https://github.com/kean/Nuke/blob/master/Documentation/Guides/Third%20Party%20Libraries.md#using-other-caching-libraries) guide to learn how to use a custom data loader or cache

Most developers either implement their own networking layer or use a third-party framework. Nuke supports both of those workflows. You can integrate your custom networking layer by implementing `DataLoading` protocol.

> See [Alamofire Plugin](https://github.com/kean/Nuke-Alamofire-Plugin) that implements `DataLoading` protocol using [Alamofire](https://github.com/Alamofire/Alamofire) framework

### Memory Cache

Processed images which are ready to be displayed are stored in a fast in-memory cache (`ImageCache`). It uses [LRU (least recently used)](https://en.wikipedia.org/wiki/Cache_algorithms#Examples) replacement algorithm and has a limit which prevents it from using more than ~20% of available RAM. As a good citizen, `ImageCache` automatically evicts images on memory warnings and removes most of the images when the application enters background.

### Resumable Downloads

If the data task is terminated (either because of a failure or a cancellation) and the image was partially loaded, the next load will resume where it was left off. 

Resumable downloads require server to support [HTTP Range Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests). Nuke supports both validators (`ETag` and `Last-Modified`). The resumable downloads are enabled by default.

> By default resumable data is stored in an efficient memory cache. Future versions might include more customization.

### Request Dedupication

By default `ImagePipeline` combines the requests for the same image (but can be different processors) into the same task. The task's priority is set to the highest priority of registered requests and gets updated when requests are added or removed to the task. The task only gets cancelled when all the registered requests are.

> Deduplication can be disabled using `ImagePipeline.Configuration`.

<a name="h_performance"></a>
# Performance

Performance is one of the key differentiating factors for Nuke. There are four key components of its performance:

### Main-Thread Performance

The framework has been tuned to do very little work on the main thread. There are a number of optimizations techniques that were used to achieve that including: reducing number of allocations, reducing dynamic dispatch, backing some structs by reference typed storage to reduce ARC overhead, etc.

### Robustness Under Stress

A common use case is to dynamically start and cancel requests for a collection view full of images when scrolling at a high speed. There are a number of components that ensure robustness in those kinds of scenarios:

- `ImagePipeline` schedules each of its stages on a dedicated queue. Each queue limits the number of concurrent tasks. This way we don't use too much system resources at any given moment and each stage doesn't block the other. For example, if the image doesn't require processing, it doesn't go through the processing queue.
- Under stress `ImagePipeline` will rate limit the requests to prevent trashing of the underlying systems (e.g. `URLSession`).

### Memory Usage

- Nuke tries to free memory as early as possible.
- Memory cache uses [LRU (least recently used)](https://en.wikipedia.org/wiki/Cache_algorithms#Examples) replacement algorithm. It has a limit which prevents it from using more than ~20% of available RAM. As a good citizen, `ImageCache` automatically evicts images on memory warnings and removes most of the images when the application enters background.

### Performance Metrics (Beta)

When optimizing performance, it's important to measure. Nuke collects detailed performance metrics during the execution of each image task:

```swift
ImagePipeline.shared.didFinishCollectingMetrics = { task, metrics in
    print(metrics)
}
```

![timeline](https://user-images.githubusercontent.com/1567433/39193766-8dfd81b2-47dc-11e8-86b3-f3f69dc73d3a.png)

```
(lldb) po metrics

Task Information {
    Task ID - 1
    Duration - 22:35:16.123 – 22:35:16.475 (0.352s)
    Was Cancelled - false
    Is Memory Cache Hit - false
    Was Subscribed To Existing Session - false
}
Session Information {
    Session ID - 1
    Total Duration - 0.351s
    Was Cancelled - false
}
Timeline {
    22:35:16.124 – 22:35:16.475 (0.351s) - Total
    ------------------------------------
    nil – nil (nil)                      - Check Disk Cache
    22:35:16.131 – 22:35:16.410 (0.278s) - Load Data
    22:35:16.410 – 22:35:16.468 (0.057s) - Decode
    22:35:16.469 – 22:35:16.474 (0.005s) - Process
}
Resumable Data {
    Was Resumed - nil
    Resumable Data Count - nil
    Server Confirmed Resume - nil
}
```

<a name="h_plugins"></a>
# Extensions

There are a variety extensions available for Nuke some of which are built by the community.

|Name|Description|
|--|--|
|[**RxNuke**](https://github.com/kean/RxNuke)|[RxSwift](https://github.com/ReactiveX/RxSwift) extensions for Nuke with examples of common use cases solved by Rx|
|[**Alamofire**](https://github.com/kean/Nuke-Alamofire-Plugin)|Replace networking layer with [Alamofire](https://github.com/Alamofire/Alamofire) and combine the power of both frameworks|
|[**WebP**](https://github.com/ryokosuge/Nuke-WebP-Plugin)| **[Community]** [WebP](https://developers.google.com/speed/webp/) support, built by [Ryo Kosuge](https://github.com/ryokosuge)|
|[**Gifu**](https://github.com/kean/Nuke-Gifu-Plugin)|Use [Gifu](https://github.com/kaishin/Gifu) to load and display animated GIFs|
|[**FLAnimatedImage**](https://github.com/kean/Nuke-AnimatedImage-Plugin)|Use [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) to load and display [animated GIFs]((https://www.youtube.com/watch?v=fEJqQMJrET4))|


<a name="h_requirements"></a>
# Minimum Requirements

- iOS 9.0 / watchOS 2.0 / macOS 10.10 / tvOS 9.0
- Xcode 9.2
- Swift 4.0

# License

Nuke is available under the MIT license. See the LICENSE file for more info.
