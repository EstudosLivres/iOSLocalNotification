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

    let LOREM_IDENTIFIER = "test.LocalNotification"
    let MEALS_IDENTIFIER = "test.DietaFitLocalNotification"
    var notificationCenter = UNUserNotificationCenter.current()
    let CATEGORY_IDENTIFIER = UNNotificationCategory(identifier: "alarm", actions: [], intentIdentifiers: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        notificationCenter.delegate = self
        notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [self.LOREM_IDENTIFIER, self.MEALS_IDENTIFIER])
        notificationCenter.setNotificationCategories([self.CATEGORY_IDENTIFIER])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func notify(_ sender: Any) {
        print("it will notify")
        
        notificationCenter.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                // Single Notification
                // self.setupLoremNotification()
                
                
                // Dieta Fit Notifications
                for meal in self.meals() {
                    var at = DateComponents()
                    
                    let mealAtString = meal["at"]
                    let mealAtArray = mealAtString!.characters.split{$0 == ":"}
                    
                    at.hour = Int(String(mealAtArray[0]))
                    at.minute = Int(String(mealAtArray[1]))
                    at.second = Int(String(mealAtArray[2]))
                    
                    self.registerNotification(identifier: meal["id"]!, content: self.setupContentFrom(dictionary: meal), at: at)
                }
                
                self.alertScheduleDone()
            } else {
                print("notification not authorized")
            }
        })
    }
    
    private func registerNotification(identifier: String, content: UNMutableNotificationContent, at: DateComponents) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: at, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        print("Date Component: \(String(describing: at))")
        
        notificationCenter.add(request){(error) in
            if (error != nil) {
                print(error?.localizedDescription ?? "notification error")
            }
        }
    }
    
    private func setupLoremNotification() {
        let  content = self.loremContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (1*60), repeats: true)
        let request = UNNotificationRequest(identifier: content.categoryIdentifier, content: content, trigger: trigger)
        notificationCenter.delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            if (error != nil) {
                print(error?.localizedDescription ?? "notification error")
            }
        }
    }
    
    private func meals() -> Array<Dictionary<String, String>> {
        let title = "Hora da refeição"
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let nextMinute = formatter.string(from: now.addingTimeInterval(60))
        let nextSeconds = formatter.string(from: now.addingTimeInterval(20))
        
        print("ten seconds: \(nextSeconds)")
        print("a minute: \(nextMinute)")
        
        return [
            ["id": "1", "at": "07:00:00", "title": title, "type": "Café da Manhã"],
            ["id": "9", "at": "08:30:00", "title": title, "type": "Pré-Treino"],
            ["id": "3", "at": "13:00:00", "title": title, "type": "Almoço"],
            ["id": "4", "at": "17:00:00", "title": title, "type": "Lanche da Tarde"],
            ["id": "6", "at": "21:00:00", "title": title, "type": "Jantar"],
            ["id": "98", "at": nextMinute, "title": title, "type": "TEST NEXT MINUTE"],
            ["id": "99", "at": nextSeconds, "title": title, "type": "Notificação 10 segundos após o aceite das notificações"]
        ]
    }
    
    private func setupContentFrom(dictionary: Dictionary<String, String>) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = dictionary["title"]!
        // content.subtitle = dictionary["subtitle"]!
        content.body = "Daqui a 10min será o seu " + dictionary["type"]!
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = self.MEALS_IDENTIFIER
        return content
    }
    
    private func loremContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.subtitle = "Lets code,Talk is cheap"
        content.body = "Buy some milk lac free"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = self.LOREM_IDENTIFIER
        return content
    }
    
    private func alertScheduleDone() {
        let alert = UIAlertController(title: "Notificações Agendadas", message: "Todas notificações foram agendadas com sucesso!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

