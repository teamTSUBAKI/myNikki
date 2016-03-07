//
//  shareViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/05.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import MessageUI

class shareViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let closeButton = UIBarButtonItem(title: "閉じる", style:.Plain , target: self, action: "closeButtonTaped")
        self.navigationItem.rightBarButtonItem = closeButton
        
        tableView.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")

        // Do any additional setup after loading the view.
    }

    //グーグルアナリティクスを設置
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "shareView")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    
    //余計な線をなくしたい
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        view.backgroundColor = colorFromRGB.colorWithHexString("f5f5f5")
        
        return view
    }

    
    func closeButtonTaped(){
        
        //tmpに作成したpdfを消す。
        
        let tmpFilePath:NSString = NSTemporaryDirectory()
        let filename = "シンプル1"
        let fullFileName = filename.stringByAppendingString(".pdf")
        let tmpFilePaths = tmpFilePath.stringByAppendingPathComponent(fullFileName)
        
        let fileManer = NSFileManager()
        
        do{
            try fileManer.removeItemAtPath(tmpFilePaths)
        }catch{
            print("エラー")
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:shareTableViewCell = tableView.dequeueReusableCellWithIdentifier("shareCell") as! shareTableViewCell
        
        if indexPath.section == 0{
        
            switch indexPath.row{
            
            case 0:
                cell.textLabel?.text = "メールで送る"
            case 1:
                cell.textLabel?.text = "PDFをメールで送る"
            case 2:
                cell.textLabel?.text = "PDFを共有する"
            default:
                print("エラー")
        
            }
        }
        

        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            
            return 3
        }
        
        return 0
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row{
        case 0:
            print("メールで送る")
        case 1:
            onClickStartMailerBth()
            
            
        case 2:
            print("3")
        default:
            print("エラー")
            
        }
        
        
    }
    
    func onClickStartMailerBth(){
        //メールを送信できるかチェック
        if MFMailComposeViewController.canSendMail() == false{
            print("Email send Failed!")
            return
            
        }
        
        sendMailWithPDF("ノート(PDF) by trim:\(appDelegate.dateForPDF)", message: "")
    }
    
    func sendMailWithPDF(subject:String,message:String){
        
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        mailViewController.setSubject(subject)
        mailViewController.setMessageBody(message, isHTML: false)
        
        let PDFfileName = "シンプル1.pdf"
        let tmpPath = NSTemporaryDirectory()
        let PDFfilePath = (tmpPath as NSString).stringByAppendingPathComponent(PDFfileName)
        //tmpからpdfファイルを引っ張ってきたい
        let PDFfile:NSData = NSData(contentsOfFile: PDFfilePath)!
        
        //ここにtmpディレクトリから引っ張ってきたPDFデータをブチ込めばOKかな。
        mailViewController.addAttachmentData(PDFfile, mimeType: "application/pdf", fileName: "trim.pdf")
        self.presentViewController(mailViewController, animated: true, completion: nil)
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Email send Cancelled")
            break
        case MFMailComposeResultSaved.rawValue:
            print("Email saved as aDraft")
            break
        case MFMailComposeResultSent.rawValue:
            print("Email Sent Successfully")
            break
        case MFMailComposeResultFailed.rawValue:
            print("Email Sent Failed")
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
