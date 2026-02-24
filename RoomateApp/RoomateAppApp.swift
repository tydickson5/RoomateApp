import SwiftUI
import GoogleSignIn
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
      }
}

@main
struct RoomateAppApp: App {
    // Register the delegate
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
      @StateObject private var authManager = AuthManager()
    @StateObject private var groupManager = GroupManager()

      var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(groupManager)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
      }
}
