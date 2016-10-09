//
//  ViewController.swift
//  Bargent
//
//  Created by Ivan Chau on 10/8/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit
import NessieFmwk

private let reuseIdentifier = "BargentCell"
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView : UITableView!
    var totalMoney = NSMutableDictionary()
    let client = NSEClient.sharedInstance
    var dict = NSMutableDictionary()
    var goodDict = [AnyObject]()
    var okayDict = [AnyObject]()
    var badDict = [AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        client.setKey("d914174469cc843bb832513eda8b644b")
        self.testGetAccounts()
        testGetAllPurchasesFromAccount()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    func testGetAccounts() {
        let accountType = AccountType.Savings
        
        AccountRequest().getAccounts(accountType, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                if let array = response as Array<Account>? {
                    if array.count > 0 {
                        let account = array[0] as Account?
                        print(account!.accountId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        })
    }
    func testPostPurchase() {
        let purchaseToCreate = Purchase(merchantId: "57f895e7360f81f104543bdb", status: .Cancelled, medium: .Balance, payerId: "57f8949c360f81f104543bd8", amount: 10, type: "merchant", purchaseDate: NSDate(), description: "Description", purchaseId: "asd")
        PurchaseRequest().postPurchase(purchaseToCreate, accountId: "57f94dd7360f81f104543bff", completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                let purchaseResponse = response as BaseResponse<Purchase>?
                let message = purchaseResponse?.message
                let purchaseCreated = purchaseResponse?.object
                print("\(message): \(purchaseCreated)")
                //self.testPutPurchase(purchaseCreated!)
            }
        })
    }
    func testGetAllPurchasesFromAccount() {
        let pushArray = NSMutableArray();
        PurchaseRequest().getPurchasesFromAccountId("57f94dd7360f81f104543bff", completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                if let array = response as Array<Purchase>? {
                    if array.count > 0 {
                        let purchase = array[0] as Purchase!
                        print(array)
                        for purchase in array {
                            print(purchase.description, purchase.amount, purchase.merchantId, purchase.type)
                            pushArray.addObject(NSDictionary(objects: [purchase.amount,purchase.description!,purchase.merchantId,purchase.type!], forKeys: ["amount","description","merchant","type"]));
                        }
                        self.pushToServer(pushArray)
                        //self.testGetPurchase(purchase.purchaseId)
                    } else {
                        print("No purchases found")
                    }
                }
            }
        })
    }
    func pushToServer(array : NSMutableArray) {
        print(array)
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(array, options: NSJSONWritingOptions.PrettyPrinted)
            let string = NSMutableData(data: jsonData)
            let headers = [
                "content-type": "application/json",
                "cache-control": "no-cache",
                ]
            
            let postData = string;
            let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:3000/getExpenseData")!,
                                              cachePolicy: .UseProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.HTTPMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.HTTPBody = postData
            
            let session = NSURLSession.sharedSession()
            let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error)
                } else {
                    let httpResponse = response as? NSHTTPURLResponse
                    print(httpResponse)
                    if(httpResponse?.statusCode == 200){
                        dispatch_async(dispatch_get_main_queue(), {
                            do{
                                let arr  = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSMutableArray;
                                var x = 0;
                                for obj in arr {
                                    if(x == 4){
                                        x += 1;
                                    }else{
                                        let string = obj["category"] as! String
                                        if (self.dict.valueForKey(string) != nil){
                                            let array = self.dict.valueForKey(string)
                                            array!.addObject(obj)
                                            self.dict.setValue(array, forKey: string)
                                        }else{
                                            self.dict.setValue(NSMutableArray(array: [obj]), forKey: string)
                                        }
                                        x += 1;
                                    }
                                    
                                }
                                print(self.dict)
                                let newDict = NSMutableDictionary();
                                for (key, value) in self.dict {
                                    let arr = value as! NSArray
                                    var total = 0.0;
                                    for i in arr {
                                        
                                        total += Double(i["amount"] as! NSNumber)
                                    }
                                    newDict.setValue(total, forKey: key as! String)
                                }
                                print(newDict)
                                self.totalMoney = newDict
                                let sortedKeys2 = newDict.keysSortedByValueUsingComparator
                                    {
                                        ($0 as! NSNumber).compare($1 as! NSNumber)
                                }
                                self.newDict = sortedKeys2
                                self.tableView.reloadData()
                            
                            }catch{
                                
                            }
                        })
                    }
                    
                }
            })
            dataTask.resume()
        } catch{
            print("parsing error")
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*var x = 0, y = 0, z = 0
        for (_, values) in self.totalMoney{
            let da = Double(values as! NSNumber)
            if (da < 35){
                z += 1;
            }else if (da < 140){
                y += 1;
            }else{
                x += 1;
            }
            
        }
        if(section == 0){
            return x;
        }else if (section == 1){
            return y;
        }else {
            return z;
        }*/
        return self.newDict.count;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BargentCell") as! BargentTableViewCell
        let key = self.newDict[indexPath.row] as! String
        let array = self.dict[key] as! NSMutableArray;
        var total = 0.0;
        for i in array {
            total += Double(i["amount"] as! NSNumber)
        }
        cell.cashLabel.text = "$" + String(total)
        cell.infoLabel.text = key;
        
        return cell;
    }
  /*  func testGetAccount(accountId: String) {
        AccountRequest().getAccount(accountId, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                if let account = response as Account? {
                    print(account)
                    self.testGetCustomerAccounts(account.customerId)
                }
            }
        })
    }
    func testGetCustomerAccounts(customerId: String) {
        AccountRequest().getCustomerAccounts(customerId, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                if let array = response as Array<Account>? {
                    print(array)
                    let account = array[0] as Account?
                    self.testPostAccount(account!.customerId)
                    self.testPutAccount(account!.accountId, nickname: "New nickname", accountNumber: "0987654321123456")
                }
            }
        })
    }
    func testPostAccount(customerId: String) {
        let accountType = AccountType.Savings
        let accountToCreate = Account(accountId: "", accountType:accountType, nickname: "Hola", rewards: 10, balance: 100, accountNumber: "1234567890123456", customerId: customerId)
        AccountRequest().postAccount(accountToCreate, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                let accountResponse = response as BaseResponse<Account>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }
    
    func testPutAccount(accountId: String, nickname: String, accountNumber: String?) {
        AccountRequest().putAccount(accountId, nickname: nickname, accountNumber: accountNumber, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                let accountResponse = response as BaseResponse<Account>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }
    
    func testPostCustomer() {
        let address = Address(streetName: "Street", streetNumber: "1", city: "City", state: "VA", zipCode: "12345")
        let customerToCreate = Customer(firstName: "Ivan", lastName: "Chau", address: address, customerId: "skjdfhskdjghskjdgh")
        CustomerRequest().postCustomer(customerToCreate, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                let customerResponse = response as BaseResponse<Customer>?
                let message = customerResponse?.message
                let customerCreated = customerResponse?.object
                print("\(message): \(customerCreated)")
                self.testPutCustomer(customerCreated!)
            }
        })
    }
    func testPutCustomer(customerToBeModified: Customer) {
        customerToBeModified.firstName = "Raul"
        CustomerRequest().putCustomer(customerToBeModified, completion:{(response, error) in
            if (error != nil) {
                print(error)
            } else {
                let accountResponse = response as BaseResponse<Customer>?
                let message = accountResponse?.message
                let accountCreated = accountResponse?.object
                print("\(message): \(accountCreated)")
            }
        })
    }*/


}

