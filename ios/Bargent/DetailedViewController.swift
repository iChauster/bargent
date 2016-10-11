//
//  DetailedViewController.swift
//  Nessie-iOS-Wrapper
//
//  Created by Ivan Chau on 10/9/16.
//  Copyright © 2016 Nessie. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var xbutton : UIBarButtonItem!
    @IBOutlet weak var percentView : UIView!
    @IBOutlet weak var cashView : UIView!
    @IBOutlet weak var cash : UILabel!
    @IBOutlet weak var percent : UILabel!
    @IBOutlet weak var topic : UILabel!
    @IBOutlet weak var passage : UITextView!
    var category:String!
    var cashString : String!
    var expenses : NSMutableDictionary!
    var grandTotal : Double!
    var status : String!
    var arrayCovered = NSMutableArray()
    var oldExpenses = 0.0;
    var newExpenses = 0.0;
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.percentView.layer.cornerRadius = 10;
        self.cashView.layer.cornerRadius = 10;
        self.cash.text = cashString
        self.topic.text = category
        if((self.status == nil)){
            self.status = "";
        }
        self.passage.text = "Expenses in the previous month for " + self.category + ".\n\n" + self.status;
        self.arrayCovered = expenses[category] as! NSMutableArray
        var percentage = Double(String(self.cashString.characters.dropFirst()))!/grandTotal
        percentage = round(1000.0 * percentage) / 1000.0
        self.percent.text = String(percentage * 100) + "%"
        /*NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setMonth:-1]; // note that I'm setting it to -1
        NSDate *endOfWorldWar3 = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];*/
        let offsetComponents = NSDateComponents()
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        offsetComponents.month = -1;
        let monthago = gregorian?.dateByAddingComponents(offsetComponents, toDate: NSDate(), options: NSCalendarOptions.MatchFirst)
        self.oldExpenses = getOldExpenses(monthago!)
        self.passage.text.appendContentsOf("\nExpenses from last month : $" + String(self.oldExpenses) + "\nExpenses from this month: $" + String(self.newExpenses));
        if(self.oldExpenses != 0.0 && self.newExpenses != 0.0){
            var perc = (self.newExpenses - self.oldExpenses) / self.oldExpenses;
            perc = round(1000.0 * perc) / 1000.0
            self.passage.text.appendContentsOf("\n Trend from last month :" + String(perc*100.0) + "%")
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayCovered.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailTableViewCell") as! DetailTableViewCell
        let purchase = arrayCovered[indexPath.row]
        cell.goods.text = purchase["description"] as? String
        cell.name.text = purchase["merchantName"] as? String
        let dubs = Double(purchase["amount"] as! NSNumber)
        cell.price.text = String(dubs)

        return cell;
    }
    func getOldExpenses(date: NSDate) -> Double{
        let dateFormat = NSDateFormatter()
        var expenses = 0.0
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        for i in self.expenses {
            print(i)
            if(i.key as! String == self.category){
                let arr = i.value as! NSMutableArray
                for a in arr {
                    let stringDate = a["purchase_date"] as! String
                    let actualDate = dateFormat.dateFromString(stringDate)
                    if(date.compare(actualDate!) == .OrderedDescending){
                        expenses += Double(a["amount"] as! NSNumber)
                    }else if(date.compare(actualDate!) == .OrderedAscending || date.compare(actualDate!) == .OrderedSame){
                        self.newExpenses += Double(a["amount"] as! NSNumber)
                    }
                }
            }
        }
        return expenses;
    }
    @IBAction func segueBack(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
