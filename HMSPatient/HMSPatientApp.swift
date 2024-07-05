import SwiftUI
import Firebase

@main
struct HMSPatientApp: App {
    // Use the custom AppDelegate class
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Authentication()
        }
    }
}
