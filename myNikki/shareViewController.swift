//
//  shareViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/05.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import MessageUI

class shareViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var dic:UIDocumentInteractionController?
    
    var path:String?
    
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
        let filename = "\(appDelegate.nameOfPDF)"
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
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:shareTableViewCell = tableView.dequeueReusableCellWithIdentifier("shareCell") as! shareTableViewCell
        
        if indexPath.section == 0{
        
            switch indexPath.row{
            
            case 0:
                cell.textLabel?.text = "PDFをメールで送る"
            case 1:
                cell.textLabel?.text = "PDFを共有する"
            default:
                print("エラー")
        
            }
        }
        

        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            
            return 2
        }
        
        return 0
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row{
    
        case 0:
            onClickPDFMailerTaped()
            
            
        case 1:
            
            openPDFin()
            
        default:
            print("エラー")
            
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
    }
    
    //PDFじゃなくて、写真を本文に貼り付けてメール送信機能を作るためのコード。途中。いずれ使うかもしれない。
    /*
    func onClicksStartMailerTaped(){
        
        if MFMailComposeViewController.canSendMail() == false{
            print("Email send failed")
            return
        }
        
        let mailerController = MFMailComposeViewController()
        
        mailerController.mailComposeDelegate = self
        mailerController.setSubject("ノート by trim:\(appDelegate.dateForPDF)")
        
        if appDelegate.Photoes != nil{
        
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
            if paths.count > 0{
                path = paths[0]
            }
            
            for ind in 1...appDelegate.Photoes.count{
                
                let fileName = appDelegate.Photoes[ind-1].filename
                let filePath = (path! as NSString).stringByAppendingPathComponent(fileName)
                
                let image = UIImage(contentsOfFile: filePath)
                let imagedata = UIImageJPEGRepresentation(image!, 1.0)
                mailerController.addAttachmentData(imagedata!, mimeType: "image/png", fileName: "image")
            }
        
        }
        
        self.presentViewController(mailerController, animated: true, completion: nil)
    }*/
    
    
    func openPDFin(){
        
        print("PDF")
        
            let fileName = "\(appDelegate.nameOfPDF).pdf"
            let tmpPath = NSTemporaryDirectory()
            let filePath = (tmpPath as NSString).stringByAppendingPathComponent(fileName)
        
            let fileURL:NSURL = NSURL(fileURLWithPath: filePath)
        
            dic = UIDocumentInteractionController(URL: fileURL)
            dic?.delegate = self
            dic?.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
            
        }
    
    
    func onClickPDFMailerTaped(){
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
        
        let PDFfileName = "\(appDelegate.nameOfPDF).pdf"
        let tmpPath = NSTemporaryDirectory()
        let PDFfilePath = (tmpPath as NSString).stringByAppendingPathComponent(PDFfileName)
        
        //tmpからpdfファイルを引っ張ってきたい
        let PDFfile:NSData = NSData(contentsOfFile: PDFfilePath)!
        
        //ここにtmpディレクトリから引っ張ってきたPDFデータをブチ込めばOKかな。
        mailViewController.addAttachmentData(PDFfile, mimeType: "application/pdf", fileName: "\(appDelegate.nameOfPDFForMail).pdf")
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
