import UIKit
import Firebase
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Register for remote notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Register background tasks
        registerBackgroundTasks()
        
        return true
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.app.fetchRecords", using: nil) { task in
            self.handleFetchRecordsTask(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.app.uploadFiles", using: nil) { task in
            self.handleUploadFilesTask(task: task as! BGProcessingTask)
        }
    }
    
    private func handleFetchRecordsTask(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Fetch records in the background
        DataController.shared.fetchCurrentUserDocumentsInBackground { records in
            // Save or process the records as needed
            task.setTaskCompleted(success: true)
        }
    }
    
    private func handleUploadFilesTask(task: BGProcessingTask) {
        scheduleProcessingTask()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Upload files in the background
        DataController.shared.uploadPendingFiles { success in
            task.setTaskCompleted(success: success)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.example.app.fetchRecords")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch every 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: "com.example.app.uploadFiles")
        request.requiresNetworkConnectivity = true // Need internet
        request.requiresExternalPower = false // Can run without power
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule processing task: \(error)")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
        scheduleProcessingTask()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        // This is a custom notification, handle it as appropriate
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle display notification while app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // Handle tapped notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler()
            return
        }
        // This is a custom notification, handle it as appropriate
        completionHandler()
    }
}
