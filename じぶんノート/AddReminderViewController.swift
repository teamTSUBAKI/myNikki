//
//  AddReminderViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/11.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class AddReminderViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var mySwitch:UISwitch?
    var dateCell:datePickerTableViewCell?
    var date:NSDate?
    
    var screentHeight = Double(UIScreen.mainScreen().bounds.size.height)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        tableView.scrollEnabled = false
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
         dateCell = tableView.dequeueReusableCellWithIdentifier("datePicker") as! datePickerTableViewCell
        let startCell:startButtonTableViewCell = tableView.dequeueReusableCellWithIdentifier("theStart") as! startButtonTableViewCell
        
        if indexPath.section == 0{
            
            switchCell.textLabel!.text = "リマインダー"
            mySwitch = UISwitch(frame: CGRectMake(0, 0, 20, 20))
            mySwitch!.on = true
            mySwitch!.addTarget(self, action: "mySwitchTaped:", forControlEvents: .ValueChanged)
            
            switchCell.accessoryView = mySwitch
            switchCell.selectionStyle = .None
            return switchCell
        }
        
        if indexPath.section == 1{
            
            let realm = try!Realm()
            let remind = realm.objects(Reminder)
            
            if remind.isEmpty == false{
                
                dateCell!.datePicker.date = remind[0].Time!
                
            }
            
            dateCell!.datePicker.addTarget(self, action: "datepicks:", forControlEvents: .ValueChanged)
            
            return dateCell!
            
        }
        
        if indexPath.section == 2{
            
            return startCell
            
        }
        
        return startCell
    }
    
    
    func datepicks(sender:AnyObject){
        
        print("時間設定\((sender as! UIDatePicker).date)")
        date = (sender as! UIDatePicker).date
        
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
          
            if screentHeight == 480{
                
                return 120
                
            }else{
            
                return 200
            }
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        

        
        if indexPath.section == 2{
            
            let realm = try!Realm()
            let reminder = Reminder()
            
            reminder.id = 1
            
            if mySwitch?.on == true{
                
                reminder.repitition = 1
            }else{
                
                reminder.repitition = 0
            }
            
            let now = NSDate()
            let calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)
            let unit:NSCalendarUnit = [NSCalendarUnit.Year,.Month,.Day]
            let comps = calendar?.components(unit, fromDate: now)
            
            comps?.calendar = calendar
            comps?.hour = 21
            comps?.minute = 00
            
            if date != nil{
            
                reminder.Time = date
            
            }else{
              
                reminder.Time = comps?.date
                
            }
            
            try!realm.write({ 
                realm.add(reminder, update: true)
            })
            
            
            let userNotification:UIUserNotificationType = [UIUserNotificationType.Alert,UIUserNotificationType.Badge,UIUserNotificationType.Sound]
            
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: userNotification,categories: nil))
         
            performSegueWithIdentifier("Start", sender: nil)
            
        }
        
    }
    
    func mySwitchTaped(sender:UISwitch){
        
       
        
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
