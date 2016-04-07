//
//  ReminderViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/05.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        return remind.count + 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //便宜的に、まずはadd reminderボタンだけを作り、realmに記録することをつくる。
        //常に小さく作り始める
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        if remind.count == 0{
            
            return 1
            
        }else{
            
            if section < remind.count{
                return 2
            }
            
            if section == remind.count {
                return 1
            }
            
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        let cells:ReminderTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell") as! ReminderTableViewCell
        
        let cell:AddReminderTableViewCell = tableView.dequeueReusableCellWithIdentifier("addRemider") as! AddReminderTableViewCell
        
        if indexPath.section < remind.count{
          
            if indexPath.row == 0{
                
                print("リマ")
                cells.textLabel?.text = "Time"
                
            }
            
            if indexPath.row == 1{
                print("リマいん")
                cells.textLabel?.text = "繰り返し"
            }
            
            return cells
        }
        
        if indexPath.section == remind.count{
        
            
            if indexPath.row == 0{
            print("リマい")
            cell.addRemiderLabel.text = "リマインダーを追加する"
            return cell
        
            }
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0{
            
            print(indexPath.section)
            
            let realm = try!Realm()
            
            let reminder = Reminder()
            
            let remind = realm.objects(Reminder).sorted("id", ascending: false)
            
            if remind.isEmpty{
                
                reminder.id = 1
            
            }else{
             
                reminder.id = remind[0].id + 1
                
            }
            
            reminder.createDate = NSDate()
            reminder.Time = NSDate()
            
            reminder.repitition = 0
            
            try!realm.write({ 
                
                realm.add(reminder, update: true)
            })
            
            tableView.reloadData()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
    
        let View = UIView()
        
        if section == remind.count{
    
         View.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
         //View.backgroundColor = UIColor.redColor()
        return View
        }
        
       return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        if section == remind.count{
            
            return 100
        }
        
        return 0

        
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
