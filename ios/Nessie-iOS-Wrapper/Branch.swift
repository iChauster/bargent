//
//  Branch.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Branch: JsonParser {
    public let branchId: String
    public let name: String
    public let phoneNumber: String
    public let hours: Array<String>
    public let notes: Array<String>
    public let address: Address
    public let geocode: Geocode
    
    public required init(data: JSON) {
        self.branchId = data["_id"].string ?? ""
        self.name = data["name"].string ?? ""
        self.phoneNumber = data["phone_number"].string ?? ""
        self.hours = data["hours"].arrayValue.map({$0.string ?? ""})
        self.notes = data["notes"].arrayValue.map({$0.string ?? ""})
        self.address = Address(data: data["address"])
        self.geocode = Geocode(data: data["geocode"])
    }
}

public class BranchRequest {
    private var requestType: HTTPType = .GET
    private var branchId: String?

    public init () {}

    private func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/branches"
        if (branchId != nil) {
            requestString += "/\(branchId!)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString
    }
    
    // APIs
    public func getBranches(completion:(branchesArray: Array<Branch>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(branchesArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(branchesArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Branch>(data: json)
                completion(branchesArray: response.requestArray, error: nil)
            }
        })
    }
    
    public func getBranch(branchId: String, completion: (branch: Branch?, error: NSError?) -> Void) {
        self.branchId = branchId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(branch: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Branch>(data: json)
                completion(branch: response.object, error: nil)
            }
        })
    }
}
