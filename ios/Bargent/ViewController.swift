//
//  ViewController.swift
//  Bargent
//
//  Created by Ivan Chau on 10/8/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit
import NessieFmwk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testPostCustomer()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func testPostCustomer() {
        // construct the Customer object you want to create
        // in this case, address is an object so it needs its own initializer
        let address = Address(streetName: "Street", streetNumber: "1", city: "City", state: "VA", zipCode: "12345")
        let customerToCreate = Customer(firstName: "Victor", lastName: "Lopez", address: address, customerId: "sup3rc00la1ph4num3r1cId")
        
        // send the request using the wrapper!
        CustomerRequest().postCustomer(customerToCreate, completion:{(response, error) in
            if (error != nil) {
                // handling the error. You could alternatively not have this block if you so choose
                print(error)
            } else {
                // map the response and determine how to use i
                // in this case, we only print to console
                let customerResponse = response as BaseResponse<Customer>?
                let message = customerResponse?.message
                let customerCreated = customerResponse?.object
                print("\(message): \(customerCreated)")
                self.testPutCustomer(customerCreated!)
            }
        })
    }
    func testGetCustomers() {
        // Retrieve all the Customers!
        CustomerRequest().getCustomers({(response, error) in
            if (error != nil) {
                // optionally handle the error here
                print(error)
            } else {
                // we are expecting back an array of customers. Type check!
                if let array = response as Array<Customer>? {
                    // if there are Customers in the result, print the first Customer
                    if array.count > 0 {
                        let customer = array[0] as Customer?
                        self.testGetCustomer(customer!.customerId)
                        print(array)
                    } else {
                        print("No accounts found")
                    }
                }
            }
        })
    }
    func testGetCustomer(customerId: String) {
        var request = EnterpriseCustomerRequest()
        request.getCustomer(customerId){ (response, error) in
            if (error != nil) {
                print(error)
            } else {
                if (error != nil) {
                    print(error)
                } else {
                    if let account = response as Customer? {
                        print(account)
                    }
                }
            }
        }
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
    }



}

