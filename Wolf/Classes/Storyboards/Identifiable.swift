import Foundation

public protocol Identifiable {
    associatedtype Identifier
    static var identifier: Identifier { get }
}

public extension Identifiable where Self.Identifier == String {
    static var identifier: String {
        return String(self)
    }
}
