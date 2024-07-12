import SwiftUI
import Firebase

@main
struct HMSPatientApp: App {
    // Use the custom AppDelegate class
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authManager = AuthManager()
    @State private var isLoggedIn = false // Track login state

    var body: some Scene {
        WindowGroup {
            Authentication()
                .environmentObject(authManager)
                .onAppear {
                    // Set up initial authentication state
                    isLoggedIn = authManager.isLoggedIn
                }
                .onChange(of: authManager.isLoggedIn) { newValue in
                    isLoggedIn = newValue
                }
        }
    }
}
