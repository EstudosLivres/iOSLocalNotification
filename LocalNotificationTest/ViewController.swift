//
//  ViewController.swift
//  TestLocalNotification
//
//  Created by Ilton Garcia on 29/06/17.
//  Copyright © 2017 Ilton Garcia. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class ViewController: UIViewController {

    let REQUEST_IDENTIFIER = "TestNotificationApp"
    var center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        center = UNUserNotificationCenter.current()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func notify(_ sender: Any) {
        print("it will notify")
        
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                // Single Notification
                // let interval = TimeInterval(CFCalendarUnit.hour.rawValue)
                // self.registerNotification(content: self.loremContent(), at: Date())
                
                // Dieta Fit Notifications
                for meal in self.meals() {
                    let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
                    let cal = Calendar.current
                    var components = cal.dateComponents(x, from: Date())
                    components.timeZone = TimeZone(abbreviation: "UTC")
                    let mealAt = meal["at"]!.characters.split{$0 == ":"}
                    
                    components.hour = Int("\(mealAt[0])")
                    components.minute = Int("\(mealAt[1])")
                    components.second = Int("\(mealAt[2])")
                    let at = cal.date(from: components)

                    self.registerNotification(content: self.setupContentFrom(dictionary: meal), at: at!)
                }
            } else {
                print("notification not authorized")
            }
        })
    }
    
    private func registerNotification(content: UNMutableNotificationContent, at: Date) {
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(CFCalendarUnit.day.rawValue), repeats: true)
        let request = UNNotificationRequest(identifier: self.REQUEST_IDENTIFIER + at.description, content: content, trigger: trigger)
        
        center.delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            if (error != nil) {
                print(error?.localizedDescription ?? "notification error")
            }
        }
    }
    
    private func meals() -> Array<Dictionary<String, String>> {
        let title = "Hora da refeição"
        
        return [
            ["id": "1", "at": "07:00:00", "title": title, "type": "Café da Manhã"],
            ["id": "9", "at": "08:30:00", "title": title, "type": "Pré-Treino"],
            ["id": "3", "at": "13:00:00", "title": title, "type": "Almoço"],
            ["id": "4", "at": "17:00:00", "title": title, "type": "Lanche da Tarde"],
            ["id": "6", "at": "21:00:00", "title": title, "type": "Jantar"]
        ]
    }
    
    private func setupContentFrom(dictionary: Dictionary<String, String>) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = dictionary["title"]!
        // content.subtitle = dictionary["subtitle"]!
        content.body = "Daqui a 10min será o seu " + dictionary["type"]!
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "test.DietaFitLocalNotification"
        return content
    }
    
    private func loremContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.subtitle = "Lets code,Talk is cheap"
        content.body = "Buy some milk lac free"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "test.LocalNotification"
        return content
    }

}

extension ViewController:UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Tapped on the notification")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    // ***************** THAT IS THE FUNCTION THAT WAS MISSING!!!!!! *****************
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber += 0
        completionHandler(.badge)
        
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
//        if notification.request.identifier == self.REQUEST_IDENTIFIER {}
    }
    
}

