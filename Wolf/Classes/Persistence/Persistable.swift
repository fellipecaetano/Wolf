import Foundation

public protocol Persistable {
    var path: String { get }
}

public protocol File: URLConvertible {
    var baseURL: NSURL { get }
    var path: String { get }
}

public extension File {
    var URL: NSURL {
        return baseURL.URLByAppendingPathComponent(path)
    }
}

public protocol Cacheable {}

public extension Cacheable where Self: File {
    var baseURL: NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory,
                                                               inDomains: .UserDomainMask)[0]
    }
}

public protocol URLConvertible {
    var URL: NSURL { get }
}
