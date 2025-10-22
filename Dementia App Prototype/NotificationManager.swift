//
//  NotificationManager.swift
//  Dementia App Prototype
//
//  Created by Melissa Lyon, Chi Sum Lau, Jeffery Wang on 16/10/2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
        //UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
    }
    
    func scheduleNotification(for taskTitle: String, at taskDate: Date, reminderMinutes: Int = 0) {
        let content = UNMutableNotificationContent()
        
        if reminderMinutes > 0 {
            content.title = "Task Reminder"
            content.body = "\(taskTitle) is due in \(reminderMinutes) minute\(reminderMinutes > 1 ? "s" : "")"
        } else {
            content.title = "Task Due"
            content.body = "\(taskTitle) is due now"
        }
        
        content.sound = .default
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -reminderMinutes, to: taskDate)!
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, triggerDate.timeIntervalSinceNow),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification scheduled for \(taskTitle) at \(triggerDate)")
            }
        }
    }
    
    //use for testing
    func triggerInstantTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification triggered by your button."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            } else {
                print("Notification scheduled to appear in 1 second.")
            }
        }
    }
}
