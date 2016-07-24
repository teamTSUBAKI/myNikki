//
//  PhotosAlbumViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/16.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import Photos
import RealmSwift
import SVProgressHUD


//写真ピッカー画面になったら、裏で親ビューを画面遷移させたい
protocol modalViewControllerDelegate{
    
    func modalDidFinished(modaldata:[PHAsset])
    
}

class PhotosAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //モーダルデリゲートを使うためのプロパティを準備
    var delegate:modalViewControllerDelegate! = nil
    
    let userDefaults = NSUserDefaults()
    
    //保存完了通知
    let saveCompleteNotification = "saveComplete"
    
    var saveCompObserver:NSObjectProtocol?
    
    @IBOutlet weak var nonSelectedView: UIView!
    
    //選択された写真のインデックスパスを入れる配列
    var selectIndexPath:[NSIndexPath] = [NSIndexPath]()
    //選択された写真を入れる配列
    var selectPhots:[PHAsset] = [PHAsset]()
    
    var appDelegate:AppDelegate?
    
    var path:String?
    var data:NSData?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var filename:String?
    
    var PhotosSavedObserver:NSObjectProtocol?
    
    @IBOutlet weak var toNoteButton: UIBarButtonItem!
    
    deinit{
        //通知を削除
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("フラグス\(appDelegate?.noteFlag)")
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        
        
        //最初はdoneボタンを無効に
        toNoteButton.enabled = false
        
        self.collectionView.reloadData()
        
        //ナビゲーションバーの色
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        
        //写真の複数選択可能
        collectionView.allowsMultipleSelection = true
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "PhotosAlbumView")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        //写真が保存された通知を受け取ったら
        NSNotificationCenter.defaultCenter().addObserverForName("saved", object: nil, queue: nil, usingBlock:{(notification)in
            
            //リロード
            self.collectionView.reloadData()
            
        })
        
        
    }
    
    
    func collectionView(collectionView: UICollectionView,  numberOfItemsInSection section: Int) -> Int {
        return appDelegate!.photosAssets.count+1
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //viewのwidthを三等分にしたサイズ
        let size = (self.view.frame.size.width-4)/3
        
        return CGSize(width: size, height: size)
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CameraIqon", forIndexPath: indexPath) as! CameraCollectionViewCell
            
            return cell
            
        }else{
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photosCell", forIndexPath: indexPath) as! photosAlbumCollectionViewCell
            
            
            
            let asset = appDelegate?.photosAssets[indexPath.row-1]
            
            let manager:PHImageManager = PHImageManager()
            manager.requestImageForAsset(asset!, targetSize: CGSizeMake((self.view.bounds.size.width-4)/3, (self.view.bounds.size.height-4)/3), contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler:{(image,info)->Void in
                
                if image != nil{
                    
                    cell.imageView.image = image
                }
            })
            
            
            //タグからviewを取得
            let numberLabelView:UIView = cell.viewWithTag(1) as UIView!
            let numberLabel:UILabel = cell.viewWithTag(2) as! UILabel!
            let nonSelectedView:UIView = cell.viewWithTag(3) as UIView!
            
            //表示する写真が選択されたものだったら
            if let index = selectIndexPath.indexOf(indexPath) {
                
                
                cell.contentView.layer.borderColor = UIColor(red: 0, green: 0.545, blue: 0.545, alpha: 1.0).CGColor
                cell.contentView.layer.borderWidth = 4.0
                
                numberLabelView.backgroundColor = UIColor(red: 0, green: 0.545, blue: 0.545, alpha: 1.0)
                numberLabelView.hidden = false
                numberLabel.hidden = false
                numberLabel.textColor = UIColor.whiteColor()
                numberLabel.text = "\(index+1)"
                nonSelectedView.hidden = true
                
            }else{
                
                nonSelectedView.hidden = true
                cell.contentView.layer.borderColor = UIColor.clearColor().CGColor
                cell.contentView.layer.borderWidth = 0.0
                numberLabelView.hidden = true
                numberLabel.hidden = true
                
                
                if selectIndexPath.count == 4 - ((appDelegate?.photosCount))!{
                    
                    nonSelectedView.hidden = false
                    nonSelectedView.alpha = 0.5
                    
                }
                
                
            }
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0{
            
            let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            
            switch status{
            case AVAuthorizationStatus.Authorized:
                //許可されている場合
                let camera = self.storyboard?.instantiateViewControllerWithIdentifier("Camera")
                appDelegate?.albumFlag = true
                self.presentViewController(camera!, animated: true, completion: nil)
                
            case AVAuthorizationStatus.Denied:
                //カメラの使用が禁止されている場合
                break;
            case AVAuthorizationStatus.NotDetermined:
                //まだ確認されていない場合、許可を求めるダイアログを表示
                
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                    
                    if granted{
                        //許可された場合
                        let camera = self.storyboard?.instantiateViewControllerWithIdentifier("Camera")
                        self.appDelegate?.albumFlag = true
                        self.presentViewController(camera!, animated: true, completion: nil)
                        
                        
                    }else{
                        
                        print("不許可")
                        
                    }
                    
                })
                
            default:
                break
                
            }
            
        }else if let index = selectIndexPath.indexOf(indexPath){
            
            //残り一枚ならば、写真が選択されていない状態になるから、doneボタンを無効に。
            if selectPhots.count == 1{
                toNoteButton.enabled = false
            }
            //すでにセレクトされた写真なので、selectIndexPathから消す
            selectIndexPath.removeAtIndex(index)
            selectPhots.removeAtIndex(index)
            
            
        }else{
            
            
            if selectIndexPath.count < 4 - (appDelegate?.photosCount)!{
                
                //配列にないなら入れる
                selectIndexPath.append(indexPath)
                selectPhots.append((appDelegate?.photosAssets[indexPath.row-1])!)
                toNoteButton.enabled = true
            }
            
        }
        //選択されるたびにリロード。
        self.collectionView.reloadData()
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
    }
    
    
    @IBAction func toNoteButton(sender: AnyObject) {
        
        cancelButton.enabled = false
        toNoteButton.enabled = false
        self.dataSave()
        
    }
    
    func dataSave(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count > 0{
            path = paths[0]
        }
           SVProgressHUD.showWithStatus("写真を保存しています")
    
        
          collectionView.allowsSelection = false
        
        //写真の追加だったら
        if appDelegate?.addPhotoFlag == true{
            
            SVProgressHUD.showWithStatus("写真を保存しています")
          
            dispatch_async_global({
                
                let realm = try!Realm()
                let maxNote = realm.objects(Note).sorted("id", ascending: false)
                let note = Note()
                
                let editNoteIds:Int = (self.appDelegate?.editNoteId)!
                let editNote = realm.objects(Note).filter("id = \(editNoteIds)")
                
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                
                if paths.count > 0{
                    
                    self.path = paths[0]
                    
                }else{
                    //エラー処理
                }
                
                
                var ind = 0
                
                for asset in self.selectPhots{
                    
                    self.filename = NSUUID().UUIDString + ".jpg"
                    let filepath = (self.path! as NSString).stringByAppendingPathComponent(self.filename!)
                    
                    
                    let maxPhoto = realm.objects(Photos).sorted("id", ascending: false)
                    
                    
                    try!realm.write({ () -> Void in
                        
                        let photo = Photos()
                        
                        
                        if maxPhoto.isEmpty{
                            
                            photo.id = 1
                            
                            
                        }else{
                            
                            photo.id = maxPhoto[0].id + 1
                            
                        }
                        
                        photo.createDate = editNote[0].createDate
                        photo.filename = self.filename!
                        
                        if ind == self.selectPhots.count - 1{
                            
                            editNote[0].photos.append(photo)
                            
                            
                            
                        }else{
                            
                            editNote[0].photos.append(photo)
                            
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("savePhoto", object: nil)
                        
                    })
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                    options.networkAccessAllowed = true
                    
                    let manager = PHImageManager()
                    //仮説１：オプションをnilにして画質がどうなるかをチェックする。
                    //結果：少し早くなった気もするがあまり効果的ではない感じ。
                    
                    //仮説２：写真サイズをオリジナルにする
                    //結果:あまり変わらず。
                    
                    //比率
                    var minRatio:CGFloat = 1
                    
                    if CGFloat(asset.pixelWidth) > UIScreen.mainScreen().bounds.width || CGFloat(asset.pixelHeight) > UIScreen.mainScreen().bounds.height{
                        
                        //小さい方の辺の比率に合わせる
                        minRatio = min(UIScreen.mainScreen().bounds.width / CGFloat(asset.pixelWidth), UIScreen.mainScreen().bounds.height / CGFloat(asset.pixelHeight))
                        
                    }
                    
                    let size:CGSize = CGSizeMake(CGFloat(asset.pixelWidth)*minRatio + 125, CGFloat(asset.pixelHeight)*minRatio)
                    
                    manager.requestImageForAsset(asset, targetSize:size , contentMode: .AspectFill, options: options, resultHandler: {(image,info)->Void in
                        
                        
                        if image != nil{
                        self.data = UIImageJPEGRepresentation(image!, 0.8)
                        self.data?.writeToFile(filepath, atomically: true)
                        }
                        
                        if ind == self.selectPhots.count - 1{
                           
                            NSNotificationCenter.defaultCenter().postNotificationName(self.saveCompleteNotification, object: nil)
                        }
                        
                        ind += 1
                    })
                    
                }
                
                self.dispatch_async_main({
                    
                   self.saveCompObserver = NSNotificationCenter.defaultCenter().addObserverForName(self.saveCompleteNotification, object: nil, queue: nil, usingBlock: {(notification)in
                        SVProgressHUD.dismiss()
                        self.toNoteDetail()
                    
                    })
                    
                })
                
                
            })
            
            
            
            
            
            
        }else{
            //新規のノートの追加。
        
            
            let semaphore = dispatch_semaphore_create(0)
            
            
            SVProgressHUD.showWithStatus("写真を保存しています")
            dispatch_async_global({
            
            
                
                let realms = try!Realm()
                let maxNotes = realms.objects(Note).sorted("id", ascending: false)
                let notes = Note()
                
                if maxNotes.isEmpty{
                    notes.id = 1
                }else{
                    
                    notes.id = maxNotes[0].id + 1
                }
                
                
                //元に戻し済み。大丈夫な状態。
                notes.createDate = NSDate()
                
                
                /*
                 let date:String = "2016-7-16 22:34:12"
                 let dateformatter:NSDateFormatter = NSDateFormatter()
                 dateformatter.locale = NSLocale(localeIdentifier: "ja")
                 dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                 let changeDate = dateformatter.dateFromString(date)
                 note.createDate = changeDate
                 */
                
                
                try!realms.write({ () -> Void in
                    
                    realms.add(notes, update: true)
                    
                })
                
                
                
                
                //画像の保存先パスを取得
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                if paths.count > 0{
                    self.path = paths[0]
                }else{
                    
                    //エラー処理
                }
                
                
                
                var ind = 0
                
                for asset in self.selectPhots{
                    
                    self.filename = NSUUID().UUIDString + ".jpg"
                    
                    let filepath = (self.path! as NSString).stringByAppendingPathComponent(self.filename!)
                    
                    
                    let maxPhoto = realms.objects(Photos).sorted("id", ascending: false)
                    
                    try!realms.write({ () -> Void in
                        
                        let photo = Photos()
                        
                        
                        if maxPhoto.isEmpty{
                            
                            photo.id = 1
                            
                        }else{
                            
                            photo.id = maxPhoto[0].id + 1
                            
                        }
                        
                        photo.createDate = NSDate()
                        photo.filename = self.filename!
                        
                        notes.photos.append(photo)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("savePhoto", object: nil)
                    })
                    
                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                    options.resizeMode = .Exact
                    options.networkAccessAllowed = true
                    options.synchronous = true
                    
                    
                    
                    
                    let manager = PHImageManager()
                    
                    
                    var minRatio:CGFloat = 1
                    
                    if CGFloat(asset.pixelWidth) > UIScreen.mainScreen().bounds.width || CGFloat(asset.pixelHeight) > UIScreen.mainScreen().bounds.height{
                        
                        minRatio = min(UIScreen.mainScreen().bounds.width / CGFloat(asset.pixelWidth), UIScreen.mainScreen().bounds.height / CGFloat(asset.pixelHeight))
                        
                    }
                    
                    
                    let size:CGSize = CGSizeMake(CGFloat(asset.pixelWidth)*minRatio + 125, CGFloat(asset.pixelHeight)*minRatio)
                    
                    
                    print("アセット\(asset)")
                    manager.requestImageForAsset(asset, targetSize:size , contentMode: .AspectFill, options: options, resultHandler: {(image,info)->Void in
                        
                        /*
                         if image != nil{
                         self.data = UIImageJPEGRepresentation(image!,0.8)
                         self.data?.writeToFile(filepath, atomically: true)
                         
                         }*/
                        
                        
                        
                        if let images = image{
                            
                            print("ヤーゴン")
                            self.data = UIImageJPEGRepresentation(images,0.8)
                            self.data?.writeToFile(filepath, atomically: true)
                            
                        }
                        
                        
                        print("インド\(ind)")
                        print("写真の数すう\(self.selectPhots.count - 1)")
                        
                        /*
                        if ind == self.selectPhots.count - 1{
                            
                            print("ジュベス")
                            
                        
                            NSNotificationCenter.defaultCenter().postNotificationName(self.saveCompleteNotification, object: nil)
                        }*/
                        
                        ind += 1
                        
                        
                        
                    })
                    
                    
                    
                }
                
                
                
                dispatch_semaphore_signal(semaphore)
            
            
            
            
            })
            
            
            
            
            print("こきあ")
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
            
            print("画面遷移先生")
       
            
            self.dispatch_async_main({
                
                SVProgressHUD.dismiss()
                self.toNoteDetail()
                
              /*  print("画面遷移先生")
                    SVProgressHUD.dismiss()
                    self.toNoteDetail()
                */
                
                /*  self.saveCompObserver = NSNotificationCenter.defaultCenter().addObserverForName(self.saveCompleteNotification, object: nil, queue: nil, usingBlock: {(notification) in
                 
                 print("画面遷移先生")
                 SVProgressHUD.dismiss()
                 self.toNoteDetail()
                 })*/
                
                
                
                
            })
            
            
      
            
            
        }
    }
    
    
    //非同期処理関数
    func dispatch_async_main(block:()->()){
        
        dispatch_async(dispatch_get_main_queue(),block)
        
    }
    
    func dispatch_async_global(block:()->()){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
        
    }
    
    
    
    
    func toNoteDetail(){
        
        
        //カメラを経由したならば、
        if self.appDelegate?.cameraViewFlag == true{
            
            //写真追加
            if self.appDelegate?.addPhotoFlag == true{
                
                
                if appDelegate?.noteFlag == true && appDelegate?.returnCamera == false{
                    self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                    appDelegate?.addPhotoFlag = false
                    appDelegate?.noteFlag = true
                    appDelegate?.noPhotoButtonTaped = false
                    
                }else if appDelegate?.noteFlag == false && appDelegate?.returnCamera == false{
                    
                    self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                    appDelegate?.addPhotoFlag = false
                    appDelegate?.noteFlag = false
                    
                }
                
                
                if appDelegate?.returnCamera == true{
                    
                    //新規ノート
                    if appDelegate?.noteFlag == true {
                        
                        //noPhotoButton経由ならば
                        if appDelegate?.noPhotoButtonTaped == true{
                            appDelegate?.returnCamera = false
                            appDelegate?.addPhotoFlag = false
                            appDelegate?.noteFlag = true
                            appDelegate?.noPhotoButtonTaped = false
                            
                            self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                            
                            
                        }else{
                            appDelegate?.noteFlag = true
                            
                            appDelegate?.returnCamera = false
                            appDelegate?.addPhotoFlag = false
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        }
                        
                        
                    }else{
                        
                        //タイムライン
                        appDelegate?.noteFlag = false
                        self.dismissViewControllerAnimated(true, completion: nil)
                        appDelegate?.returnCamera = false
                        appDelegate?.addPhotoFlag = false
                        
                    }
                    
                }
                
                
                
            }else{
                
                if appDelegate?.returnCamera == true{
                    
                    if appDelegate?.tabBarCamera == true{
                        
                        self.appDelegate?.noteFlag = true
                        appDelegate?.returnCamera = false
                        appDelegate?.tabBarCamera = false
                        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        
                        
                        
                    }else{
                        self.appDelegate?.noteFlag = true
                        appDelegate?.returnCamera = false
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                    
                }else{
                    
                    self.appDelegate?.noteFlag = true
                    self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    
                }
                
            }
            
            self.appDelegate?.cameraViewFlag = false
            
        }else{
            
            //写真の追加ならば
            if self.appDelegate?.addPhotoFlag == true{
                
                print("ここます")
                
                self.dismissViewControllerAnimated(true, completion: nil)
                self.appDelegate?.addPhotoFlag = false
                
                
            }else{
                //新規作成ノートであることを伝える。
                self.appDelegate?.noteFlag = true
                self.dismissViewControllerAnimated(true, completion: nil)
                
                
            }
            
            
        }
        
        
        appDelegate?.tabBarCamera = false
        
        print("フラグス後編\(appDelegate?.noteFlag)")

        
    }
    
    
    
    
    @IBAction func canceButton(sender: AnyObject) {
        
        appDelegate?.tabBarCamera = false
        
        appDelegate?.noPhotoButtonTaped = false
        if appDelegate?.textOrCameraFlag == true{
            
            self.presentingViewController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            appDelegate?.addPhotoFlag = false
            appDelegate?.textOrCameraFlag = false
            appDelegate?.cameraViewFlag = false
            
            
        }else{
            
            appDelegate?.addPhotoFlag = false
            self.dismissViewControllerAnimated(true, completion: nil)
            
            
            
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(self.saveCompObserver)
        if saveCompObserver != nil{
        NSNotificationCenter.defaultCenter().removeObserver(self.saveCompObserver!)
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