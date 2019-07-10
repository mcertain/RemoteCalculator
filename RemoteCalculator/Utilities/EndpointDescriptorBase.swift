//
//  EndpointDescriptorBase.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 6/21/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import Foundation

protocol EndpointDescriptorBase {
    func getTargetURL(withArgument: AnyObject?) -> URL
    func getEncodedJSONData(withArgument: AnyObject?) -> Data?
}
