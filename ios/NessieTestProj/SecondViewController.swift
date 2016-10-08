//
//  SecondViewController.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. on 9/16/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func testEnterpriseAccountsRequests(sender: AnyObject) {
        let _ = EnterpriseAccountTests()
    }
    
    @IBAction func testEnterpriseBillsRequests(sender: AnyObject) {
        let _ = EnterpriseBillTests()
    }
    
    @IBAction func testEnterpriseCustomerRequests(sender: AnyObject) {
        let _ = EnterpriseCustomerTests()
    }
    
    @IBAction func testEnterpriseDepositsRequests(sender: AnyObject) {
        let _ = EnterpriseDepositTests()
    }
    
    @IBAction func testEnterpriseMerchantsRequests(sender: AnyObject) {
        let _ = EnterpriseMerchantTests()
    }
    
    @IBAction func testEnterpriseTransfersRequests(sender: AnyObject) {
        let _ = EnterpriseTransferTests()
    }
    
    @IBAction func testEnterpriseWithdrawalsRequests(sender: AnyObject) {
        let _ = EnterpriseWithdrawalTests()
    }
}
