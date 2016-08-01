import UIKit
import OHHTTPStubs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        installNetworkStubs()
        installKeyWindow()
        return true
    }

    private func installKeyWindow() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = UINavigationController(
            rootViewController: Storyboard.Main.instantiateViewController() as PopularShowsViewController
        )
        window?.makeKeyAndVisible()
    }

    private func installNetworkStubs() {
        stub(isPath("/shows/popular")) { _ in
            return fixture(OHPathForFile("popular_shows.json", self.dynamicType)!, headers: nil)
        }
    }
}
