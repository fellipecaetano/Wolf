public protocol URLConvertible {
    var baseURL: NSURL { get }
    var path: String { get }
}

public extension URLConvertible {
    var URL: NSURL {
        return baseURL.URLByAppendingPathComponent(path)
    }
}
