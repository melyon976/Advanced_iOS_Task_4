//
//  Dementia_App_PrototypeApp.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon on 19/8/2025.
//

import SwiftUI
import FirebaseCore
import UserNotifications

@main
struct Dementia_App_PrototypeApp: App {
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // this will register app delegate for Firebase Firestore setup
    var body: some Scene {
        WindowGroup {
            LandingPage1()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate { //networking layer for integrating cloud data management
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        registerForNotifications()
        return true
    }
    
    func registerForNotifications() {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.badge, .banner, .list, .sound]
    }
}
