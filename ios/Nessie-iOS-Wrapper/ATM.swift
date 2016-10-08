//
//  ATM.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

public class ATMRequest {
    private var requestType: HTTPType?
    private var atmId: String?
    private var radius: String?
    private var latitude: Float?
    private var longitude: Float?
    private var nextPage: String?
    private var previousPage: String?
    
    public init () {
        self.requestType = HTTPType.GET
    }
    
    private func buildRequestUrl() -> String {
        if let nextPage = self.nextPage {
            return "\(baseString)\(nextPage)"
        }

        if let previousPage = self.previousPage {
            return "\(baseString)\(previousPage)"
        }
        
        var requestString = "\(baseString)/atms"

        if let atmId = self.atmId {
            requestString += "/\(atmId)?"
        } else {
            requestString += validateLocationSearchParameters()
        }
        
        requestString += "key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func validateLocationSearchParameters() -> String {
        if (self.latitude != nil && self.longitude != nil && self.radius != nil) {
            let locationSearchParameters = "lat=\(self.latitude!)&lng=\(self.longitude!)&rad=\(self.radius!)"
            return "?"+locationSearchParameters+"&"
        }
        else if !(self.latitude == nil && self.longitude == nil && self.radius == nil) {
            NSLog("Latitude, longitude, and radius are optionals. But if one is used, all are required.")
            NSLog("You provided lat:\(self.latitude) long:\(self.longitude) radius:\(self.radius)")
            return ""
        }
        
        return "?"
    }

    private func makeRequest(completion:(response:AtmResponse?, error: NSError?) -> Void) {
        let requestString = buildRequestUrl()
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.buildRequest(self.requestType!, url: requestString)
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(response: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = AtmResponse(data: json)
                completion(response: response, error: nil)
            }
        })
    }
    
    public func getAtms(latitude: Float?, longitude: Float?, radius: String?, completion:(response:AtmResponse?, error: NSError?) -> Void) {

        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius

        self.makeRequest(completion)
    }
    
    public func getNextAtms(nextPage:String, completion:(response:AtmResponse?, error: NSError?) -> Void) {
            
        self.nextPage = nextPage

        self.makeRequest(completion)
    }

    public func getPreviousAtms(previousPage:String, completion:(response:AtmResponse?, error: NSError?) -> Void) {

        self.previousPage = previousPage
        
        self.makeRequest(completion)
    }

}

public class AtmResponse {
    
    public let previousPage: String
    public let nextPage: String
    public let requestArray: Array<AnyObject>
    
    internal init(data:JSON) {
        self.requestArray = data["data"].arrayValue.map({Atm(data: $0)})
        self.previousPage = data["paging"]["previous"].string ?? ""
        self.nextPage = data["paging"]["next"].string ?? ""
    }
}

public class Atm {
    
    public let atmId: String
    public let name: String
    public let languageList: Array<String>
    public let address: Address
    public let geocode: CLLocation
    public let amountLeft: Int
    public let accessibility: Bool
    public let hours: Array<String>
    
    internal init(data: JSON) {
        self.atmId = data["_id"].string ?? ""
        self.name = data["name"].string ?? ""
        self.languageList = data["language_list"].arrayValue.map {$0.string!}
        self.address = Address(data:data["address"])
        self.amountLeft = data["amount_left"].int ?? 0
        self.accessibility = data["accessibility"].bool ?? false
        self.hours = data["hours"].arrayValue.map {$0.string!}
        self.geocode = CLLocation(latitude: data["lat"].double ?? 0, longitude: data["lng"].double ?? 0)
    }

}
