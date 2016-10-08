//
//  Purchase.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Purchase: JsonParser {
    public var merchantId: String
    public let status: BillStatus
    public var medium: TransactionMedium
    public let payerId: String?
    public var amount: Double
    public let type: String?
    public var purchaseDate: NSDate?
    public var description: String?
    public let purchaseId: String
    
    public init(merchantId: String, status: BillStatus, medium: TransactionMedium, payerId: String?, amount: Double, type: String, purchaseDate: NSDate?, description: String?, purchaseId: String) {
        self.merchantId = merchantId
        self.status = status
        self.medium = medium
        self.payerId = payerId
        self.amount = amount
        self.type = type
        self.purchaseDate = purchaseDate
        self.description = description
        self.purchaseId = purchaseId
    }
    
    public required init(data: JSON) {
        self.merchantId = data["merchant_id"].string ?? ""
        self.status = BillStatus(rawValue: data["status"].string ?? "") ?? .Unknown
        self.medium = TransactionMedium(rawValue: data["medium"].string ?? "") ?? .Unknown
        self.payerId = data["payer_id"].string
        self.amount = data["amount"].double ?? 0.0
        self.type = data["type"].string ?? ""
        let transactionDateString = data["purchase_date"].string
        if let str = transactionDateString {
            if let date = dateFormatter.dateFromString(str) {
                self.purchaseDate = date
            } else {
                self.purchaseDate = NSDate()
            }
        }
        self.description = data["description"].string
        self.purchaseId = data["_id"].string ?? ""
    }
}

public class PurchaseRequest {
    private var requestType: HTTPType!
    private var accountId: String?
    private var purchaseId: String?
    private var merchantId: String?
    
    public init () {}
    
    private func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/purchases/"
        
        if let merchantId = merchantId, let accountId = accountId {
            requestString = "\(baseString)/merchants/\(merchantId)/accounts/\(accountId)/purchases"
        }
        
        if let merchantId = merchantId {
            requestString = "\(baseString)/merchants/\(merchantId)/purchases"
        }

        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/purchases"
        }
        
        if let purchaseId = purchaseId {
            requestString += "\(purchaseId)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    public func getPurchase(purchaseId: String, completion: (purchase: Purchase?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.purchaseId = purchaseId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchase: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Purchase>(data: json)
                completion(purchase: response.object, error: nil)
            }
        })
    }
    
    public func getPurchasesFromMerchantId(merchantId: String, completion: (purchaseArrays: Array<Purchase>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.merchantId = merchantId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchaseArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Purchase>(data: json)
                completion(purchaseArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func getPurchasesFromAccountId(accountId: String, completion: (purchaseArrays: Array<Purchase>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchaseArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Purchase>(data: json)
                completion(purchaseArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func getPurchasesFromMerchantAndAccountIds(merchantId: String, accountId: String, completion: (purchaseArrays: Array<Purchase>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.merchantId = merchantId
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchaseArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Purchase>(data: json)
                completion(purchaseArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func postPurchase(newPurchase: Purchase, accountId: String, completion: (purchaseResponse: BaseResponse<Purchase>?, error: NSError?) -> Void) {
        requestType = HTTPType.POST
        self.accountId = accountId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        var params: Dictionary<String, AnyObject> = ["medium": newPurchase.medium.rawValue,
                                                     "merchant_id": newPurchase.merchantId,
                                                     "amount": newPurchase.amount]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        if let purchaseDate = newPurchase.purchaseDate as NSDate? {
            let dateString = dateFormatter.stringFromDate(purchaseDate)
            params["purchase_date"] = dateString
        }
        
        if let description = newPurchase.description {
            params["description"] = description
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(purchaseResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchaseResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Purchase>(data: json)
                completion(purchaseResponse: response, error: nil)
            }
        })
    }
    
    public func putPurchase(updatedPurchase: Purchase, completion: (purchaseResponse: BaseResponse<Purchase>?, error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        purchaseId = updatedPurchase.purchaseId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        var params: Dictionary<String, AnyObject> = ["medium": updatedPurchase.medium.rawValue,
                                                     "amount": updatedPurchase.amount]
        if let description = updatedPurchase.description {
            params["description"] = description
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(purchaseResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchaseResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Purchase>(data: json)
                completion(purchaseResponse: response, error: nil)
            }
        })
    }
    
    public func deletePurchase(purchaseId: String, completion: (purchaseResponse: BaseResponse<Purchase>?, error: NSError?) -> Void) {
        requestType = HTTPType.DELETE
        self.purchaseId = purchaseId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(purchaseResponse: nil, error: error)
            } else {
                let response = BaseResponse<Purchase>(requestArray: nil, object: nil, message: "Purchase deleted")
                completion(purchaseResponse: response, error: nil)
            }
        })
    }
}
