import Foundation

public protocol NSDictionaryConvertible {
    init?(dictionary: NSDictionary)
    func asDictionary() -> NSDictionary
}

public struct KeyedArchive<T: protocol<NSDictionaryConvertible, URLConvertible>>: Archiving, Unarchiving {
    public typealias Object = T

    public func archive(rootObject: T) -> Bool {
        return NSKeyedArchiver.archiveRootObject(rootObject.asDictionary(),
                                                 toFile: T.URL.absoluteString)
    }

    public func unarchive() throws -> T {
        guard let unarchived = NSKeyedUnarchiver.unarchiveObjectWithFile(T.URL.absoluteString) else {
            throw UnarchivingError.FailedReading
        }
        guard let dictionary = unarchived as? NSDictionary, object = T(dictionary: dictionary) else {
            throw UnarchivingError.WrongType
        }
        return object
    }
}
