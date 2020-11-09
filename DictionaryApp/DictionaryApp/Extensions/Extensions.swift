//
//  Extensions.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }
}

extension AlertPresentable where Self: UIViewController {
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true)
    }
    
}

extension LoaderPresentable where Self: UIViewController {
    
    func showLoader() {
        let dimmerView = UIView(frame: view.bounds)
        dimmerView.tag = 97
        dimmerView.alpha = 0
        dimmerView.backgroundColor = .white
        view.addSubview(dimmerView)
        
        var indicator = UIActivityIndicatorView()
        indicator.color = .systemGray
        
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .large)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        
        dimmerView.addSubview(indicator)
        indicator.frame = CGRect(x: view.center.x, y: view.frame.height / 3, width: 0, height: 0)
        
        UIView.animate(withDuration: 0.1, animations: {
            dimmerView.alpha = 1
        }) { (_) in
            indicator.startAnimating()
        }
    }
    
    func hideLoader() {
        for subview in view.subviews {
            if subview.tag == 97 {
                subview.removeFromSuperview()
            }
        }
    }
    
}

extension DateConvertable where Self: UIViewController {
    func convertToDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: date)
        
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateString = dateFormatter.string(from: date ?? Date())
        
        return dateString
    }
}

extension Notification.Name {
    static let didCompleteTask = Notification.Name("didCompleteTask")
    static let didCompleteDeleteTask = Notification.Name("didCompleteDeleteTask")
}
