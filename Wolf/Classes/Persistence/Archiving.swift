import BrightFutures

public protocol Archiving {
    func archive(rootObject: AnyObject, toFile path: String) -> Bool
}

public extension Archiving {
    func tryToArchive(rootObject: AnyObject, toFile path: String) throws {
        if !archive(rootObject, toFile: path) {
            throw ArchivingError.FailedArchiving
        }
    }
}

public enum ArchivingError: ErrorType {
    case FailedArchiving
    case Unknown
}

public protocol Archivable {
    var archiving: Archiving { get }
}

public protocol NSDictionaryConvertible {
    init? (dictionary: NSDictionary)
    func asDictionary() -> NSDictionary
}

public extension Persistable where Self: protocol<Archivable, NSDictionaryConvertible, URLConvertible> {
    func archive(inQueue queue: dispatch_queue_t? = nil) -> Future<Self, ArchivingError> {
        let promise: Promise<Self, ArchivingError> = Promise()

        dispatch_async(queue ?? dispatch_get_main_queue()) {
            do {
                try self.archiving.tryToArchive(self.asDictionary(), toFile: self.URL.absoluteString)
                promise.success(self)
            } catch let error as ArchivingError {
                promise.failure(error)
            } catch {
                promise.failure(.Unknown)
            }
        }

        return promise.future
    }
}
