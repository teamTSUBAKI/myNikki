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
    
    //アルバムから来た時のフラグ
    var albumFrag:Bool!
    
    //アルバムで表示中の年月を保存
    var nowYear:Int!
    var nowMonth:Int!
    
    //カレンダーで表示中の年月を保存
    var nowYearsForCal:Int!
    var nowMonthsForCal:Int!
    
    
    
    

    //初回起動時に呼ばれる
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        if let options = launchOptions{
            
            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification{
                
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                
            }
            
        }
     
     
        //レルムのデータファイルを削除。要注意。
       /* if let p = Realm.Configuration.defaultConfiguration.path{
            try?NSFileManager.defaultManager().removeItemAtPath(p)
        }*/
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        //開発中のためFablicを一度止める
         Fabric.with([Crashlytics.self])
        
        //クラッシュさせるコード。必ず、コメントアウトか、消す。ここ以外には一切書いてない
        //Crashlytics.sharedInstance().crash()
        
        //グーグルアナリティクス
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil,"Error congiguring Google services:\(configureError)")
        
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.logger.logLevel = GAILogLevel.Verbose
        
        //これをコメントアウトすることで、アナリティクスが起動する。
       // gai.dryRun = true
        
        
        //UserDefaultsにtrueを保存
        let dic = ["firstLunch":true]
        userDefaults.registerDefaults(dic)
        

        let storyBorad = UIStoryboard(name: "Main", bundle: nil)
        var viewController = UIViewController()
        
        if userDefaults.boolForKey("firstLunch"){
            
             viewController = storyBorad.instantiateViewControllerWithIdentifier("WalkTrough") as!
                 WalkTroughViewController
            
            print("ゆいこはん")
            
            
        }else{
            
             viewController = storyBorad.instantiateViewControllerWithIdentifier("navi1")
            // userDefaults.setBool(true, forKey: "firstLunch")
        }
        
        self.window?.rootViewController = viewController
        //self.window?.makeKeyAndVisible()
        
      
    
        return true
    }
    
    
    
    
   
    
    
    
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
              
        return false
        
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        if remind.isEmpty != true {
        
            if remind[0].repitition == 1{
            
                scheduledLocalNotification()
            }else{
                
                UIApplication.sharedApplication().cancelAllLocalNotifications()
            }
        }
        
    }
    
    //毎日のお知らせのローカル通知を設定
    func scheduledLocalNotification(){
        
        //まずは一度通知をキャンセルする
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //通知を設定する
        
        let notification:UILocalNotification = UILocalNotification()
        notification.alertAction = "アプリに戻る"
        //後で、ランダムにするように設定する。
        notification.alertBody = "じぶん日記に今の気持ちや出来事を書いてみて！"
        notification.timeZone = NSTimeZone.defaultTimeZone()
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        let now = NSDate()
        
        let calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute]
        let nowComps = calendar?.components(unit, fromDate: now)
        print("realmのデータ\(remind[0].Time)")
        let remindComps = calendar?.components(unit, fromDate: remind[0].Time!)
        
        
        nowComps?.calendar = calendar
    
        nowComps?.hour = (remindComps?.hour)!
        nowComps?.minute = (remindComps?.minute)!
        
        print("時間\(nowComps?.hour)")
     
    
        
        //設定したreminDateが今よりも前ならば、
        if now.compare((nowComps?.date)!) != .OrderedAscending{
            
            //設定したリマインドがすでに過ぎていたら、1日加える。
            nowComps!.day += 1
            
        }
    
        let remindsDate = nowComps?.date
        
        print("リマインず\(remindsDate)")
        notification.fireDate = remindsDate
        
        //notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        
        notification.soundName = "bgm_coinin_2.mp3"
        notification.repeatInterval = .Day
        
        notification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
 

            
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
     
          application.applicationIconBadgeNumber = 0
        
          UIApplication.sharedApplication().cancelLocalNotification(notification)
     
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

