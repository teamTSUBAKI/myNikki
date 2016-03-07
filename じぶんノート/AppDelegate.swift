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

    //初回起動時に呼ばれる
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        Dropbox.setupWithAppKey("zhyddhnllulwogy")
        
        
        Fabric.with([Crashlytics.self])
        
        
        //グーグルアナリティクス
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil,"Error congiguring Google services:\(configureError)")
        
        var gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.logger.logLevel = GAILogLevel.Verbose
        
        
        //UserDefaultsにtrueを保存
        let userDefaults = NSUserDefaults.standardUserDefaults()
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
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if let authResult = Dropbox.handleRedirectURL(url){
            switch authResult {
                case .Success(let token):
                 print("Sucess! User is logged into Dropbox with token: \(token)")
           
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

