import BrightFutures

public protocol Archiving {
    associatedtype Object
    func archive(rootObject: Object) -> Bool
}

public extension Archiving where Self: Asynchronous {
    func archive(rootObject: Object) -> Future<Object, ArchivingError> {
        let promise = Promise<Object, ArchivingError>()

        dispatch {
            do {
                try self.tryToArchive(rootObject)
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
    func tryToArchive(rootObject: Object) throws {
        if !archive(rootObject) {
            throw ArchivingError.FailedWriting
        }
    }
}

public enum ArchivingError: ErrorType {
    case FailedWriting
    case Unknown
}
