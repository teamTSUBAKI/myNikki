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


//写真ピッカー画面になったら、裏で親ビューを画面遷移させたい
protocol modalViewControllerDelegate{
    
    func modalDidFinished(modaldata:[PHAsset])
    
}

class PhotosAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //モーダルデリゲートを使うためのプロパティを準備
    var delegate:modalViewControllerDelegate! = nil
    
    let userDefaults = NSUserDefaults()
    
    @IBOutlet weak var nonSelectedView: UIView!
    
    //選択された写真のインデックスパスを入れる配列
    var selectIndexPath:[NSIndexPath] = [NSIndexPath]()
    //選択された写真を入れる配列
    var selectPhots:[PHAsset] = [PHAsset]()
    
    var appDelegate:AppDelegate?
    
    var path:String?
    var data:NSData?
    
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
        
        self.dataSave()
        
        //カメラを経由したならば、
            if self.appDelegate?.cameraViewFlag == true{
                
                //写真追加
                if self.appDelegate?.addPhotoFlag == true{
                  
                    print("恋こい")
                    if appDelegate?.noteFlag == true && appDelegate?.returnCamera == false{
                        self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        appDelegate?.addPhotoFlag = false
                        appDelegate?.noteFlag = true
                        appDelegate?.noPhotoButtonTaped = false
                        print("ウグイス")
                    }else if appDelegate?.noteFlag == false && appDelegate?.returnCamera == false{
                        
                        self.presentingViewController?.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        appDelegate?.addPhotoFlag = false
                        appDelegate?.noteFlag = false
                        print("たらお")
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
                                print("らんま")
                                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                
                            
                               }else{
                               appDelegate?.noteFlag = true
                               print("やぁ")
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
                            print("やす")
                        }
                        
                    }
                    
             
                
                }else{
                    
                    if appDelegate?.returnCamera == true{
                        
                        if appDelegate?.tabBarCamera == true{
                             print("ユキ")
                            self.appDelegate?.noteFlag = true
                            appDelegate?.returnCamera = false
                            appDelegate?.tabBarCamera = false
                            self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        
                     
                            
                        }else{
                        self.appDelegate?.noteFlag = true
                        appDelegate?.returnCamera = false
                        self.dismissViewControllerAnimated(true, completion: nil)
                        print("ここ")
                        }
                        
                    }else{
                        
                        self.appDelegate?.noteFlag = true
                        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        print("呼ばれない？")
                    }
                    
                }
                
                   self.appDelegate?.cameraViewFlag = false
                
        }else{
                
                //写真の追加ならば
                if self.appDelegate?.addPhotoFlag == true{
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.appDelegate?.addPhotoFlag = false
                    print("オドム")
                    
                }else{
                    //新規作成ノートであることを伝える。
                    self.appDelegate?.noteFlag = true
                    self.dismissViewControllerAnimated(true, completion: nil)
                    print("ランス")
                    
                }
                
                
            }
        
        print("通る")
        appDelegate?.tabBarCamera = false
        
     
        
        
    }
    
    func dataSave(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count > 0{
            path = paths[0]
        }
       
        let realm = try!Realm()
        let maxNote = realm.objects(Note).sorted("id", ascending: false)
        let note = Note()
        
        print("why")
        
        //写真の追加だったら
        if appDelegate?.addPhotoFlag == true{
            
            
            let editNoteIds:Int = (appDelegate?.editNoteId)!
            let editNote = realm.objects(Note).filter("id = \(editNoteIds)")
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            if paths.count > 0{
                
                path = paths[0]
                
            }else{
                //エラー処理
            }
            
            for ind in 0...selectPhots.count-1{
                
                filename = NSUUID().UUIDString + ".jpg"
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename!)
                let options = PHImageRequestOptions()
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                options.synchronous = true
                options.networkAccessAllowed = true
                
                let asset = selectPhots[ind]
                
                let manager = PHImageManager()
                manager.requestImageForAsset(asset, targetSize:CGSizeMake(self.view.bounds.size.width,360) , contentMode: .AspectFill, options: options, resultHandler: {(image,info)->Void in
                    
                    
                    
                    self.data = UIImageJPEGRepresentation(image!, 0.8)
                    if ((self.data?.writeToFile(filepath, atomically: true)) != nil){
                        
                        
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
                    }
                })
                
            }
            
            
            
        }else{
            //新規のノートの追加。
            
            if maxNote.isEmpty{
                note.id = 1
            }else{
                
                note.id = maxNote[0].id + 1
            }
            
            
            //元に戻し済み。大丈夫な状態。
            note.createDate = NSDate()
            
        
            /*
            let date:String = "2016-5-7 23:35:12"
            let dateformatter:NSDateFormatter = NSDateFormatter()
            dateformatter.locale = NSLocale(localeIdentifier: "ja")
            dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let changeDate = dateformatter.dateFromString(date)
            note.createDate = changeDate
            */
            
            
            try!realm.write({ () -> Void in
                
                realm.add(note, update: true)
                
            })
            
        
            
   
            //画像の保存先パスを取得
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            if paths.count > 0{
                path = paths[0]
            }else{
                
                //エラー処理
            }
            
            
            
            for ind in 0...selectPhots.count - 1{
                
                let options = PHImageRequestOptions()
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
                options.networkAccessAllowed = true
                options.synchronous = true
                
                
                let asset = selectPhots[ind]
                
                let manager = PHImageManager()
                manager.requestImageForAsset(asset, targetSize:CGSizeMake(self.view.bounds.size.width,360) , contentMode: .AspectFill, options: options, resultHandler: {(image,info)->Void in
                   
                    
                    self.data = UIImageJPEGRepresentation(image!, 0.8)
                    //ここに移動してみた！結果、問題は起きないけど、問題解決も出来なかった。
                     self.filename = NSUUID().UUIDString + ".jpg"
                    
                    let filepath = (self.path! as NSString).stringByAppendingPathComponent(self.filename!)
                    
                    if((self.data?.writeToFile(filepath, atomically: true)) != nil){
                        
                
                        
                        let maxPhoto = realm.objects(Photos).sorted("id", ascending: false)
                        
                        try!realm.write({ () -> Void in
                            
                            let photo = Photos()
                            
                            
                            if maxPhoto.isEmpty{
                                
                                photo.id = 1
                                
                            }else{
                                
                                photo.id = maxPhoto[0].id + 1
                                
                            }
                            
                            photo.createDate = NSDate()
                            photo.filename = self.filename!
                            
                            //選ばれた写真の最後の一枚ならば、
                            if ind == self.selectPhots.count - 1{
                                
                                note.photos.append(photo)
                            
                            }else{
                                
                                note.photos.append(photo)
                                
                            }
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("savePhoto", object: nil)
                        })
                        
                    
                        
                        
                    }
                    
                    
                })
                
            }
            
        }
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