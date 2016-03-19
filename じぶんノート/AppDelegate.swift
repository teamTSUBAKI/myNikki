//
//  AppDelegate.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/10.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import Photos
import Fabric
import Crashlytics
import SwiftyDropbox
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //取得した写真を入れる配列
    var photosAssets = [PHAsset]()
    
    var textData:String?
    
    //タブバーから直接立ち上げたカメラか？
    var tabBarCamera:Bool?
    
    //カメラ経由かどうかを判定
    var textOrCameraFlag:Bool?
    
    //noPhotoButton経由の場合
    var noPhotoButtonTaped:Bool?
    
    //アルバム経由かどうか
    var albumFlag:Bool?
    
    //アルバム→カメラ→アルバム
    var returnCamera:Bool = false
    
    //タイマー経由
    var timerFlag:Bool?
    
    //タイムラインとノート作成画面からの遷移を判定
    var noteFlag:Bool?
    //noteDetailからphotoDetailに渡す
    var detailPhoto:UIImage?
    var detailPhotoId = 0
    
    //カメラ経由かどうかを判定
    var cameraViewFlag:Bool?
    //写真の追加であることを知らせる。
    var addPhotoFlag:Bool?
    //編集したいノートのid
    var editNoteId:Int?
    //編集したノートのNSdate
    var editNoteDate:NSDate?
    //ノートの写真枚数
    var photosCount = 0
    //新規作成→キャンセルからの写真やコメント追加
    var cancelAdd:Bool?
    
    //noteDetailからタイムラインに戻るボタンを押した場合
    var noteReturn:Bool?
    
    //PDFメールの件名用の日付データ入れ
    var dateForPDF:String!
    
    //PDFの名前入れ：共有用
    var nameOfPDF:String!
    
    //PDFメール添付用
    var nameOfPDFForMail:String!
    
    //ノートディテイルで、メール添付用に写真を配列に入れる
    var Photoes:List<Photos>!
    
    //ノートディテールのテキストビューを押したフラグ
    var textViewOfNoteDetail:Bool?
    
    
    

    //初回起動時に呼ばれる
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        Dropbox.setupWithAppKey("zhyddhnllulwogy")
        
        
        Fabric.with([Crashlytics.self])
        
        
        //グーグルアナリティクス
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil,"Error congiguring Google services:\(configureError)")
        
        var gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.logger.logLevel = GAILogLevel.Verbose
        
        
        //Dropboxにログイン済みなら
        print(Dropbox.authorizedClient)
        if (Dropbox.authorizedClient != nil){
            
            
            let dic = ["firstAfterDropBoxLogin":true]
            userDefaults.registerDefaults(dic)
            
            //ログインしてから一回目なら。
            if userDefaults.boolForKey("firstAfterDropBoxLogin"){
                print("ログイン")
                //dropboxへすべての写真、default.realmをバックアップ
                self.downLoadFromDropbox()
              
            }
            //uploadrealm的なメソッドを使って、すぐに上書きするのはどうだろう。
            
        }

        
        
        //UserDefaultsにtrueを保存
        let dic = ["firstLunch":true]
        userDefaults.registerDefaults(dic)
        

        let storyBorad = UIStoryboard(name: "Main", bundle: nil)
        var viewController = UIViewController()
        
        if userDefaults.boolForKey("firstLunch"){
            
             viewController = storyBorad.instantiateViewControllerWithIdentifier("WalkTrough") as!
                 WalkTroughViewController
            
            
        }else{
            
             viewController = storyBorad.instantiateViewControllerWithIdentifier("navi1")
            // userDefaults.setBool(true, forKey: "firstLunch")
        }
        
        self.window?.rootViewController = viewController
        //self.window?.makeKeyAndVisible()
        
        let UIUserNotification:UIUserNotificationType = [UIUserNotificationType.Alert,UIUserNotificationType.Sound]
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotification, categories: nil))
        
        return true
    }
    
    
    //ドロップボックスからserver.realmファイルと写真をダウンロード。
    func downLoadFromDropbox(){
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        //ログインしているか
        if let client = Dropbox.authorizedClient{
            
            //ダウンロード先のURLを設定。server.realmファイルをDocumentにダウンロード
            let destination:(NSURL,NSHTTPURLResponse) -> NSURL = {temporaryURL,response in
                
                let directoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains:
                    .UserDomainMask)[0]
                let pathComponent = "server.realm"
                return directoryURL.URLByAppendingPathComponent(pathComponent)
            }
            
            let documentDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let file = "default.realm"
            let fileName = "server.realm"
            let fileNames = "merged.realm"
            
            let server = (documentDirPath as NSString).stringByAppendingPathComponent("server.realm")
               
            if NSFileManager.defaultManager().fileExistsAtPath(server){
                
                do{
                try NSFileManager.defaultManager().removeItemAtPath("\(documentDirPath)/\(fileName)")
                }catch{
                    print("エラーよ")
                }
            }
            
            client.files.download(path: "/default.realm", destination: destination).response({ (response, error) -> Void in
                
                if let (metadata,url) = response{
                    
                    print("download \(metadata.name)")
                    print("ダウンロード１")
                    
                    //default.realm（未ログイン時のデータ)をserver.realmにコピーしたい
                    
                    var config = Realm.Configuration()
                    config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default").URLByAppendingPathExtension("realm").path
                    
                    
                    let realm = try!Realm(configuration: config)
                    let realmNote = realm.objects(Note)
                    
                    //defaultの一番大きいIDを取り出す
                    let realmsNote = realm.objects(Note).sorted("id", ascending: false)
                   
                    let realmsNoteMaxDate:NSDate?
                    if realmsNote.isEmpty != true{
                     
                        realmsNoteMaxDate = realmsNote[0].createDate
                        
                    }else{
                        
                         realmsNoteMaxDate = NSDate()
                        
                    }
                    var configs = Realm.Configuration()
                    configs.path = NSURL.fileURLWithPath(configs.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("server").URLByAppendingPathExtension("realm").path
                    
                    
                    
                    do{
                        let realms = try Realm(configuration: configs)
                        
                        let maxNote = try realms.objects(Note).sorted("id", ascending: false)[0]
                        let maxId = maxNote.id
                        let maxNoteDate = maxNote.createDate
                        
                        print("マックス\(maxId)")
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
                            let maxPhoto = realms.objects(Photos).sorted("id", ascending: false)[0]
                            let maxPhotoID = maxPhoto.id
                            
                            //すべて写真を一気に入れるのではなくて、ノートごとに取り出して、入れていけばいいのではないか。
                            for photo in note.photos{
                                
                                let phot = Photos()
                                
                                phot.id = maxPhotoID + photo.id
                                phot.createDate = photo.createDate
                                phot.filename = photo.filename
                                
                                try realms.write({ () -> Void in
                                    
                                    not.photos.append(phot)
                                    
                                })
                                
                            }
                            
                            print("フレッシュ")
                          
                            
                            try realms.write({ () -> Void in
                                realms.add(not, update: true)
                                
                        
                            })
                            
                        }
                        
                        
                        
                        
                    
                    }catch{
                        
                        print("エラー")
                    }
                    
                    
                    
                    //上記のコードで、ドロップボックスからDocumenetDirectoryにdefault.realmをdefaults.realmという名前でダウンロード(同じ名前だとダウンロードできないため)し、もともとあったdefault.realmをdefaults.realmにコピーした。ここでdefault.realmを削除して、defaults.realmをdefault.realmに名前変更したい。
                    
                    
                    print("ダウンロード２")
                    if NSFileManager.defaultManager().fileExistsAtPath("\(documentDirPath)/\(fileName)") && NSFileManager.defaultManager().fileExistsAtPath("\(documentDirPath)/\(file)"){
                  
                  
                        //merged.realmがすでにあったら削除すればいいか。
                        do{
                            try NSFileManager.defaultManager().removeItemAtPath("\(documentDirPath)/\(fileNames)")
                        }catch{
                            print("エラーず")
                        }
                        
                        //server.realmをmerged.realmに名前変更
                        do{
                            try NSFileManager.defaultManager().moveItemAtPath("\(documentDirPath)/\(fileName)", toPath: "\(documentDirPath)/\(fileNames)")
                            
                            //merged.realmをアップロード
                            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                            var path = ""
                            if paths.count > 0{
                                
                                path = paths[0]
                                
                            }
                            
                            
                            let documetURL = NSURL(fileURLWithPath:path)
                            let fileURL:NSURL!
                            
                            //default.realmがあるならば
                            if NSFileManager.defaultManager().fileExistsAtPath("\(path)/\(file)"){
                                
                                fileURL = documetURL.URLByAppendingPathComponent("default.realm")
                                print("ローカル")
                            }else{
                                
                                fileURL = documetURL.URLByAppendingPathComponent("merged.realm")
                                print("まーじ")
                            }
                            
                            client.files.upload(path: "/default.realm", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, body: fileURL).response({ (response, error) -> Void in
                                
                                if let metadata = response{
                                    print("uploaded file \(metadata)")
                                    print("いやっほ−")
                                    self.uploadToDropBox()
                                    
                                }else{
                                    print("エラー\(error!)")
                                }
                                
                            })
                            

                            
                            
                            var configes = Realm.Configuration()
                            configes.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default").URLByAppendingPathExtension("realm").path
                            
                            
                            let realmss = try!Realm(configuration: configes)
                            let Photo = realmss.objects(Photos)
                            print("写真１\(Photo)")
                            for photo in Photo{
                                
                                let filename = photo.filename
                                
                                //ダウンロード先のURLを設定
                                let destination:(NSURL,NSHTTPURLResponse) -> NSURL = {temporaryURL,respomse in
                                    
                                    let directoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                                    let pathComponent = "\(filename)"
                                    return directoryURL.URLByAppendingPathComponent(pathComponent)
                                    
                                }
                                
                                
                                if let client = Dropbox.authorizedClient{
                                    
                                    client.files.download(path: "/\(filename)", destination: destination).response({ (response, error) -> Void in
                                        
                                        print("写真ダウンロード")
                                        if let metadata = response{
                                            print("download \(metadata)")
                                        }else{
                                            print(error)
                                        }
                                        
                                    })
                                 
                                    //ローカルファイルを消す
                                    do{
                                        print("できた")
                                        try NSFileManager.defaultManager().removeItemAtPath("\(documentDirPath)/\(file)")
                                    }catch{
                                        print("エラー")
                                        
                                    }
                                    
                                }
                                
                            }
                            

                            print("チェリー")
                            
                            
                            
                            

                        }catch{
                            
                            print("エラー２")
                            
                        }
                        
                        

                        
                        userDefaults.setBool(true, forKey: "downloadRealmFile")
                        print("エレガンス")
                    }
                    
                    print("ムッシュー")
                    
                    
                    
                    
                }else{
                    
                print("エラリスト\(error)")
                    self.uploadToDropBox()
                
                }
                
                
                
            })
            
            
            
            
        }
        
        
    }
    
    
    
    //ドロップボックスに既存の写真、データをアップロードする
    func uploadToDropBox(){
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        print("やぁねー")
        
        let Paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        var path = ""
        if Paths.count > 0{
            
            path = Paths[0]
            
        }
        
        let documetURL = NSURL(fileURLWithPath:path)
        
        
        //その時のdefault.realmをアップロード
        let defaultFile = (path as NSString).stringByAppendingPathComponent("default.realm")
        let fileURL:NSURL!
        if NSFileManager.defaultManager().fileExistsAtPath(defaultFile){
            
            fileURL = documetURL.URLByAppendingPathComponent("default.realm")
        }else{
            fileURL = documetURL.URLByAppendingPathComponent("merged.realm")
        }
        
        if let client = Dropbox.authorizedClient{
            client.files.upload(path: "/default.realm", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, body: fileURL).response({ (response, error) -> Void in
                
                if let metadata = response{
                    
                    print("メリークリスマス")
                    print("\(metadata)")
                    
                    //一番最初にログインした時に、defaultをmergeに変えちゃう
                    if NSFileManager.defaultManager().fileExistsAtPath("\(path)/default.realm"){
                        do{
                            try NSFileManager.defaultManager().moveItemAtPath("\(path)/default.realm", toPath:"\(path)/merged.realm")
                        }catch{
                            
                            print("エラー")
                            
                        }
                    }
                    
                    
                }else{
                    print("ここで\(error)")
                    
                }
                
            })
            
            
        }
        
        //写真データをバックアップ。
        
        var config:Realm.Configuration!
        
        
        if NSFileManager.defaultManager().fileExistsAtPath(defaultFile){
            
            config = Realm.Configuration()
            config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default").URLByAppendingPathExtension("realm").path
 
        }else{
            
            
            config = Realm.Configuration()
            config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("merged").URLByAppendingPathExtension("realm").path
            
        }
        
        
        let realm = try!Realm(configuration: config)
        let photos = realm.objects(Photos)
        
        print("写真２\(photos)")
        print("イノセントワールド")
        for  photo in photos{
            
            let filename = photo.filename
            let fileURLs = documetURL.URLByAppendingPathComponent(filename)
            print("生活")
            if let client = Dropbox.authorizedClient{
                client.files.upload(path: "/\(filename)", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, body: fileURLs).response({ (response,error) -> Void in
                    print("生")
                    if let metaData = response{
                        print("uploaded file \(metaData)")
                    }else{
                        print(error!)
                    }
                    
                })
                
            }
            
            
        }
        
        
       
    
        userDefaults.setBool(false, forKey: "firstAfterDropBoxLogin")
            
        
        
    }
    
    

    
    
    
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if let authResult = Dropbox.handleRedirectURL(url){
            switch authResult {
                case .Success(let token):
                 print("Sucess! User is logged into Dropbox with token: \(token)")
                 
                 NSNotificationCenter.defaultCenter().postNotificationName("login", object: nil)
           
                 let userDefaults = NSUserDefaults.standardUserDefaults()
                 if (Dropbox.authorizedClient != nil){
                    
                    let dic = ["firstAfterDropBoxLogin":true]
                    userDefaults.registerDefaults(dic)
                    
               
                    
                    //ログインしてから一回目なら。
                    if userDefaults.boolForKey("firstAfterDropBoxLogin"){
                        print("ログイン")
                        //dropboxへすべての写真、default.realmをバックアップ
                        if let client = Dropbox.authorizedClient{
                            client.files.listFolder(path: "").response({ (response, error) -> Void in
                                if let metadata = response{
                                    
                                    print("データあります")
                                }else{
                                    
                                    print("ありません")
                                }
                                
                                
                            })
                            
                        }
                        
                        self.downLoadFromDropbox()
                    
                        
                        
                        
                        
                        
                    }
                    //uploadrealm的なメソッドを使って、すぐに上書きするのはどうだろう。
                    
                }

                
                case .Error(let error,let description):
                 print("Error\(error):\(description)")
                
            }
            
            
        }
        
        return false
        
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

