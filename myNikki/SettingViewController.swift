//
//  SettingViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/02/06.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import MessageUI
import RealmSwift

class SettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let userDefaults = NSUserDefaults()
    
    var loginTapedNotificationObserver:NSObjectProtocol?
    
    var loginNoticationObserber:NSObjectProtocol!
   
    var path:String?
    
    var mySwitch:UISwitch?
    
    var calendar:NSCalendar?

    var unit:NSCalendarUnit?
    var comps:NSDateComponents?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorFromRGB.colorWithHexString("0fb5c4")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        let closeButton:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Delete Filled-50"), style: .Plain, target: self, action: "closeButtontaped")
        self.navigationItem.leftBarButtonItem = closeButton
        
        tableView.scrollEnabled = false
        tableView.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        
        //最初に設定を開いた時に、realmにreminderを設定してしまう。
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        if remind.isEmpty{
            
            let reminder = Reminder()
            reminder.id = 1
            reminder.createDate = NSDate()
            
            let now = NSDate()
            calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)
            unit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day]
            comps = calendar?.components(unit!, fromDate: now)
            
            comps?.calendar = calendar
            comps?.hour = 21
            comps?.minute = 00
            
            reminder.Time = comps?.date
            reminder.repitition = 0
            
            try!realm.write({ 
                realm.add(reminder, update: true)
            })
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Setting")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        tableView.reloadData()

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            
            if indexPath.row == 0{
                return 75
            }else{
                return 44
            }
            
        }else{
            
            return 44
            
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        view.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        return view
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
        
        switch section{
        case 0:
            return 44
        case 1:
            return 44
        case 2:
            return 44
     
        default:
            return 100
        }
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:SettingTableViewCell = tableView.dequeueReusableCellWithIdentifier("SettingCell") as! SettingTableViewCell
        let cells:SettingOtherTableViewCell = tableView.dequeueReusableCellWithIdentifier("other")
        as! SettingOtherTableViewCell
        let celler:SettingReminderTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReminderCell") as! SettingReminderTableViewCell
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        if indexPath.section == 0{
            
            switch indexPath.row{
            case 0:
                cell.Photo.image = UIImage(named: "512")
                cell.TSUBAKILabel.text = "じぶん日記"
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            case 1:
                
                cells.menuLabel.text = "バージョン"
                cells.accessoryLabel.text = "1.0.3"
                cells.selectionStyle = UITableViewCellSelectionStyle.None
                return cells
                
            default:
                cell.textLabel?.text = "エラー"
            }
        
            
        }
        
        if indexPath.section == 1{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "リマインダー"
                mySwitch = UISwitch(frame:CGRectMake(0,0,20,20))
                mySwitch?.addTarget(self, action: #selector(SettingViewController.remindTaped), forControlEvents: .TouchUpInside)
                
                if remind.isEmpty || remind[0].repitition == 0{
                    mySwitch!.on = false
                
                }else{
                
                    mySwitch!.on = true
                
                }
                
                
                cell.accessoryView = mySwitch
                
                cell.selectionStyle = .None
                
            case 1:
                
                celler.remindLabel.text = "お知らせの時間"
                
                if remind.isEmpty{
                celler.remindTimelabel.text = "21:00"
                }else{
                    
                    let time:NSDate = remind[0].Time!
                    print("ここ\(time)")
                    calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)!
                    unit = [NSCalendarUnit.Hour,NSCalendarUnit.Minute]
                    comps = calendar?.components(unit!, fromDate: time)
                    let hour = (comps?.hour)!
                    let minute = (comps?.minute)!
                    
                    if minute <= 9{
                    
                        celler.remindTimelabel.text = "\(hour):0\(minute)"
                    
                    }else{
                      
                        celler.remindTimelabel.text = "\(hour):\(minute)"
                        
                    }
                }
                celler.selectionStyle = .None
                celler.accessoryType = .DisclosureIndicator
                
                return celler
            default:
                print("エラー")
            }
            
            
        }
        
        if indexPath.section == 2{
            
            switch indexPath.row{
            case 0:
                cell.textLabel?.text = "お問い合わせ"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

            case 1:
                cell.textLabel?.text = "App Storeで評価する"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
            default:
                cell.textLabel?.text = "エラー"
            }
            
           }
       
        return cell
        
    }
    
    func remindTaped(){
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        let remainder = Reminder()
        remainder.id = 1
        
        //リマインダーボタンを初めて押した、もしくはオフの状態ならば
        if remind.isEmpty || remind[0].repitition == 0{
            
            //リマインダーボタンをオンに
            remainder.repitition = 1
            
            if remind.isEmpty{
                
                let now = NSDate()
                calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)!
                
                unit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day]
                comps = calendar!.components(unit!, fromDate: now)
                
                comps!.calendar = calendar
                comps!.hour = 21
                comps!.minute = 00
                
                remainder.Time = comps!.date
                
                
            }else{
                remainder.Time = remind[0].Time
                
            }
            
        }else{
            //オンならばオフにする
            remainder.repitition = 0
            remainder.Time = remind[0].Time
            
        }
        
        try!realm.write({ 
            realm.add(remainder, update: true)
        })
        
        tableView.reloadData()
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1{
            
            performSegueWithIdentifier("datePicker", sender: nil)
            
        }
        
        if indexPath.section == 2{
            
            if indexPath.row == 0{
                
                let alert = UIAlertController(title: "お問い合わせ",message: "",preferredStyle:.ActionSheet)
                
                let webAction:UIAlertAction = UIAlertAction(title: "web",style: .Default,handler: {(action:UIAlertAction)-> Void in
                
                    let url = NSURL(string: "https://docs.google.com/forms/d/1v-g2ImwaJvwT1K_ORtA7Y54PPHdjg_nqUtZW2yqETcE/viewform")!
                    UIApplication.sharedApplication().openURL(url)
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    
                
                })
                
                let twitterAction:UIAlertAction = UIAlertAction(title: "Twitter",style: .Default,handler: {(action:UIAlertAction)-> Void in
                
                    let url:NSURL = NSURL(string:"https://twitter.com/zibunnikki0630")!
                    UIApplication.sharedApplication().openURL(url)
                     tableView.deselectRowAtIndexPath(indexPath, animated: true)
                })
                
                let mailAction:UIAlertAction = UIAlertAction(title: "mail",style: .Default,handler: {(action:UIAlertAction)-> Void in
                     tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                    self.sendMail()
                
                })
                
                
                let cancel:UIAlertAction = UIAlertAction(title:"キャンセル",style: .Cancel,handler: {(action:UIAlertAction)-> Void in
                
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                })
                
                alert.addAction(cancel)
                alert.addAction(webAction)
                alert.addAction(twitterAction)
                alert.addAction(mailAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
                
    
            }
            
            if indexPath.row == 1{
                
                let url:NSURL = NSURL(string: "https://itunes.apple.com/us/app/jibun-ri-ji-ri-ji-yaritaikotorisuto/id1131614479?mt=8")!
                UIApplication.sharedApplication().openURL(url)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            }
            
        }
        
    }
    
    
    
    func sendMail(){
        
        
        if MFMailComposeViewController.canSendMail() == false{
            
            print("メール送れない")
            return
        }
        
        let mailController = MFMailComposeViewController()
        let toAddress = ["teamTSUBAKI0127@gmail.com"]
        let ccAddress = ["funkyfrea@gmail.com"]
        
        mailController.mailComposeDelegate = self
        mailController.setSubject("フィードバック・改善要望")
        mailController.setToRecipients(toAddress)
        mailController.setCcRecipients(ccAddress)
        
       
        
        self.presentViewController(mailController, animated: true, completion: nil)
        
    }
    
    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue{
        case MFMailComposeResultCancelled.rawValue:
            break
        case MFMailComposeResultSaved.rawValue:
            break
        case MFMailComposeResultSent.rawValue:
            break
        case MFMailComposeResultFailed.rawValue:
            break
        default:
            break
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func closeButtontaped(){
        
        dismissViewControllerAnimated(true, completion: nil)
        
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
