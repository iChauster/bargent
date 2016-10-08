//
//  Merchant.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. (CONT) on 9/1/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Merchant: JsonParser {
    
    public let merchantId: String
    public var name: String
    public var category: Array<String>
    public var address: Address
    public var geocode: Geocode
    
    public init(merchantId: String, name: String, category: Array<String>, address: Address, geocode: Geocode) {
        self.merchantId = merchantId
        self.name = name
        self.category = category
        self.address = address
        self.geocode = geocode
    }
    
    public required init(data: JSON) {
        self.merchantId = data["_id"].string ?? ""
        self.name = data["name"].string ?? ""
        self.category = data["category"].arrayValue.map({$0.string ?? ""})
        self.address = Address(data: data["address"])
        self.geocode = Geocode(data: data["geocode"])
    }
}

public class MerchantRequest {
    private var requestType: HTTPType!
    private var merchantId: String?
    private var rad: String?
    private var geocode: Geocode?
    
    public init () {}
    
    private func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/merchants"
        if let merchantId = merchantId {
            requestString += "/\(merchantId)"
        }
        if let geocode = geocode, let rad = rad {
            requestString += "?lat=\(geocode.lat)&lng=\(geocode.lng)&rad=\(rad)&key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    public func getMerchants(geocode: Geocode? = nil, rad: String? = nil, completion:(merchantsArrays: Array<Merchant>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.geocode = geocode
        self.rad = rad
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(merchantsArrays: nil, error: error)
            } else {
                guard let data = data else {
                    completion(merchantsArrays: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Merchant>(data: json)
                completion(merchantsArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func getMerchant(merchantId: String, completion: (merchant: Merchant?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.merchantId = merchantId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(merchant: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Merchant>(data: json)
                completion(merchant: response.object, error: nil)
            }
        })
    }
    
    public func postMerchant(newMerchant: Merchant, completion: (merchantResponse: BaseResponse<Merchant>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.POST
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        let address = ["street_number": newMerchant.address.streetNumber,
                       "street_name": newMerchant.address.streetName,
                       "city": newMerchant.address.city,
                       "state": newMerchant.address.state,
                       "zip": newMerchant.address.zipCode]
        let geocode = ["lng": newMerchant.geocode.lng,
                       "lat": newMerchant.geocode.lat]
        
        let params: Dictionary<String, AnyObject> = ["name": newMerchant.name,
                                                     "category": newMerchant.category,
                                                     "geocode": geocode,
                                                     "address": address]
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(merchantResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(merchantResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Merchant>(data: json)
                completion(merchantResponse: response, error: nil)
            }
        })
    }
    
    public func putMerchant(updatedMerchant: Merchant, completion: (merchantResponse: BaseResponse<Merchant>?, error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        merchantId = updatedMerchant.merchantId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        let address = ["street_number": updatedMerchant.address.streetNumber,
                       "street_name": updatedMerchant.address.streetName,
                       "city": updatedMerchant.address.city,
                       "state": updatedMerchant.address.state,
                       "zip": updatedMerchant.address.zipCode]
        let geocode = ["lng": updatedMerchant.geocode.lng,
                       "lat": updatedMerchant.geocode.lat]
        
        let params: Dictionary<String, AnyObject> = ["name": updatedMerchant.name,
                                                     "category": updatedMerchant.category,
                                                     "geocode": geocode,
                                                     "address": address]
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(merchantResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(merchantResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Merchant>(data: json)
                completion(merchantResponse: response, error: nil)
            }
        })
    }
}
