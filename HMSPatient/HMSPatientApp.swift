import SwiftUI
import Firebase

@main
struct HMSPatientApp: App {
    // Use the custom AppDelegate class
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authManager = AuthManager()
    @AppStorage("isLoggedIn") private var isLoggedIn = false // Persistent login state

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HomeView()
                    .environmentObject(authManager)
                    .onAppear {
                        authManager.checkLoginState()
                    }
            } else {
                Authentication()
                    .environmentObject(authManager)
            }
        }
    }
}
