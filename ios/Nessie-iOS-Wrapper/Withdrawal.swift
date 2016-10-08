//
//  Withdrawal.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Withdrawal: JsonParser {
    public var withdrawalId: String
    public var type: TransferType
    public var transactionDate: NSDate?
    public var status: TransferStatus
    public var payerId: String
    public var medium: TransactionMedium
    public var amount: Double
    public var description: String?
    
    public init(withdrawalId: String, type: TransferType, transactionDate: NSDate?, status: TransferStatus, medium: TransactionMedium, payerId: String, amount: Double, description: String?) {
        self.withdrawalId = withdrawalId
        self.type = type
        self.transactionDate = transactionDate
        self.status = status
        self.medium = medium
        self.payerId = payerId
        self.amount = amount
        self.description = description
    }
    
    public required init(data: JSON) {
        self.withdrawalId = data["_id"].string ?? ""
        self.type = TransferType(rawValue: data["type"].string ?? "") ?? .Unknown
        self.status = TransferStatus(rawValue: data["status"].string ?? "") ?? .Unknown
        self.transactionDate = data["transaction_date"].string?.stringToDate()
        self.medium = TransactionMedium(rawValue: data["medium"].string ?? "") ?? .Unknown
        self.payerId = data["payer_id"].string ?? ""
        self.amount = data["amount"].double ?? 0
        self.description = data["description"].string ?? ""
    }
    
}

public class WithdrawalRequest {
    private var requestType: HTTPType!
    private var accountId: String?
    private var withdrawalId: String?
    
    public init() {
        // not implemented
    }
    
    private func buildRequestUrl() -> String {
        // base URL
        var requestString = "\(baseString)/withdrawals/"
        
        // if a call uses accountId
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/withdrawals"
        }
        
        // if a call uses transferId
        if let withdrawalId = withdrawalId {
            requestString += "\(withdrawalId)"
        }
        
        // append apiKey
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    
    // MARK: API Requests
    
    // GET /accounts/{id}/withdrawals
    public func getWithdrawalsFromAccountId(accountId: String, completion: (withdrawalArray: Array<Withdrawal>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(withdrawalArray: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(withdrawalArray: response.requestArray, error: nil)
            }
        })
    }
    
    // GET /withdrawals/{id}
    public func getWithdrawal(withdrawalId: String, completion: (withdrawal: Withdrawal?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.withdrawalId = withdrawalId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(withdrawal: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(withdrawal: response.object, error: nil)
            }
        })
    }
    
    // POST /accounts/{id}/withdrawals
    public func postWithdrawal(newWithdrawal: Withdrawal, accountId: String, completion: (withdrawalResponse: BaseResponse<Withdrawal>?, error: NSError?) -> Void) {
        requestType = HTTPType.POST
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        // construct request body
        // required values: medium, amount
        var params: Dictionary<String, AnyObject> =
            ["medium": newWithdrawal.medium.rawValue,
             "amount": newWithdrawal.amount]
        
        // optional values
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        if let transactionDate = newWithdrawal.transactionDate as NSDate? {
            let dateString = dateFormatter.stringFromDate(transactionDate)
            params["transaction_date"] = dateString
        }
        
        if let description = newWithdrawal.description {
            params["description"] = description
        }
        
        // make request
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(withdrawalResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(withdrawalResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(withdrawalResponse: response, error: nil)
            }
        })
    }
    
    // PUT /withdrawals/{id}
    public func putWithdrawal(updatedWithdrawal: Withdrawal, completion: (withdrawalResponse: BaseResponse<Withdrawal>?, error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        withdrawalId = updatedWithdrawal.withdrawalId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        var params: Dictionary<String, AnyObject> =
            ["medium": updatedWithdrawal.medium.rawValue,
             "amount": updatedWithdrawal.amount]
        
        if let description = updatedWithdrawal.description {
            params["description"] = description
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(withdrawalResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(withdrawalResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(withdrawalResponse: response, error: nil)
            }
        })
    }
    
    // DELETE /withdrawals/{id}
    public func deleteWithdrawal(withdrawalId: String, completion: (withdrawalResponse: BaseResponse<Withdrawal>?, error: NSError?) -> Void) {
        requestType = HTTPType.DELETE
        self.withdrawalId = withdrawalId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(withdrawalResponse: nil, error: error)
            } else {
                let response = BaseResponse<Withdrawal>(requestArray: nil, object: nil, message: "Withdrawal deleted")
                completion(withdrawalResponse: response, error: nil)
            }
        })
    }
}
