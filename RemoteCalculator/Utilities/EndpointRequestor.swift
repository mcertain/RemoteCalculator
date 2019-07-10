//
//  EndpointRequestor.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 6/13/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import Foundation
import UIKit

class EndpointRequestor {
    /// We store all ongoing tasks here to avoid duplicating tasks.
    static var tasks = [URLSessionTask]()
    
    static func postEndpointData(endpointDescriptor: EndpointDescriptorBase,
                                 withUIViewController: UIViewController,
                                 errorHandler: (() -> Void)?,
                                 successHandler: ((_ receivedData: Data?, _ withArgument: AnyObject?) -> Void)?,
                                 busyTheView: Bool,
                                 withTargetArgument: AnyObject?=nil) {
        EndpointRequestor.queryEndpointData(endpointDescriptor: endpointDescriptor,
                                            withUIViewController: withUIViewController,
                                            errorHandler: errorHandler,
                                            successHandler: successHandler,
                                            busyTheView: busyTheView,
                                            withTargetArgument: withTargetArgument,
                                            httpMethod: "POST")
    }
    
    static func requestEndpointData(endpointDescriptor: EndpointDescriptorBase,
                                    withUIViewController: UIViewController,
                                    errorHandler: (() -> Void)?,
                                    successHandler: ((_ receivedData: Data?, _ withArgument: AnyObject?) -> Void)?,
                                    busyTheView: Bool,
                                    withTargetArgument: AnyObject?=nil) {
        
        EndpointRequestor.queryEndpointData(endpointDescriptor: endpointDescriptor,
                                            withUIViewController: withUIViewController,
                                            errorHandler: errorHandler,
                                            successHandler: successHandler,
                                            busyTheView: busyTheView,
                                            withTargetArgument: withTargetArgument)
    }
    
    static func queryEndpointData(endpointDescriptor: EndpointDescriptorBase,
                                  withUIViewController: UIViewController,
                                  errorHandler: (() -> Void)?,
                                  successHandler: ((_ receivedData: Data?, _ withArgument: AnyObject?) -> Void)?,
                                  busyTheView: Bool,
                                  withTargetArgument: AnyObject?=nil,
                                  httpMethod:String?="GET") {
        
        // Use the provide endpoint descriptor to get the target URL using the supplied target arguments
        let remoteLocation: URL = endpointDescriptor.getTargetURL(withArgument: withTargetArgument)
        
        // Don't attempt to fetch the same resource twice while one fetch request is pending
        guard tasks.firstIndex(where: { $0.originalRequest?.url == remoteLocation }) == nil else {
            print("Attempted to fetch the same resource more than once before the previous fetch had completed.")
            return
        }
        
        // Just incase it takes a while to get a response, busy the view so the user knows something
        // is happening
        var busyViewOverlay: UIViewController?
        if(busyTheView == true) {
            busyViewOverlay = withUIViewController.busyTheViewWithIndicator(currentUIViewController: withUIViewController)
        }
        
        let responseHandler: (Data?, URLResponse?, Error?) -> Void =
        {(data, response, error) in
            // Find and remove task reference once the content processing is done
            guard let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url == remoteLocation }) else {
                print("Task for URL was not found.")
                return
            }
            
            // Once the response comes back, then the view can be unbusied and updated
            if(busyTheView == true) {
                withUIViewController.unbusyTheViewWithIndicator(currentUIViewController: withUIViewController, busyView: busyViewOverlay)
            }
            
            // For issues, dispatch the default view indicating the information is unavailable
            guard error == nil else {
                print("URL Request returned with error.")
                errorHandler?()
                tasks.remove(at: taskIndex)
                return
            }
            guard let content = data else {
                print("There was no data at the requested URL.")
                errorHandler?()
                tasks.remove(at: taskIndex)
                return
            }
            
            successHandler?(content, withTargetArgument)
            tasks.remove(at: taskIndex)
        }
        var task: URLSessionDataTask
        if(httpMethod == "POST") {
            var remotePostRequest = URLRequest(url: remoteLocation)
            remotePostRequest.httpMethod = httpMethod
            if(withTargetArgument != nil) {
                remotePostRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                remotePostRequest.httpBody = endpointDescriptor.getEncodedJSONData(withArgument: withTargetArgument)
            }
            task = URLSession.shared.dataTask(with: remotePostRequest, completionHandler: responseHandler)
        }
        else {
            task = URLSession.shared.dataTask(with: remoteLocation, completionHandler: responseHandler)
        }
        task.resume()
        tasks.append(task)
    }
}
