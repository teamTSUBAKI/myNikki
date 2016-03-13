//
//  SettingViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/02/06.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import MessageUI
import SwiftyDropbox
import RealmSwift

class SettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
   
    var path:String?
    
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
        
        //Dropboxにログイン後、一回目のタイムライン表示のタイミングですべての写真、realmデータをdropboxに保存し、同時に復元する。
        //Dropboxにログイン済みなら
        if (Dropbox.authorizedClient != nil){
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let dic = ["firstAfterDropBoxLogin":true]
            userDefaults.registerDefaults(dic)
            
            
            //ログイン後、一回目ならば。
            if userDefaults.boolForKey("firstAfterDropBoxLogin"){
                print("ログイン")
                //dropboxへすべての写真、default.realmをバックアップ
                
                downLoadFromDropbox()
                
                userDefaults.setBool(false, forKey: "firstAfterDropBoxLogin")
                
                
            }else{
                
                
                
            }
            
        }else{
            
            
            
        }
        
    }
    
    //ドロップボックスからdefaultと写真をダウンロード。
    func downLoadFromDropbox(){
        
        if let client = Dropbox.authorizedClient{
            
            //ダウンロード先のURLを設定
            let destination:(NSURL,NSHTTPURLResponse) -> NSURL = {temporaryURL,response in
                
                
                let directoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains:
                    .UserDomainMask)[0]
                let pathComponent = "defaults.realm"
                return directoryURL.URLByAppendingPathComponent(pathComponent)
                
                
            }
            
            client.files.download(path: "/default.realm", destination: destination).response({ (response, error) -> Void in
                
                if let (metadata,url) = response{
                    
                    print("download \(metadata.name)")
                    print("ダウンロード１")
                    //defaults.realmを復元してdefault.realmに上書きする前に、default.realm（未ログイン時のデータ)をdefaults.realmにコピーしたい
                    let realm = try!Realm()
                    let realmNote = realm.objects(Note)
                    
                    var config = Realm.Configuration()
                    config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("defaults").URLByAppendingPathExtension("realm").path
                    
                    let realms = try!Realm(configuration: config)
                    let maxNote = try!realms.objects(Note).sorted("id", ascending: false)[0]
                    let maxId = maxNote.id
                    var not:Note!
                    
                    
                    
                    for note in realmNote{
                        
                        
                        not = Note()
                        
                        not.id = maxId + note.id
                        not.createDate = note.createDate
                        not.editDate = note.editDate
                        not.noteText = note.noteText
                        not.modelName = note.modelName
                        not.timerTime = note.timerTime
                        
                        //写真は写真で取り出して、コピーしていくやり方でうまくいくか検証.うまくコピーできた！
                        let maxPhoto = try!realms.objects(Photos).sorted("id", ascending: false)[0]
                        let maxPhotoID = maxPhoto.id
                        
                        //すべて写真を一気に入れるのではなくて、ノートごとに取り出して、入れていけばいいのではないか。
                        for photo in note.photos{
                            
                            let phot = Photos()
                            
                            phot.id = maxPhotoID + photo.id
                            phot.createDate = photo.createDate
                            phot.filename = photo.filename
                            
                            try!realms.write({ () -> Void in
                                
                                not.photos.append(phot)
                                
                            })
                            
                        }
                        

                        
                        
                        print("フレッシュ")
                        try!realms.write({ () -> Void in
                            realms.add(not, update: true)
                            
                        })
                        
                        
                        
                    }
                    
                    
                    
                    
                    //上記のコードで、ドロップボックスからDocumenetDirectoryにdefault.realmをdefaults.realmという名前でダウンロードした(同じ名前だとダウンロードできないため)。ここでdefault.realmを削除して、defaults.realmをdefault.realmに名前変更したい。
                    let documentDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let fileName = "defaults.realm"
                    let fileNames = "default.realm"
                    
                    print("ダウンロード２")
                    
                    if NSFileManager.defaultManager().fileExistsAtPath("\(documentDirPath)/\(fileName)") && NSFileManager.defaultManager().fileExistsAtPath("\(documentDirPath)/\(fileNames)"){
                        
                        try!NSFileManager.defaultManager().removeItemAtPath("\(documentDirPath)/\(fileNames)")
                        try!NSFileManager.defaultManager().moveItemAtPath("\(documentDirPath)/\(fileName)", toPath: "\(documentDirPath)/\(fileNames)")
                        
                        
                    }
                    
                    self.uploadToDropBox()
                    
                    
                }else{
                    print(error)
                }
                
            })
            
            
        }
        
    }
    
    //ドロップボックスに既存の写真、データをアップロードする
    func uploadToDropBox(){
        
        print("やぁねー")
        
        let Paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        if Paths.count > 0{
            
            path = Paths[0]
            
        }
        
        let documetURL = NSURL(fileURLWithPath:path!)
        
        let realm = try!Realm()
        let photos = realm.objects(Photos)
        print("イノセントワールド")
        for  photo in photos{
            
            let filename = photo.filename
            let fileURLs = documetURL.URLByAppendingPathComponent(filename)
            
            if let client = Dropbox.authorizedClient{
                client.files.upload(path: "/\(filename)", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, body: fileURLs).response({ (response,error) -> Void in
                    
                    if let metaData = response{
                        print("uploaded file \(metaData)")
                    }else{
                        print(error!)
                    }
                    
                })
                
            }
            
            
        }
        
        //その時のdefault.realmをアップロード
        let fileURL = documetURL.URLByAppendingPathComponent("default.realm")
        
        if let client = Dropbox.authorizedClient{
            client.files.upload(path: "/default.realm", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, body: fileURL).response({ (response, error) -> Void in
                
                if let metadata = response{
                    print("uploaded file \(metadata)")
                }else{
                    print(error!)
                }
                
            })
            
        }
        
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
            case 1:
                cell.textLabel!.text = "Dropboxにバックアップする"
                //switchボタンを作る
                let mySwitch = UISwitch(frame: CGRectMake(0,0,20,20))
                
                //ログイン済みなら
                if let _ = Dropbox.authorizedClient{
                
                    mySwitch.on = true
                
                }else{
                
                
                    mySwitch.on = false
                
                }
                
                mySwitch.addTarget(self, action: "DropboxTaped:", forControlEvents: UIControlEvents.ValueChanged)
                cell.accessoryView = mySwitch
                
            default:
                cell.textLabel?.text = "エラー"
            }
            
           }
       
        return cell
        
    }
    
    func DropboxTaped(sender:UISwitch){
        
        if sender.on{
            
            //ログイン済みなら
            if let _ = Dropbox.authorizedClient{
                //すでにログイン済みの場合、クラッシュしてしまうのでログアウトする
                Dropbox.unlinkClient()
            }
            
            //ログイン画面を表示する
            Dropbox.authorizeFromController(self)
            
        }else{
           
            //switchをオフにしたらログアウト
            Dropbox.unlinkClient()
            
        }
        
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
