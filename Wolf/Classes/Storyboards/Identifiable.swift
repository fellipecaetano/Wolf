import Foundation

protocol Identifiable {
    associatedtype Identifier
    static var identifier: Identifier { get }
}

extension Identifiable where Self.Identifier == String {
    static var identifier: String {
        return String(self)
    }
}
