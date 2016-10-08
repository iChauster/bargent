//
//  Customer.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Customer: JsonParser {
    public var firstName: String
    public var lastName: String
    public var address: Address
    public var customerId: String
    
    public init(firstName: String, lastName: String, address: Address, customerId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.customerId = customerId
    }
    
    public required init(data: JSON) {
        self.firstName = data["first_name"].string ?? ""
        self.lastName = data["last_name"].string ?? ""
        self.address = Address(data: data["address"])
        self.customerId = data["_id"].string ?? ""
    }
}

public class CustomerRequest {
    private var requestType: HTTPType!
    private var accountId: String?
    private var customerId: String?
    
    public init () {}
    
    private func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/customers/"
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/customer"
        }
        
        if let customerId = customerId {
            requestString += "\(customerId)"
        }

        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }

    // APIs
    public func getCustomers(completion:(customersArrays: Array<Customer>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customersArrays: nil, error: error)
            } else {
                guard let data = data else {
                    completion(customersArrays: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Customer>(data: json)
                completion(customersArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func getCustomer(customerId: String, completion: (customer: Customer?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Customer>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
    
    public func getCustomerFromAccountId(accountId: String, completion: (customersArrays: Customer?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customersArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Customer>(data: json)
                completion(customersArrays: response.object, error: nil)
            }
        })
    }
    
    public func postCustomer(newCustomer: Customer, completion: (customerResponse: BaseResponse<Customer>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.POST
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        let address = ["street_number": newCustomer.address.streetNumber,
                       "street_name": newCustomer.address.streetName,
                       "city": newCustomer.address.city,
                       "state": newCustomer.address.state,
                       "zip": newCustomer.address.zipCode]

        let params: Dictionary<String, AnyObject> = ["first_name": newCustomer.firstName,
                                                     "last_name": newCustomer.lastName,
                                                     "address": address]
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(customerResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customerResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Customer>(data: json)
                completion(customerResponse: response, error: nil)
            }
        })
    }
    
    public func putCustomer(updatedCustomer: Customer, completion: (customerResponse: BaseResponse<Customer>?, error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        customerId = updatedCustomer.customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        let address = ["street_number": updatedCustomer.address.streetNumber,
                       "street_name": updatedCustomer.address.streetName,
                       "city": updatedCustomer.address.city,
                       "state": updatedCustomer.address.state,
                       "zip": updatedCustomer.address.zipCode]
        
        let params: Dictionary<String, AnyObject> = ["first_name": updatedCustomer.firstName,
                                                     "last_name": updatedCustomer.lastName,
                                                     "address": address]
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(customerResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customerResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Customer>(data: json)
                completion(customerResponse: response, error: nil)
            }
        })
    }
}
