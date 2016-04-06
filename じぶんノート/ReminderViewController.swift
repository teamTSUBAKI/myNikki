//
//  ReminderViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/05.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //便宜的に、まずはadd reminderボタンだけを作り、realmに記録することをつくる。
        //常に小さく作り始める
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:AddReminderTableViewCell = tableView.dequeueReusableCellWithIdentifier("addRemider") as! AddReminderTableViewCell
        
        if indexPath.row == 0{
            
          cell.addRemiderLabel.text = "リマインダーを追加する"
            return cell
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let View = UIView()
        
        View.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        //View.backgroundColor = UIColor.redColor()
        return View
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
