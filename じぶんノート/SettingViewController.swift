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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.scrollEnabled = false
        tableView.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Setting")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])

        
     
        
       
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
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
            return 1
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
     
        default:
            return 100
        }
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:SettingTableViewCell = tableView.dequeueReusableCellWithIdentifier("SettingCell") as! SettingTableViewCell
        let cells:SettingOtherTableViewCell = tableView.dequeueReusableCellWithIdentifier("other")
        as! SettingOtherTableViewCell
        if indexPath.section == 0{
            
            switch indexPath.row{
            case 0:
                cell.Photo.image = UIImage(named: "114")
                cell.TSUBAKILabel.text = "trim"
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            case 1:
                
                cells.menuLabel.text = "バージョン"
                cells.accessoryLabel.text = "1.0.2"
                cells.selectionStyle = UITableViewCellSelectionStyle.None
                return cells
            default:
                cell.textLabel?.text = "エラー"
            }
        
            
        }
        
        if indexPath.section == 1{
            
            switch indexPath.row{
            case 0:
                cell.textLabel?.text = "フィードバック・改善要望を送る"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

                
            default:
                cell.textLabel?.text = "エラー"
            }
            
           }
       
        return cell
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1{
            
            if indexPath.row == 0{
                
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
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                self.presentViewController(mailController, animated: true, completion: nil)
            }
            
        }
        
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
