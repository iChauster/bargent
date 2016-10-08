//
//  NSEClient.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 4/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum HTTPType: String {
    case GET
    case POST
    case PUT
    case DELETE
}

internal let baseString = "http://api.reimaginebanking.com"
internal let baseEnterpriseString = "\(baseString)/enterprise/"
internal var dateFormatter = NSDateFormatter()
internal let genericError = NSError(domain:"com.nessie", code:0, userInfo:[NSLocalizedDescriptionKey : "Error", NSLocalizedFailureReasonErrorKey : "No description"])

public class NSEClient {
    
    public class var sharedInstance: NSEClient {
        struct Static {
            static var instance: NSEClient?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NSEClient()
        }
        
        return Static.instance!
    }
    
    private var key = "d914174469cc843bb832513eda8b644b"
    
    public func getKey() -> String {
        if key == "" {
            NSLog("Attempting to get unset key. Don't forget to set the key before sending requests!")
        }
        return key;
    }
    
    public func setKey(key:String) {
        self.key = key
    }
    
    private init() {
        dateFormatter.dateFormat = "yyyy-dd-MM"
    }
    
    public func buildRequest(requestType: HTTPType, url: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = requestType.rawValue
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request
    }
    
    public func makeRequest(requestUrl: String, requestType: HTTPType) -> NSMutableURLRequest {
        let requestString = requestUrl
        let nseClient = NSEClient.sharedInstance
        
        let request = nseClient.buildRequest(requestType, url: requestString)
        return request
    }
    
    public func loadDataFromURL(request: NSMutableURLRequest, completion:(data: NSData?, error: NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTaskWithRequest(request, completionHandler:{(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if (200 ... 299 ~= httpResponse.statusCode) {
                    completion(data: data, error: nil)
                } else {
                    let json = JSON(data: data!)
                    let errorMessage = json["message"].string ?? "Something went wrong. Check your connection."
                    let culprit = json["culprit"].array
                    let culpritMessage: String = culprit?.first?.rawString() ?? "Unknown reason"
                    let statusError = NSError(domain:"com.nessie", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : errorMessage, NSLocalizedFailureReasonErrorKey : culpritMessage])
                    completion(data: nil, error: statusError)
                }
            }
        })
        
        loadDataTask.resume()
    }
    
    
//**********//
    // In progress
    class func invokeService<T:Initable> (service: String, withParams params: Dictionary<String, String>, returningClass: T.Type, completionHandler handler: ((Initable) -> ())) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "asd")!)
        NSEClient.sharedInstance.loadDataFromURL(request, completion: {(data, error) -> Void in
            if (error != nil) {
                return
            } else {
                let json = JSON(data: data!)
                handler(BaseClass(data: json))
            }
        })
    }
}

protocol Initable {
    init(data:JSON)
}

public class BaseClass: Initable {
    
    public let previuosPage: String
    public let nextPage: String
    public let requestArray: Array<AnyObject>
    
    required public init(data:JSON) {
        self.requestArray = data["data"].arrayValue.map({Atm(data:$0)})
        self.previuosPage = data["paging"]["previous"].string ?? ""
        self.nextPage = data["paging"]["next"].string ?? ""
    }
}
//**********//

public class BaseResponse<T:JsonParser> {
    
    public var requestArray: Array<T>?
    public var object: T?
    public var message: String?
    
    internal init(data: JSON) {
        if (data["data"].null == nil) {
            self.requestArray = data["data"].arrayValue.map({T(data:$0)})
        } else if (data["results"].null == nil) {
            self.requestArray = data["results"].arrayValue.map({T(data:$0)})
        } else {
            self.requestArray = data.arrayValue.map({T(data:$0)})
        }
        if (data["objectCreated"].null == nil) {
            self.object = T(data: data["objectCreated"])
        } else {
            self.object = T(data: data)
        }
        self.message = data["message"].string ?? ""
    }
    
    internal init(requestArray: Array<T>?, object: T?, message: String?) {
        self.requestArray = requestArray
        self.object = object
        self.message = message
    }
}

public protocol JsonParser {
    init (data: JSON)
}

extension String {
    func stringToDate() -> NSDate? {
        if let date = dateFormatter.dateFromString(self) {
            return date
        } else {
            return NSDate()
        }
    }
}
