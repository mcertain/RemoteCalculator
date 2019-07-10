//
//  UIViewUtilities.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 4/11/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import Foundation
import UIKit

// Utility help class to display busy view overlay when waiting on network response
class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    var currentUIViewController: UIViewController?
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    static func createSpinnerView(currentUIViewController: UIViewController?) ->UIViewController?  {
        let child = SpinnerViewController()
        DispatchQueue.main.async {
            // Disable Scrolling if the parent view is a table view
            if(currentUIViewController is UITableViewController) {
                (currentUIViewController as! UITableViewController).tableView.isScrollEnabled = false
            }
            
            // Add the spinner to the view controller
            currentUIViewController?.addChild(child)
            child.view.frame = (currentUIViewController?.view.frame)!
            currentUIViewController?.view.addSubview(child.view)
            child.didMove(toParent: currentUIViewController)
        }
        
        return child as UIViewController
    }
    
    static func stopSpinnerView(currentUIViewController: UIViewController?, busyView: UIViewController?)  {
        let child = busyView as! SpinnerViewController
        DispatchQueue.main.async {
            // Re-enable Scrolling if the parent view is a table view
            if(currentUIViewController is UITableViewController) {
                (currentUIViewController as! UITableViewController).tableView.isScrollEnabled = true
            }
            
            // Remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}

extension UIViewController {
    
    // Extensions to busy/unbusy any UIViewController
    func busyTheViewWithIndicator(currentUIViewController: UIViewController?) ->UIViewController? {
        return SpinnerViewController.createSpinnerView(currentUIViewController: currentUIViewController)
    }
    
    func unbusyTheViewWithIndicator(currentUIViewController: UIViewController?, busyView: UIViewController?) {
        SpinnerViewController.stopSpinnerView(currentUIViewController: currentUIViewController, busyView: busyView)
    }
}

extension Int {
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    var commaDelimited: String {
        return Int.numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
