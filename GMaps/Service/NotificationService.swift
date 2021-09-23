//
//  NotificationService.swift
//  GMaps
//
//  Created by Константин Кузнецов on 23.09.2021.
//

import Foundation
import UIKit

final class NotificationService {
    
    private let center = UNUserNotificationCenter.current()
    private var checkAccessStatus = false
    
    init(){
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            self?.checkAccessStatus = granted
        }
    }
    
    func checkAccess() -> Bool{
        
        checkAccessStatus
    }
    
    func setupNotification(){
        
        if(checkAccessStatus){
            sendNotificatioRequest(content: makeNotificationContent(), trigger: makeIntervalNotificatioTrigger())
        }
    }
    
    private func makeNotificationContent() -> UNNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = "Я скучаю"
        content.subtitle = "Мы так давно не виделись"
        content.body = "Как насчет немного трекинга?"
        content.badge = 1
        return content
    }
    
    private func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        
        UNTimeIntervalNotificationTrigger(
            timeInterval: 30,
            repeats: false
        )
    }
    
    private func sendNotificatioRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
        
        let request = UNNotificationRequest(
            identifier: "alaram",
            content: content,
            trigger: trigger
        )
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}
