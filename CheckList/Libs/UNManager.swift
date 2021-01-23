//
//  UNManager.swift
//  CheckList
//
//  Created by Владислав on 23.01.2021.
//

import Foundation
import UserNotifications

final class UNManager {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestPermission(_ completionHandler: ((_ granted: Bool) -> Void)? = nil) {
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                completionHandler?(granted)
            }
        }
    }
    
    func scheduleNotification(with identifier: String,
                              title: String,
                              body: String = "",
                              date: Date,
                              completionHandler: ((Error?) -> Void)? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: notificationTrigger)
        
        notificationCenter.add(request) { error in
            DispatchQueue.main.async {
                completionHandler?(error)                
            }
        }
    }
    
    func cancelNotification(with identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
}
