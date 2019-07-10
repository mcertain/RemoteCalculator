//
//  NetworkAvailability.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 4/11/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import Foundation
import UIKit

// Utility for detecting network availability and alerting user, can be used by any controller
class NetworkAvailability {
    static fileprivate let reachability: Reachability? = Reachability()!
    
    static func displayNetworkDisconnectedAlert(currentUIViewController: UIViewController?) {
        let alert = UIAlertController(title: "Network Connection", message: "Your network connection is unavailable. Please make sure that you are connected to a Wi-Fi or Cellular Network.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(dismissAction)
        currentUIViewController?.present(alert, animated: true)
    }
    
    static func setupReachability(controller: UIViewController?, selector: Selector) {
        NotificationCenter.default.addObserver(controller as Any, selector: selector, name: .reachabilityChanged, object: NetworkAvailability.reachability)
        do{
            try NetworkAvailability.reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    static func removeReachability(controller: UIViewController?, selector: Selector) {
        NotificationCenter.default.removeObserver(controller as Any, name: .reachabilityChanged, object: NetworkAvailability.reachability)
    }
    
    static func networkAvailable() -> Bool {
        let available = NetworkAvailability.reachability?.connection
        if(available != Reachability.Connection.none) {
            // When the network is available
            return true
        }
        else {
            // When the network is NOT available
            return false
        }
    }
}
