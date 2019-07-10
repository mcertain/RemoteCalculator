//
//  RemoteCalculatorController.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 6/24/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import UIKit

class RemoteCalculatorController: UIViewController {

    let m_pCalcDataMgr = CalculatorDataManager.GetInstance()
    
    @IBOutlet var currentValueTextField: UITextField!
    @IBOutlet var currentOperatorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the calculator view initially
        disableCalculator()
        
        // Register network change events
        NetworkAvailability.setupReachability(controller: self, selector: #selector(self.reachabilityChanged(note:)) )
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        if(reachability.connection != .none) {
            // Once the network is confirmed to be available, then set up the session
            setupSession()
            
            // And enable the calculator view
            enableCalculator()
        }
        else {
            // When the network is disconnected, then show an alert to the user
            NetworkAvailability.displayNetworkDisconnectedAlert(currentUIViewController: self)
            
            // And disable the calculator
            disableCalculator()
        }
    }
    
    func setupSession() {
        let updateDisplayHandler = { (receivedResult: AnyObject?) -> Void in
            let result = receivedResult as! CalculationIdentifier?
            guard result?.id != nil else {
                self.displaySessionIDFailureAlert()
                return
            }
            CALCULATION_ID_VALUE = (result?.id)!
            
            // Display a popup with an error message
            guard result?.error == nil else {
                self.displayReceivedAlert(errorMessage: (result?.error)!)
                return
            }
        }
        m_pCalcDataMgr?.requestCalculatorSessionID(withUIViewController: self,
                                                   updateDisplayHandler: updateDisplayHandler)
    }

    @IBAction func pressedNumberButtonAction(_ sender: Any) {
        let updateDisplayHandler = { (receivedResult: AnyObject?) -> Void in
            let result = receivedResult as! NumberPost?
            // Display a popup with an error message
            guard result?.error == nil else {
                self.displayReceivedAlert(errorMessage: (result?.error)!)
                return
            }
            
            guard result?.value != nil else {
                return
            }
            
            DispatchQueue.main.async {
                // Otherwise, show the calculated results
                self.currentValueTextField.text = result?.value?.commaDelimited
            }
        }
        
        m_pCalcDataMgr?.postCalculatorNumberToken(numberData: NumberPost(value: (sender as! UIButton).tag, error: nil),
                                                  withUIViewController: self,
                                                  updateDisplayHandler: updateDisplayHandler)
    }
    
    @IBAction func pressedOperatorButtonAction(_ sender: Any) {
        let opTypeString: String = ((sender as! UIButton).tag == 0) ? "+" : "-"

        let updateDisplayHandler = { (receivedResult: AnyObject?) -> Void in
            let result = receivedResult as! OperatorPost?
            // Display a popup with an error message
            guard result?.error == nil else {
                self.displayReceivedAlert(errorMessage: (result?.error)!)
                return
            }
            
            guard result?.value != nil else {
                return
            }
            
            DispatchQueue.main.async {
                // Otherwise, show the calculated results
                self.currentOperatorTextField.text = result?.value
            }
        }
        
        m_pCalcDataMgr?.postCalculatorOperatorToken(operatorData: OperatorPost(value: opTypeString, error: nil),
                                                    withUIViewController: self,
                                                    updateDisplayHandler: updateDisplayHandler)
    }
    
    @IBAction func pressedResultsButtonAction(_ sender: Any) {
        
        let updateDisplayHandler = { (receivedResult: AnyObject?) -> Void in
            let result = receivedResult as! Results?
            // Display a popup with an error message
            guard result?.error == nil else {
                self.displayReceivedAlert(errorMessage: (result?.error)!)
                return
            }
            
            guard result?.result != nil else {
                return
            }
            
            DispatchQueue.main.async {
                // Otherwise, show the calculated results
                self.currentValueTextField.text = result?.result?.commaDelimited
                self.currentOperatorTextField.text = "="
            }
        }
        
        m_pCalcDataMgr?.requestCalculatorResults(withUIViewController: self,
                                                 updateDisplayHandler: updateDisplayHandler)
    }
    
    func disableCalculator() {
        self.view.isHidden = true
    }
    
    func enableCalculator() {
        self.view.isHidden = false
    }
    
    func displaySessionIDFailureAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Session ID", message: "Failed to retrieve a valid session ID.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
    }
    
    func displayReceivedAlert(errorMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true)
        }
    }
}

