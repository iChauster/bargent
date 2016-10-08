//
//  ViewController.swift
//  NessieTestProj
//
//  Created by Lopez Vargas, Victor R. on 10/5/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func testAccountsRequests(sender: AnyObject) {
        let _ = AccountTests()
    }
    
    @IBAction func testAtmRequests(sender: AnyObject) {
        let _ = ATMTests()
    }
    
    @IBAction func testBillRequests(sender: AnyObject) {
        let _ = BillTests()
    }
    
    @IBAction func testBranchesRequests(sender: AnyObject) {
        let _ = BranchTests()
    }
    
    @IBAction func testCustomersRequests(sender: AnyObject) {
        let _ = CustomerTests()
    }

    @IBAction func testDepositsRequests(sender: AnyObject) {
        let _ = DepositsTests()
    }
    
    @IBAction func testPurchasesRequests(sender: AnyObject) {
        let _ = PurchasesTests()
    }
    
    @IBAction func testMerchantsRequests(sender: UIButton) {
        let _ = MerchantTests()
    }
    
    @IBAction func testTransfersRequests(sender: AnyObject) {
        let _ = TransfersTests()
    }
    
    @IBAction func testWithdrawalsRequests(sender: UIButton) {
        let _ = WithdrawalsTests()
    }
    
}
