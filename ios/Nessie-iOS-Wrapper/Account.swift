//
//  Account.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum AccountType: String {
    case CreditCard = "Credit Card"
    case Savings
    case Checking
    case Unknown = ""
}

public class Account: JsonParser {
    
    public var accountId: String
    public var accountType: AccountType
    public var nickname: String
    public var rewards: Int
    public var balance: Int
    public var accountNumber: String?
    public var customerId: String
    
    public init(accountId: String, accountType: AccountType, nickname: String, rewards: Int, balance: Int, accountNumber: String?, customerId: String) {
        self.accountId = accountId
        self.accountType = accountType
        self.nickname = nickname
        self.rewards = rewards
        self.balance = balance
        self.accountNumber = accountNumber
        self.customerId = customerId
    }
    
    public required init(data: JSON) {
        self.accountId = data["_id"].string ?? ""
        self.accountType = AccountType(rawValue: data["type"].string ?? "")!
        self.nickname = data["nickname"].string ?? ""
        self.rewards = data["rewards"].int ?? 0
        self.balance = data["balance"].int ?? 0
        self.accountNumber = data["account_number"].string ?? nil
        self.customerId = data["customer_id"].string ?? ""
    }
}

public class AccountRequest {
    private var requestType: HTTPType!
    private var accountId: String?
    private var accountType: AccountType?
    private var customerId: String?
    
    public init () {}

    private func buildRequestUrl() -> String {
        
        var requestString = "\(baseString)/accounts"
        if let accountId = accountId {
            requestString += "/\(accountId)"
        }
        
        if let customerId = customerId {
            requestString = "\(baseString)/customers/\(customerId)/accounts"
        }
        
        if (self.requestType == HTTPType.POST) {
            requestString = "\(baseString)/customers/\(self.customerId!)/accounts"
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
    public func getAccounts(accountType: AccountType?, completion:(accountsArrays: Array<Account>?, error: NSError?) -> Void) {
        requestType = HTTPType.GET
        self.accountType = accountType

        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(accountsArrays: nil, error: error)
            } else {
                guard let data = data else {
                    completion(accountsArrays: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Account>(data: json)
                completion(accountsArrays: response.requestArray, error: nil)
            }
        })
    }

    public func getAccount(accountId: String, completion: (account:Account?, error: NSError?) -> Void) {
        self.requestType = HTTPType.GET
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(account: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Account>(data: json)
                completion(account: response.object, error: nil)
            }
        })
    }

    public func getCustomerAccounts(customerId: String, completion: (accountsArrays: Array<Account>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.GET
        self.customerId = customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(accountsArrays: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Account>(data: json)
                completion(accountsArrays: response.requestArray, error: nil)
            }
        })
    }

    public func postAccount(newAccount: Account, completion: (accountResponse: BaseResponse<Account>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.POST
        self.customerId = newAccount.customerId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        var params: Dictionary<String, AnyObject> = ["nickname": newAccount.nickname, "type":newAccount.accountType.rawValue, "balance": newAccount.balance, "rewards": newAccount.rewards]
        if let accountNumber = newAccount.accountNumber as String? {
            params["account_number"] = accountNumber
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(accountResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(accountResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Account>(data: json)
                completion(accountResponse: response, error: nil)
            }
        })
    }

    public func putAccount(accountId: String, nickname: String, accountNumber: String?, completion: (accountResponse: BaseResponse<Account>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.PUT
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)

        var params: Dictionary<String, AnyObject> = ["nickname": nickname]
        if let newAccountNumber = accountNumber as String? {
            params["account_number"] = newAccountNumber
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            request.HTTPBody = nil
            completion(accountResponse: nil, error: error)
        }
        
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(accountResponse: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Account>(data: json)
                completion(accountResponse: response, error: nil)
            }
        })
    }
    
    public func deleteAccount(accountId: String, completion: (accountResponse: BaseResponse<Account>?, error: NSError?) -> Void) {
        self.requestType = HTTPType.DELETE
        self.accountId = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: self.requestType)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(accountResponse: nil, error: error)
            } else {
                let response = BaseResponse<Account>(requestArray: nil, object: nil, message: "Account deleted")
                completion(accountResponse: response, error: nil)
            }
        })
    }
}