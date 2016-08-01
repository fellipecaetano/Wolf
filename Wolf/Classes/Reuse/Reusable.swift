import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(Self)
    }
}
