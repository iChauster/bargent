//
//  EnterpriseRequests.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 9/15/16.
//  Copyright (c) 2016 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Enterprise {
    var id: String? { get }
    var urlName: String { get }
    func buildRequestUrl() -> String
}

extension Enterprise {
    func buildRequestUrl() -> String {
        var requestString = "\(baseEnterpriseString)\(urlName)"
        if let id = id {
            requestString += "/\(id)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString
    }
}

public struct EnterpriseAccountRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "accounts"
    
    public init () {}
    
    public func getAccounts(completion:(accountsArray: Array<Account>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(accountsArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(accountsArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Account>(data: json)
                completion(accountsArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getAccount(accountId: String, completion: (customer: Account?, error: NSError?) -> Void) {
        self.id = accountId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Account>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
}

public struct EnterpriseBillRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "bills"
    
    public init () {}
    
    public func getBills(completion:(billsArray: Array<Bill>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(billsArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(billsArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Bill>(data: json)
                completion(billsArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getBill(bilId: String, completion: (customer: Bill?, error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Bill>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
}

public struct EnterpriseCustomerRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "customers"
    
    public init () {}
    
    public func getCustomers(completion:(customersArray: Array<Customer>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customersArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(customersArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Customer>(data: json)
                completion(customersArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getCustomer(bilId: String, completion: (customer: Customer?, error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
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
}

public struct EnterpriseDepositRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "deposits"
    
    public init () {}
    
    public func getDeposits(completion:(depositsArray: Array<Deposit>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(depositsArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(depositsArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Deposit>(data: json)
                completion(depositsArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getDeposit(bilId: String, completion: (customer: Deposit?, error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Deposit>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
}

public struct EnterpriseMerchantRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "merchants"
    
    public init () {}
    
    public func getMerchants(completion:(merchantsArray: Array<Merchant>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(merchantsArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(merchantsArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Merchant>(data: json)
                completion(merchantsArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getMerchant(bilId: String, completion: (customer: Merchant?, error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Merchant>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
}

public struct EnterpriseTransferRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "transfers"
    
    public init () {}
    
    public func getTransfers(completion:(transfersArray: Array<Transfer>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(transfersArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(transfersArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Transfer>(data: json)
                completion(transfersArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getTransfer(bilId: String, completion: (customer: Transfer?, error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Transfer>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
}

public struct EnterpriseWithdrawalRequest: Enterprise {
    var id: String? = nil
    var urlName: String = "withdrawals"
    
    public init () {}
    
    public func getWithdrawals(completion:(withdrawalsArray: Array<Withdrawal>?, error: NSError?) -> Void) {
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(withdrawalsArray: nil, error: error)
            } else {
                guard let data = data else {
                    completion(withdrawalsArray: nil, error: genericError)
                    return
                }
                let json = JSON(data: data)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(withdrawalsArray: response.requestArray, error: nil)
            }
        })
    }
    
    public mutating func getWithdrawal(bilId: String, completion: (customer: Withdrawal?, error: NSError?) -> Void) {
        self.id = bilId
        
        let nseClient = NSEClient.sharedInstance
        let request = nseClient.makeRequest(buildRequestUrl(), requestType: .GET)
        nseClient.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                completion(customer: nil, error: error)
            } else {
                let json = JSON(data: data!)
                let response = BaseResponse<Withdrawal>(data: json)
                completion(customer: response.object, error: nil)
            }
        })
    }
}
