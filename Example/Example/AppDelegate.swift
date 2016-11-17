import UIKit
import OHHTTPStubs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        installNetworkStubs()
        installKeyWindow()
        return true
    }

    private func installKeyWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(
            rootViewController: Storyboard.Main.instantiateViewController() as PopularShowsViewController
        )
        window?.makeKeyAndVisible()
    }

    private func installNetworkStubs() {
        _ = stub(condition: isPath("/shows/popular")) { _ in
            return fixture(filePath: OHPathForFile("popular_shows.json", type(of: self))!, headers: nil)
        }
    }
}
