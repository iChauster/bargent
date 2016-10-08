//
//  Deposit.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum TransactionMedium : String {
    case Balance = "balance"
    case Rewards = "rewards"
    case Unknown
}

public enum TransactionType : String {
    case Payee = "payee"
    case Payer = "payer"
    case Unknown
}

public class Deposit: JsonParser {
    public var depositId: String
    public var status: BillStatus
    public var medium: TransactionMedium
    public var payeeId: String?
    public var amount: Int
    public var type: String
    public var transactionDate: NSDate?
    public var description: String?
    
    public init(depositId: String, status: BillStatus, medium: TransactionMedium, payeeId: String?, amount: Int, type: String, transactionDate: NSDate?, description: String?) {
        self.depositId = depositId
        self.status = status
        self.medium = medium
        self.payeeId = payeeId
        self.amount = amount
        self.type = type
        self.transactionDate = transactionDate
        self.description = description
    }
    
    public required init(data: JSON) {
        self.depositId = data["_id"].string ?? ""
        self.status = BillStatus(rawValue: data["status"].string ?? "") ?? .Unknown
        self.medium = TransactionMedium(rawValue: data["medium"].string ?? "") ?? .Unknown
        self.payeeId = data["payee_id"].string ?? ""
        self.amount = data["amount"].int ?? 0
        self.type = data["type"].string ?? ""
        self.transactionDate = data["transaction_date"].string?.stringToDate()
        self.description = data["description"].string ?? ""
        self.depositId = data["_id"].string ?? ""
    }
}

public class DepositRequest {
    private var requestType: HTTPType!
    private var accountId: String?
    private var depositId: String?
    
    public init () {}
    
    private func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/deposits/"
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/deposits"
        }
        
        if let depositId = depositId {
            requestString += "\(depositId)"
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    public func getDeposit(depositId: String, completion: (deposit: Deposit?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.depositId = depositId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(deposit: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Deposit>(data: json)
                completion(deposit: response.object, error: nil)
            }
        })
    }
    
    public func getDepositsFromAccountId(accountId: String, completion: (depositArrays: Array<Deposit>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(depositArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Deposit>(data: json)
                completion(depositArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func postDeposit(newDeposit: Deposit, accountId: String, completion: (depositResponse: BaseResponse<Deposit>?, error: NSError?) -> Void) {
        requestType = HTTPType.POST
        self.accountId = accountId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
                
        var params: Dictionary<String, AnyObject> = ["medium": newDeposit.medium.rawValue,
                                                     "amount": newDeposit.amount]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        if let transactionDate = newDeposit.transactionDate as NSDate? {
            let dateString = dateFormatter.stringFromDate(transactionDate)
            params["transaction_date"] = dateString
        }
        
        if let description = newDeposit.description {
            params["description"] = description
        }

        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(depositResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(depositResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Deposit>(data: json)
                completion(depositResponse: response, error: nil)
            }
        })
    }
    
    public func putDeposit(updatedDeposit: Deposit, completion: (depositResponse: BaseResponse<Deposit>?, error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        depositId = updatedDeposit.depositId
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        var params: Dictionary<String, AnyObject> = ["medium": updatedDeposit.medium.rawValue,
                                                     "amount": updatedDeposit.amount]
        if let description = updatedDeposit.description {
            params["description"] = description
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(depositResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(depositResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Deposit>(data: json)
                completion(depositResponse: response, error: nil)
            }
        })
    }
    
    public func deleteDeposit(depositId: String, completion: (depositResponse: BaseResponse<Deposit>?, error: NSError?) -> Void) {
        requestType = HTTPType.DELETE
        self.depositId = depositId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(depositResponse: nil, error: error)
            } else {
                let response = BaseResponse<Deposit>(requestArray: nil, object: nil, message: "Deposit deleted")
                completion(depositResponse: response, error: nil)
            }
        })
    }
}
