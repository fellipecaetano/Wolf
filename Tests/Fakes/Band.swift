import Alamofire
import Wolf

struct Band: Decodable {
    let name: String
}

extension Band {
    enum Resource: HTTPResource {
        typealias Value = Band

        case getBand
        case getValidatedBand(Error)
        case getBands
        case getInvalidSchemaBand
        case getInvalidFormatBand

        var path: String {
            switch self {
            case .getBand, .getValidatedBand:
                return "band"
            case .getBands:
                return "bands"
            case .getInvalidSchemaBand:
                return "bands/invalid_schema"
            case .getInvalidFormatBand:
                return "bands/invalid_format"
            }
        }

        func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.SerializationResult {
            switch self {
            case .getValidatedBand(let error):
                return .failure(error)
            default:
                return .success
            }
        }
    }
}
