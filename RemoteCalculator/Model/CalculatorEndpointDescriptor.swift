//
//  CalculatorEndpointDescriptor.swift
//  RemoteCalculator
//
//  Created by Matthew Certain on 6/24/19.
//  Copyright © 2019 M. Certain. All rights reserved.
//

import Foundation

let BASE_URL_PREFIX:String = "https://calculator-frontend-challenge.herokuapp.com"
let REQUEST_ID_SUFFIX:String = "/calculations"
var CALCULATION_ID_VALUE:String = ""
let POST_TOKEN_SUFFIX:String = "/calculations/" + CALCULATION_ID_VALUE + "/tokens"
let GET_RESULT_SUFFIX:String = "/calculations/" + CALCULATION_ID_VALUE + "/result"

enum CalculatorDataEndpoint: Int {
    case REQUEST_ID
    case POST_NUMBER
    case POST_OPERATOR
    case REQUEST_RESULT
}

struct CalculationIdentifier : Decodable {
    let id: String?
    let error: String?
}

struct NumberPost : Decodable, Encodable {
    let type: String? = "number"
    let value: Int?
    let error: String?
}

struct OperatorPost : Decodable, Encodable {
    let type: String? = "operator"
    let value: String?
    let error: String?
}

struct Results : Decodable {
    let result: Int?
    let error: String?
}

class CalculatorEndpointDescriptor : EndpointDescriptorBase {
    
    let endpointType: CalculatorDataEndpoint
    
    init(endpoint: CalculatorDataEndpoint) {
        endpointType = endpoint
    }
    
    func getTargetURL(withArgument: AnyObject?) -> URL {
        var remoteLocation: URL
        switch endpointType {
        case .REQUEST_ID:
            remoteLocation = URL(string: BASE_URL_PREFIX + REQUEST_ID_SUFFIX)!
        case .POST_NUMBER:
            remoteLocation = URL(string: BASE_URL_PREFIX + POST_TOKEN_SUFFIX)!
        case .POST_OPERATOR:
            remoteLocation = URL(string: BASE_URL_PREFIX + POST_TOKEN_SUFFIX)!
        case .REQUEST_RESULT:
            remoteLocation = URL(string: BASE_URL_PREFIX + GET_RESULT_SUFFIX)!
        }
        
        return remoteLocation
    }
    
    func getEncodedJSONData(withArgument: AnyObject?) -> Data? {
        var encodedJSONData: Data
        switch endpointType {
        case .REQUEST_ID:
            return nil
        case .POST_NUMBER:
            let numberData = withArgument as! NumberPost
            encodedJSONData = try! JSONEncoder().encode(numberData)
        case .POST_OPERATOR:
            let operatorData = withArgument as! OperatorPost
            encodedJSONData = try! JSONEncoder().encode(operatorData)
        case .REQUEST_RESULT:
            return nil
        }
        
        return encodedJSONData
    }
}
