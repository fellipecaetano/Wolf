import Photos.PHPhotoLibrary
import PromiseKit

/**
 To import the `PHPhotoLibrary` category:

    use_frameworks!
    pod "PromiseKit/Photos"

 And then in your sources:

    import PromiseKit
*/
extension PHPhotoLibrary {
    /**
     - Returns: A promise that fulfills with the user’s authorization
     - Note: This promise cannot reject.
     */
    public class func requestAuthorization() -> Guarantee<PHAuthorizationStatus> {
        return Guarantee(.pending) { PHPhotoLibrary.requestAuthorization($0) }
    }
}
