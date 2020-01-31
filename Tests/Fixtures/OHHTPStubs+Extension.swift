import Foundation
import OHHTTPStubs

#if canImport(OHHTTPStubsSwift)
    import OHHTTPStubsSwift
#endif

public func UrlForFile(_ fileName: String) -> URL {
    let baseURL = localURLForTest()
    guard let enumerator = FileManager.default.enumerator(
        at: baseURL,
        includingPropertiesForKeys: [.nameKey],
        options: [.skipsHiddenFiles, .skipsPackageDescendants],
        errorHandler: nil
        ), let url = enumerator.first(where: { ($0 as? URL)?.lastPathComponent == fileName }) as? URL else {
        fatalError("Could not enumerate \(baseURL)")
    }
    return url
}

public func GetPathForFile(_ fileName: String, _ classType: AnyClass) -> String {
    #if SWIFT_PACKAGE
    return PathForFile(fileName)
    #else
    return OHPathForFile(fileName, classType)!
    #endif
}

private func localURLForTest() -> URL {
    let fileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
    return fileURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

private func PathForFile(_ fileName: String) -> String {
    return UrlForFile(fileName).path
}
