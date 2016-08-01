import Foundation
import Argo

extension NSURL: Decodable {
    public static func decode(json: JSON) -> Decoded<NSURL> {
        switch json {
        case .String(let string):
            return .fromOptional(NSURL(string: string))
        default:
            return .typeMismatch("String", actual: json.description)
        }
    }
}
