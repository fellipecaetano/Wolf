import BrightFutures

public protocol Archiving {
    func archive(rootObject: AnyObject, toFile path: String) -> Bool
}

public protocol Archivable {
    var archiving: Archiving { get }
}

public protocol NSDictionaryConvertible {
    init? (dictionary: NSDictionary)
    func asDictionary() -> NSDictionary
}

public extension Persistable where Self: protocol<Archivable, NSDictionaryConvertible, URLConvertible> {
    func archive() -> Future<Self, NSError> {
        archiving.archive(asDictionary(), toFile: URL.absoluteString)
        return Future(value: self)
    }
}
