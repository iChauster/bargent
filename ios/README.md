# Nessie-iOS-Wrapper

##Synopsis
Capital One Nessie API SDK written in Swift, using SwiftyJSON for JSON parsing. This SDK can be easily embedded in an iOS project.

##Installation
1. Download the entire SDK directory.
2. Open the `Nessie-iOS-Wrapper.xcworkspace` file.
3. Set your API Key in `NSEClient.swift` where `private var key = ""`
4. Start working by either:
  * Creating a new Project Target and add your work there.
  * Adding your files directly into the `Nessie-iOS-Wrapper` target. See `NessieTestProj` for examples.

##Usage and Examples
####Important Note
Any parameter marked as optional in the Nessie documentation are also optional in the SDK. They are simply marked as an `Optional` type in Swift. For instance, `accountType` is an optional field here:
![accountTypeExample](http://i.imgur.com/RsLW1ls.png)

In the `getAccounts()` call, `accountType` is optional. If you wish to get all accounts regardless of account type, just pass in a `nil` value for accountType:
```swift
        AccountRequest().getAccounts(nil, completion:{(response, error) in 
            ...
        )}
```

####Creating a Customer
```Swift
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
```

####Retrieving Customers
```Swift
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
```

You can find examples [here](https://github.com/nessieisreal/nessie-ios-sdk-swift/blob/master/NessieTestProj/NSEFunctionalTests.swift).
