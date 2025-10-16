//
//  NotificationManager.swift
//  Dementia App Prototype
//
//  Created by Grace on 16/10/2025.
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
    
    func scheduleReminders(for taskName: String, at date: Date) {
        let intervals = [15, 10, 5] // minutes before the task
        for minutesBefore in intervals {
            let triggerTime = date.addingTimeInterval(-Double(minutesBefore * 60))
            if triggerTime > Date() {
                let content = UNMutableNotificationContent()
                content.title = "Upcoming Task"
                content.body = "\(taskName) is due in \(minutesBefore) minutes."
                content.sound = .default
                
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling \(minutesBefore)-minute reminder: \(error)")
                    } else {
                        print("Scheduled \(minutesBefore)-minute reminder for \(taskName)")
                    }
                }
            }
        }
    }
    
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
