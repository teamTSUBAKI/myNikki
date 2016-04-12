//
//  AddReminderViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/11.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0:
           return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let switchCell:AddReminderSwitchTableViewCell = tableView.dequeueReusableCellWithIdentifier("switch") as! AddReminderSwitchTableViewCell
        let dateCell:datePickerTableViewCell = tableView.dequeueReusableCellWithIdentifier("datePicker") as! datePickerTableViewCell
        let startCell:startButtonTableViewCell = tableView.dequeueReusableCellWithIdentifier("theStart") as! startButtonTableViewCell
        
        if indexPath.section == 0{
            
            switchCell.textLabel!.text = "リマインダー"
            let mySwitch = UISwitch(frame: CGRectMake(0, 0, 20, 20))
            mySwitch.addTarget(self, action: "mySwtchTaped", forControlEvents: .TouchUpInside)
            
            switchCell.accessoryView = mySwitch
            
            return switchCell
        }
        
        if indexPath.section == 1{
            
            return dateCell
            
        }
        
        if indexPath.section == 2{
            
            return startCell
            
        }
        
        return startCell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        
        return view
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
           return 44
        case 1:
            return 200
        case 2:
            return 44
        default:
            return 44
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 50
        case 1:
            return 40
        case 2:
            return 40
        default:
            40
        }
        
        return 70
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = colorFromRGB.colorWithHexString("f5f5f5")
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let label:UILabel = UILabel(frame:CGRectMake(8,2,self.view.bounds.width,44))
            label.font = UIFont(name: "HiraKakuProN-W3", size: 15)
            label.numberOfLines = 0
            label.text = "  リマインダーを設定し、\n  仕事、練習の記録を習慣にしましょう"
            label.textColor = UIColor.grayColor()
            return label
        case 1:
            let labels = UILabel()
            labels.font = UIFont(name: "HiraKakuProN-W3", size: 17)
            labels.text = "  時間設定"
            labels.textColor = UIColor.grayColor()
            return labels
        case 2:
            return nil
        default:
            return nil
        }
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
