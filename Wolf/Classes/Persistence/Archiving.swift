import BrightFutures

public protocol Archiving {
    associatedtype Object
    func archive(rootObject: Object, toFile path: String) -> Bool
}

public protocol Asynchronous {
    var queue: dispatch_queue_t { get }
}

public extension Archiving where Self: Asynchronous {
    func archive(rootObject: Object, toFile path: String) -> Future<Object, ArchivingError> {
        let promise = Promise<Object, ArchivingError>()

        dispatch_async(queue) {
            do {
                try self.tryToArchive(rootObject, toFile: path)
                promise.success(rootObject)
            } catch let error as ArchivingError {
                promise.failure(error)
            } catch {
                promise.failure(.Unknown)
            }
        }

        return promise.future
    }
}

private extension Archiving {
    func tryToArchive(rootObject: Object, toFile path: String) throws {
        if !archive(rootObject, toFile: path) {
            throw ArchivingError.FailedWriting
        }
    }
}

public extension Archiving where Object: URLConvertible {
    func archive(rootObject: Object) -> Bool {
        return archive(rootObject, toFile: rootObject.URL.absoluteString)
    }
}

public extension Archiving where Object: URLConvertible, Self: Asynchronous {
    func archive(rootObject: Object) -> Future<Object, ArchivingError> {
        return archive(rootObject, toFile: rootObject.URL.absoluteString)
    }
}

public enum ArchivingError: ErrorType {
    case FailedWriting
    case Unknown
}

public protocol URLConvertible {
    var baseURL: NSURL { get }
    var path: String { get }
}

public extension URLConvertible {
    var URL: NSURL {
        return baseURL.URLByAppendingPathComponent(path)
    }
}
