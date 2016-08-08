public protocol URLConvertible {
    static var baseURL: NSURL { get }
    static var path: String { get }
}

public extension URLConvertible {
    static var URL: NSURL {
        return baseURL.URLByAppendingPathComponent(path)
    }
}

public protocol Cacheable {}

public extension Cacheable where Self: URLConvertible {
    static var baseURL: NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory,
                                                               inDomains: .UserDomainMask)[0]
    }
}
