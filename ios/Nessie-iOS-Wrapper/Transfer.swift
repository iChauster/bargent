//
//  Transfer.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum TransferType: String {
    case P2P = "p2p"
    case Deposit = "deposit"
    case Withdrawal = "withdrawal"
    case Unknown
}

public enum TransferStatus: String {
    case Pending = "pending"
    case Cancelled = "cancelled"
    case Completed = "completed"
    case Unknown
}

public class Transfer: JsonParser {
    public var transferId: String
    public var type: TransferType
    public var transactionDate: NSDate?
    public var status: TransferStatus
    public var medium: TransactionMedium
    public var payerId: String
    public var payeeId: String
    public var amount: Double
    public var description: String?
    
    public init(transferId: String, type: TransferType, transactionDate: NSDate?, status: TransferStatus, medium: TransactionMedium, payerId: String, payeeId: String, amount: Double, description: String?) {
        self.transferId = transferId
        self.type = type
        self.transactionDate = transactionDate
        self.status = status
        self.medium = medium
        self.payerId = payerId
        self.payeeId = payeeId
        self.amount = amount
        self.description = description
    }
    
    public required init(data: JSON) {
        self.transferId = data["_id"].string ?? ""
        self.type = TransferType(rawValue: data["type"].string ?? "") ?? .Unknown
        self.status = TransferStatus(rawValue: data["status"].string ?? "") ?? .Unknown
        self.transactionDate = data["transaction_date"].string?.stringToDate()
        self.medium = TransactionMedium(rawValue: data["medium"].string ?? "") ?? .Unknown
        self.payerId = data["payer_id"].string ?? ""
        self.payeeId = data["payee_id"].string ?? ""
        self.amount = data["amount"].double ?? 0
        self.description = data["description"].string ?? ""
    }
    
}

public class TransferRequest {
    private var requestType: HTTPType!
    private var accountId: String?
    private var transferId: String?
    
    public init () {
        // not implemented
    }
    
    private func buildRequestUrl() -> String {
        // base URL
        var requestString = "\(baseString)/transfers/"
        
        // if a call uses accountId
        if let accountId = accountId {
            requestString = "\(baseString)/accounts/\(accountId)/transfers"
        }
        
        // if a call uses transferId
        if let transferId = transferId {
            requestString += "\(transferId)"
        }
        
        // append apiKey
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    private func setUp(reqType: HTTPType, accountId: String?, transferId: String?) {
        self.requestType = reqType
        self.accountId = accountId
        self.transferId = transferId
    }
    
    // MARK: API Requests
    
    // GET /accounts/{id}/transfers
    public func getTransfersFromAccountId(accountId: String, completion: (transferArray: Array<Transfer>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(transferArray: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Transfer>(data: json)
                completion(transferArray: response.requestArray, error: nil)
            }
        })
    }
    
    // GET /transfers/{transferId}
    public func getTransfer(transferId: String, completion: (transfer: Transfer?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.transferId = transferId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(transfer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Transfer>(data: json)
                completion(transfer: response.object, error: nil)
            }
        })
    }
    
    // POST /accounts/{id}/transfers
    public func postTransfer(newTransfer: Transfer, accountId: String, completion: (transferResponse: BaseResponse<Transfer>?, error: NSError?) -> Void) {
        requestType = HTTPType.POST
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        // construct request body
        // required values: medium, payee_id, amount
        var params: Dictionary<String, AnyObject> =
            ["medium": newTransfer.medium.rawValue,
             "payee_id": newTransfer.payeeId,
             "amount": newTransfer.amount]
        
        // optional values
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        if let transactionDate = newTransfer.transactionDate as NSDate? {
            let dateString = dateFormatter.stringFromDate(transactionDate)
            params["transaction_date"] = dateString
        }
        
        if let description = newTransfer.description {
            params["description"] = description
        }
        
        // make request
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(transferResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(transferResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Transfer>(data: json)
                completion(transferResponse: response, error: nil)
            }
        })
    }
    
    // PUT /transfers/{transferId}
    public func putTransfer(updatedTransfer: Transfer, completion: (transferResponse: BaseResponse<Transfer>?, error: NSError?) -> Void) {
        requestType = HTTPType.PUT
        transferId = updatedTransfer.transferId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        
        var params: Dictionary<String, AnyObject> =
            ["medium": updatedTransfer.medium.rawValue,
             "payee_id": updatedTransfer.payeeId,
             "amount": updatedTransfer.amount]
        
        if let description = updatedTransfer.description {
            params["description"] = description
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(transferResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(transferResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Transfer>(data: json)
                completion(transferResponse: response, error: nil)
            }
        })
    }
    
    // DELETE /transfers/{transferId}
    public func deleteTransfer(transferId: String, completion: (transferResponse: BaseResponse<Transfer>?, error: NSError?) -> Void) {
        requestType = HTTPType.DELETE
        self.transferId = transferId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(transferResponse: nil, error: error)
            } else {
                let response = BaseResponse<Transfer>(requestArray: nil, object: nil, message: "Transfer deleted")
                completion(transferResponse: response, error: nil)
            }
        })
    }
    
}
