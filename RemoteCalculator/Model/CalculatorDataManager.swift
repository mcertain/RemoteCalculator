//
//  CalculatorDataManager.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 6/24/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import Foundation
import UIKit

class CalculatorDataManager {
    
    // CalculatorDataManager should be singleton since we only need one instance
    static var singletonInstance:CalculatorDataManager? = nil
    
    private init() { }
    
    static func GetInstance() ->CalculatorDataManager? {
        if(CalculatorDataManager.singletonInstance == nil) {
            CalculatorDataManager.singletonInstance = CalculatorDataManager()
        }
        return CalculatorDataManager.singletonInstance
    }
    
    func requestCalculatorSessionID(withUIViewController: UIViewController,
                                    updateDisplayHandler: ((_ receivedData: AnyObject?) -> Void)?) {
        
        let successHandler = { (receivedData: Data?, withArgument: AnyObject?) -> Void in
            var receivedResult: CalculationIdentifier?
            guard receivedData != nil else {
                self.displayErrorAlert(currentUIViewController: withUIViewController)
                return
            }
            
            do {
                receivedResult = try JSONDecoder().decode(CalculationIdentifier.self, from: receivedData!)
            }
            catch {
                return
            }
            
            updateDisplayHandler?(receivedResult as AnyObject?)
        }
        
        let errorHandler = { () -> Void in
            self.displayURLRequestErrorAlert(currentUIViewController: withUIViewController)
        }
        
        EndpointRequestor.postEndpointData(endpointDescriptor: CalculatorEndpointDescriptor(endpoint: .REQUEST_ID),
                                           withUIViewController: withUIViewController,
                                           errorHandler: errorHandler,
                                           successHandler: successHandler,
                                           busyTheView: true)
    }
    
    func postCalculatorNumberToken(numberData: NumberPost,
                                   withUIViewController: UIViewController,
                                   updateDisplayHandler: ((_ receivedData: AnyObject?) -> Void)?) {
        
        let successHandler = { (receivedData: Data?, withArgument: AnyObject?) -> Void in
            var receivedResult: NumberPost?
            guard receivedData != nil else {
                self.displayErrorAlert(currentUIViewController: withUIViewController)
                return
            }
            
            do {
                receivedResult = try JSONDecoder().decode(NumberPost.self, from: receivedData!)
            }
            catch {
                return
            }
            
            updateDisplayHandler?(receivedResult as AnyObject?)
        }
        
        let errorHandler = { () -> Void in
            self.displayURLRequestErrorAlert(currentUIViewController: withUIViewController)
        }
        
        EndpointRequestor.postEndpointData(endpointDescriptor: CalculatorEndpointDescriptor(endpoint: .POST_NUMBER),
                                              withUIViewController: withUIViewController,
                                              errorHandler: errorHandler,
                                              successHandler: successHandler,
                                              busyTheView: false,
                                              withTargetArgument: numberData as AnyObject)
    }
    
    func postCalculatorOperatorToken(operatorData: OperatorPost,
                                     withUIViewController: UIViewController,
                                     updateDisplayHandler: ((_ receivedData: AnyObject?) -> Void)?) {
        
        let successHandler = { (receivedData: Data?, withArgument: AnyObject?) -> Void in
            var receivedResult: OperatorPost?
            guard receivedData != nil else {
                self.displayErrorAlert(currentUIViewController: withUIViewController)
                return
            }
            
            do {
                receivedResult = try JSONDecoder().decode(OperatorPost.self, from: receivedData!)
            }
            catch {
                return
            }
            
            updateDisplayHandler?(receivedResult as AnyObject?)
        }
        
        let errorHandler = { () -> Void in
            self.displayURLRequestErrorAlert(currentUIViewController: withUIViewController)
        }
        
        EndpointRequestor.postEndpointData(endpointDescriptor: CalculatorEndpointDescriptor(endpoint: .POST_OPERATOR),
                                           withUIViewController: withUIViewController,
                                           errorHandler: errorHandler,
                                           successHandler: successHandler,
                                           busyTheView: false,
                                           withTargetArgument: operatorData as AnyObject)
    }
    
    func requestCalculatorResults(withUIViewController: UIViewController,
                                  updateDisplayHandler: ((_ receivedData: AnyObject?) -> Void)?) {
        
        let successHandler = { (receivedData: Data?, withArgument: AnyObject?) -> Void in
            var receivedResult: Results?
            guard receivedData != nil else {
                self.displayErrorAlert(currentUIViewController: withUIViewController)
                return
            }
            
            do {
                receivedResult = try JSONDecoder().decode(Results.self, from: receivedData!)
            }
            catch {
                return
            }
            
            updateDisplayHandler?(receivedResult as AnyObject?)
        }
        
        let errorHandler = { () -> Void in
            self.displayURLRequestErrorAlert(currentUIViewController: withUIViewController)
        }
        
        EndpointRequestor.requestEndpointData(endpointDescriptor: CalculatorEndpointDescriptor(endpoint: .REQUEST_RESULT),
                                           withUIViewController: withUIViewController,
                                           errorHandler: errorHandler,
                                           successHandler: successHandler,
                                           busyTheView: false)
    }
    
    func displayErrorAlert(currentUIViewController: UIViewController?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Response from the server was not in the expected format.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(dismissAction)
            currentUIViewController?.present(alert, animated: true)
        }
    }
    
    func displayURLRequestErrorAlert(currentUIViewController: UIViewController?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "The response from the server returned with an error. The server might be unreachable or your network might be disconnected.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(dismissAction)
            currentUIViewController?.present(alert, animated: true)
        }
    }
}
