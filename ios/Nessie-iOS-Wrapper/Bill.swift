//
//  Bill.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum BillStatus : String {
    case Pending = "pending"
    case Recurring = "recurring"
    case Cancelled = "cancelled"
    case Completed = "completed"
    case Unknown
}

public class Bill: JsonParser {
    
    public let billId: String
    public let status: BillStatus
    public var payee: String
    public var nickname: String? = nil
    public var creationDate: NSDate?
    public var paymentDate: NSDate? = nil
    public var recurringDate: Int?
    public var upcomingPaymentDate: NSDate? = nil
    public let paymentAmount: Int
    public var accountId: String
    
    public init (status: BillStatus, payee: String, nickname: String?, creationDate: NSDate?, paymentDate: NSDate?, recurringDate: Int?, upcomingPaymentDate: NSDate?, paymentAmount: Int, accountId: String) {
        self.billId = ""
        self.status = status
        self.payee = payee
        self.nickname = nickname
        self.creationDate = creationDate
        self.paymentDate = paymentDate
        self.recurringDate = recurringDate
        self.upcomingPaymentDate = upcomingPaymentDate
        self.paymentAmount = paymentAmount
        self.accountId = accountId
    }
    
    public required init (data: JSON) {
        self.billId = data["_id"].string ?? ""
        self.status = BillStatus(rawValue: data["status"].string ?? "") ?? .Unknown
        self.payee = data["_payee"].string ?? ""
        self.nickname = data["nickname"].string ?? ""
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"

        self.creationDate = dateFormatter.dateFromString(data["creation_date"].string ?? "")
        self.paymentDate = dateFormatter.dateFromString(data["payment_date"].string ?? "")
        self.recurringDate = data["recurring_date"].int ?? 0
        self.upcomingPaymentDate = dateFormatter.dateFromString(data["upcoming_payment_date"].string ?? "")
        self.paymentAmount = data["payment_amount"].int ?? 0
        self.accountId = data["account_id"].string ?? ""
    }
}

public class BillRequest {
    private var requestType: HTTPType!
    private var billId: String?
    private var accountId: String?
    private var accountType: AccountType?
    private var customerId: String?

    public init () {}
    
    private func buildRequestUrl() -> String {

        var requestString = "\(baseString)"
        if (self.accountId != nil) {
            requestString += "/accounts/\(self.accountId!)/bills"
        }

        if (self.billId != nil) {
            requestString += "/bills/\(self.billId!)"
        }
        
        if (self.customerId != nil) {
            requestString = "\(baseString)/customers/\(self.customerId!)/bills"
        }
        
        if (self.requestType == HTTPType.POST) {
            requestString = "\(baseString)/accounts/\(self.accountId!)/bills"
        }
        
        if (self.requestType == HTTPType.GET && self.accountId == nil && self.accountType != nil) {
            var typeParam = self.accountType!.rawValue
            typeParam = typeParam.stringByReplacingOccurrencesOfString(" ", withString: "%20")
            requestString += "?type=\(typeParam)&key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        
        return requestString
    }
    
    // APIs
    public func getAccountBills(accountId: String, completion: (billsArrays: Array<Bill>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(billsArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Bill>(data: json)
                completion(billsArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func getBill(billId: String, completion: (bill:Bill?, error: NSError?) -> Void) {
        self.requestType = HTTPType.GET
        self.billId = billId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(bill: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Bill>(data: json)
                completion(bill: response.object, error: nil)
            }
        })
    }
    
    public func getCustomerBills(customerId: String, completion: (billsArrays: Array<Bill>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.GET
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(billsArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Bill>(data: json)
                completion(billsArrays: response.requestArray, error: nil)
            }
        })
    }
    
    public func postBill(newBill: Bill, completion: (billResponse: BaseResponse<Bill>?, error: NSError?) -> Void) {
        
        self.requestType = HTTPType.POST
        self.accountId = newBill.accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        
        var params: Dictionary<String, AnyObject> = ["status": newBill.status.rawValue, "payee": newBill.payee, "payment_amount": newBill.paymentAmount]

        if let nickname = newBill.nickname as String? {
            params["nickname"] = nickname
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        
        if let paymentDate = newBill.paymentDate as NSDate? {
            let dateString = dateFormatter.stringFromDate(paymentDate)
            params["payment_date"] = dateString
        }
        
        if let recurringDate = newBill.recurringDate as Int? {
            params["recurring_date"] = recurringDate
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(billResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(billResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Bill>(data: json)
                completion(billResponse: response, error: nil)
            }
        })
    }
    
    public func putBill(updatedBill: Bill, completion: (billResponse: BaseResponse<Bill>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.PUT
        self.billId = updatedBill.billId

        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        
        var params: Dictionary<String, AnyObject> = ["status": updatedBill.status.rawValue, "payee": updatedBill.payee, "payment_amount": updatedBill.paymentAmount]
        
        if let nickname = updatedBill.nickname as String? {
            params["nickname"] = nickname
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM"
        
        if let paymentDate = updatedBill.paymentDate as NSDate? {
            let dateString = dateFormatter.stringFromDate(paymentDate)
            params["payment_date"] = dateString
        }
        
        if let recurringDate = updatedBill.recurringDate as Int? {
            params["recurring_date"] = recurringDate
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(billResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(billResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Bill>(data: json)
                completion(billResponse: response, error: nil)
            }
        })
    }
    
    public func deleteBill(billId: String, completion: (billResponse: BaseResponse<Bill>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.DELETE
        self.billId = billId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType!)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(billResponse: nil, error: error)
            } else {
                let response = BaseResponse<Bill>(requestArray: nil, object: nil, message: "Bill deleted")
                completion(billResponse: response, error: nil)
            }
        })
    }
}
