//
//  TimerViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/20.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import SwiftyDropbox

class TimerViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var stopRestartButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerLabelMinute: UILabel!
    
    var player:AVAudioPlayer!
    
    var path:String?
    

    @IBOutlet weak var datePickerViewHeight: NSLayoutConstraint!
    
    

    @IBOutlet weak var timerLabelMinuteX: NSLayoutConstraint!
    
    @IBOutlet weak var timerLabelX: NSLayoutConstraint!
  //  @IBOutlet weak var timerLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var stopRestartButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var stopRestartButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var DoneButtonWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var DoneButtonHeight: NSLayoutConstraint!
    
    var myNotification:UILocalNotification!
    
    var countDownNow = false
    
    
    var countDowns:NSDate!
    var countDownsAtBackground:NSDate!
    
    var countUp = false
    
    
    var countDown:String?
    var countUps:String?
    var allCountUps:String?
    
    var appDelegate:AppDelegate?
    
    //タイマー
    var tmr:NSTimer?
    
    var times:String!
    
    //スタートしてからの経過秒
    var allTimeBySecond:Int!
    
    //バックグラウンドになった時間
    var backgroundDate:NSDate!
   
    var startTime:NSTimeInterval!
    
    var restartFlag = false
    var backGroundFlag = false
    
    let screenHight = Double(UIScreen.mainScreen().bounds.size.height)
    let screenWidth = Double(UIScreen.mainScreen().bounds.size.width)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(screenHight)
        switch screenHight{
        case 480:
            datePickerViewHeight.constant = 213
        case 568:
            datePickerViewHeight.constant = 250
        case 667:
            datePickerViewHeight.constant = 300
        case 736:
            datePickerViewHeight.constant = 350
        default:
            print("エラー")
        }
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        
        //自動ロックさせない
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        datePicker.locale = NSLocale(localeIdentifier: "ja_JP")
        datePicker.countDownDuration = 60.0
        
        //スタートボタン以外は押せない
        self.setButtonEnable(false, start: true, done: false)
        
        self.addNotification()
       
        //スタートしてからのしてから経過秒
        allTimeBySecond = 0
        
        timerLabel.hidden = true
        timerLabelMinute.hidden = true
        
        backgroundDate = nil
        
        resetButton.setTitle("リセット", forState: .Normal)
        resetButton.addTarget(self, action: "resetButtonTaped", forControlEvents: .TouchUpInside)
        resetButton.layer.masksToBounds = true
        resetButton.layer.cornerRadius = 35
        resetButton.backgroundColor = UIColor.grayColor()
        resetButton.tintColor = UIColor.whiteColor()
        
        stopRestartButton.addTarget(self, action: "stopRestartButtontaped", forControlEvents: .TouchUpInside)
        stopRestartButton.setTitle("スタート", forState: .Normal)
        stopRestartButtonHeight.constant = 90
        stopRestartButtonWidth.constant = 90
        stopRestartButton.layer.masksToBounds = true
        stopRestartButton.layer.cornerRadius = 45
        stopRestartButton.backgroundColor = UIColor(red: 0, green: 0.7098, blue: 0.8667, alpha: 1.0)
        stopRestartButton.tintColor = UIColor.whiteColor()
        
        doneButton.setTitle("完了", forState: .Normal)
        doneButton.addTarget(self, action: "doneButtonTaped", forControlEvents: .TouchUpInside)
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 35
        doneButton.backgroundColor = UIColor.grayColor()
        doneButton.tintColor = UIColor.whiteColor()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Timer")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    
    
    
    func setNotification(){
        
        myNotification = UILocalNotification()
        //メッセージを代入
        myNotification.alertBody = "時間です！！"
        myNotification.timeZone = NSTimeZone.defaultTimeZone()
        myNotification.soundName = UILocalNotificationDefaultSoundName
        
        let setTime:Double = Double(datePicker.countDownDuration) - Double(allTimeBySecond!)
        print("セットされた時間\(Double(datePicker.countDownDuration))")
        print("経過秒\(allTimeBySecond)")
        
        myNotification.fireDate = NSDate(timeIntervalSinceNow: setTime)
        UIApplication.sharedApplication().scheduleLocalNotification(myNotification)
    }
    
    

    
    func addNotification(){
        
        //通知の登録
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        //自動ロックされない状態を解除する
        UIApplication.sharedApplication().idleTimerDisabled = false
        
    }
    
    func didBecomeActive(){
        
        if myNotification != nil{
        UIApplication.sharedApplication().cancelLocalNotification(myNotification)
        }
        
        if let backgroundDates = backgroundDate {
            
            //バックグラウンドになった時間とフォアグラウンドに戻った時間の差分を取得
            let timeDiff = Double(NSDate().timeIntervalSinceDate(backgroundDates))
            
            //全体の経過時間にバックグラウンド中に経過した時間を加える
            allTimeBySecond = allTimeBySecond + Int(timeDiff)
            
            let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
            let unit:NSCalendarUnit = [NSCalendarUnit.Hour]
            let coms:NSDateComponents = (calendar?.components(unit, fromDate: backgroundDate!))!
            let dateFormatter:NSDateFormatter!
            
            //経過時間がセットした時間よりも長いならば
            if allTimeBySecond > Int(datePicker.countDownDuration){
                
                countUp = true
                
            }
            
            
            if countUp == true{
                
                let start = "00:00"
                
                dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "mm:ss"
                backGroundFlag = true
                
                let startDate = dateFormatter.dateFromString(start)
                
                let interval:NSTimeInterval = Double(allTimeBySecond) - Double(datePicker.countDownDuration)
                
                let dateFormatting = NSDateFormatter()
                
                if interval >= 3600{
                    
                    dateFormatting.dateFormat = "HH:mm:ss"
                    let time = NSDate(timeInterval:interval, sinceDate: startDate!)
                    times = dateFormatting.stringFromDate(time)
                    
                }else{
                    
                    dateFormatting.dateFormat = "mm:ss"
                    let time = NSDate(timeInterval:interval, sinceDate: startDate!)
                    times = dateFormatting.stringFromDate(time)
                    
                    
                }
                    
                
            }else{
            
                if coms.hour == 00{
                    let time = NSDate(timeInterval:-timeDiff , sinceDate: countDownsAtBackground)
                    let dateFomatter = NSDateFormatter()
                    dateFomatter.dateFormat = "mm:ss"
                    backGroundFlag = true
                    times = dateFomatter.stringFromDate(time)
                    
                }else{
                
                    let time = NSDate(timeInterval:-timeDiff , sinceDate: countDownsAtBackground)
                    let dateFomatter = NSDateFormatter()
                    dateFomatter.dateFormat = "HH:mm:ss"
                    backGroundFlag = true
                    times = dateFomatter.stringFromDate(time)
                }
            }
            backgroundDate = nil
            stopRestartButtontaped()
            
        }
        
    }
    
    func didEnterBackground(){
        
        if countDownNow == true {
        self.countDownsAtBackground = countDowns
        print("にチェ\(self.countDownsAtBackground)")
        tmr?.invalidate()
        countDownNow = false
        restartFlag = true
        backgroundDate = NSDate()
        
            //カウントダウンならばnotificationを設定
            if !countUp{

                setNotification()
            }
        }
        
    }
    
    func stopRestartButtontaped(){
        
        //すべてのボタンを押せるようにする
        setButtonEnable(true, start: true, done: true)
        
        //カウント中に押されたら、一時停止
        if countDownNow{
            
            tmr?.invalidate()
            stopRestartButton.setTitle("再開", forState: .Normal)
            countDownNow = false
            restartFlag = true
            
        }else{
            //スタートボタンを押されたら、タイマーを生成
            //一秒間間隔でtickTimerメソッドを呼ぶ。fire()はタイマー開始
            countDownNow = true
            
            datePicker.hidden = true
            
            if datePicker.countDownDuration >= 3600{
                timerLabel.hidden = false
                timerLabelMinute.hidden = true
            }else{
                
                timerLabelMinute.hidden = false
                timerLabel.hidden = true
            }
            
            
            stopRestartButton.setTitle("一時停止", forState: .Normal)
            stopRestartButtonHeight.constant = 70
            stopRestartButtonWidth.constant = 70
            stopRestartButton.layer.cornerRadius = 35
            stopRestartButton.backgroundColor = UIColor.grayColor()
            
            DoneButtonHeight.constant = 90
            DoneButtonWidth.constant = 90
            doneButton.layer.cornerRadius = 45
            doneButton.backgroundColor = UIColor(red: 0, green: 0.7098, blue: 0.8667, alpha: 1.0)
            
            var Hour:Double? = 00
            var MM:Double? = 00
            
            
            if restartFlag{
                
                if countUp{
                    
                    if backGroundFlag == true{
                
                        countUps = times
                        backGroundFlag = false
                        
                    }else{
                        
                        if timerLabel.text == "Label"{
                        
                            countUps = timerLabelMinute.text
                        
                        }else{
                            
                            countUps = timerLabel.text
                        }
                    }
                    
                }else{
                    
                    if backGroundFlag == true{
                        
                        countDown = times
                        backGroundFlag = false
                        
                    }else{
                        
                        if timerLabel.text == "Label"{
                        
                            countDown = timerLabelMinute.text
                        
                        }else{
                            
                            countDown = timerLabel.text
                        }
                    }
                
                }
                
            }else{
                
                  //設定されたタイムが一時間以上ならば
                  if Int(datePicker.countDownDuration) >= 3600  {
                
                         Hour = Double(Int(datePicker.countDownDuration)/3600)
                         MM = Double(Int((datePicker.countDownDuration)%3600)/60)
                    
                         let hh:Int = Int(Hour!)
                         let mm:Int = Int(MM!)
                         countDown = "\(hh):\(mm):00"
                
                    }else{
                
                         MM = Double(Int(datePicker.countDownDuration) / 60)
                         let mm:Int = Int(MM!)
                         countDown = "\(mm):00"
                
                    
                    }
          
                countUps = "00:00:00"
                allCountUps = "00:00:00"
                
            }
            
        print("初期値\(countDown)")
            tmr = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:"tickTimer" , userInfo: nil, repeats: true)
            tmr?.fire()
            
            
        }
        
        
    }
    
    func tickTimer(){
        
  
        allTimeBySecond!++
        print("作業時間\(allTimeBySecond)")
        
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        
        print("数\(countDown?.characters.count)")
        if countDown?.characters.count == 6 || countDown?.characters.count == 8  {
        
            dateFormatter.dateFormat = "HH:mm:ss"
        
        }else{
        
            dateFormatter.dateFormat = "mm:ss"
 
        }
        
        let dateFormat:NSDateFormatter = NSDateFormatter()
        if countUps?.characters.count == 6 || countUps?.characters.count == 8{
            
            dateFormat.dateFormat = "HH:mm:ss"
            
        }else{
            
            dateFormat.dateFormat = "mm:ss"
        }
        
        let allDateFormatter:NSDateFormatter = NSDateFormatter()
        allDateFormatter.dateFormat = "HH:mm:ss"
            
        //スタートボタンが押されて、タイマーが起動してからの時間を計る。
        let allStopWatchDate = allDateFormatter.dateFromString(allCountUps!)
        print("開始\(allStopWatchDate)")
        let allStopWatch = NSDate(timeInterval: 1, sinceDate: allStopWatchDate!)
        let allTime = allDateFormatter.stringFromDate(allStopWatch)
        
        allCountUps = allTime
        
        print("全体のタイム\(allTime)")
        
        //datePickerの時間を日付型に変換
        print(dateFormatter.dateFormat)
        print("どうした？\(countDown)")
        let countDownDate = dateFormatter.dateFromString(countDown!)
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let unit:NSCalendarUnit = [NSCalendarUnit.Hour,NSCalendarUnit.Minute,NSCalendarUnit.Second]
   
        
        //カウントダウン、カウントアップ
        if countUp{
            
            
            
            let countUpDate = dateFormat.dateFromString(countUps!)
            
             countDowns = NSDate(timeInterval: 1.0, sinceDate: countUpDate!)
            let coms:NSDateComponents = (calendar?.components(unit, fromDate:countDowns))!

            if coms.hour == 00{
                
                timerLabelMinute.text = String(format: "%02d:%02d", coms.minute,coms.second)
                timerLabelMinuteX.constant = CGFloat(screenWidth / Double(2))-100
         
                timerLabelMinute.font = UIFont(name: "AppleSDGothicNeo-Thin", size:74.0)
                timerLabelMinute.textColor = UIColor.redColor()
                print("タイムズ\(timerLabel.text)")
                countUps = String(format: "%02d:%02d",coms.minute,coms.second)
            }else{
                
                timerLabel.text = String(format: "%d:%02d:%02d",coms.hour,coms.minute,coms.second)
                timerLabelX.constant = CGFloat(screenWidth / Double(2))-120
           
                timerLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size:74.0)
                timerLabel.textColor = UIColor.redColor()
                countUps = String(format: "%02d:%02d:%02d",coms.hour,coms.minute,coms.second)

            }
            
            
            
            
        
            
        }else{
            
             countDowns = NSDate(timeInterval: -1.0, sinceDate: countDownDate!)
            print(countDownDate!)
            let coms:NSDateComponents = (calendar?.components(unit, fromDate:countDowns))!
           
            if coms.hour == 00{
            
                timerLabelMinute.text = String(format: "%02d:%02d", coms.minute,coms.second)
                timerLabelMinuteX.constant = CGFloat(screenWidth / Double(2))-100
    
                timerLabelMinute.font = UIFont(name: "AppleSDGothicNeo-Thin", size:74.0)
                countDown = String(format: "%02d:%02d", coms.minute,coms.second)
            }else{
             
                timerLabel.text = String(format: "%d:%02d:%02d",coms.hour,coms.minute,coms.second)
                 timerLabelX.constant = CGFloat(screenWidth / Double(2))-120
       
                timerLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size:74.0)
                
                countDown = String(format: "%02d:%02d:%02d",coms.hour,coms.minute,coms.second)
                
            }
            
            
        
        
        }
      
        if countDown == "00:00"{
        
            play("pastel color1.mp3")
    
            countDown = "0"
            countUp = true
            startTime = NSDate.timeIntervalSinceReferenceDate()
        
        }
        
      
        
        
    }
    
    func play(soundName:String){
        let soundPath = (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent(soundName)
        print(soundName)
        print(soundPath)
        //読み込んだファイルにパスをつける
        let url:NSURL = NSURL.fileURLWithPath(soundPath)
       
        //マナーモードでも音を出したい！！
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        try?audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try?audioSession.setActive(true)
        
        //playerに読み込んだmp3ファイルへのパスを設定する
        player = try!AVAudioPlayer(contentsOfURL: url)
        //音を即時に出す
        player.prepareToPlay()
        //音を再生
        player.play()

        
    }
    
    func doneButtonTaped(){
     
        tmr?.invalidate()
        
        timerLabelMinute.textColor = UIColor.blackColor()
        timerLabel.textColor = UIColor.blackColor()
       
        stopRestartButtonHeight.constant = 90
        stopRestartButtonWidth.constant = 90
        stopRestartButton.layer.cornerRadius = 45
        stopRestartButton.backgroundColor = UIColor(red: 0, green: 0.7098, blue: 0.8667, alpha: 1.0)
        
        DoneButtonHeight.constant = 70
        DoneButtonWidth.constant = 70
        doneButton.layer.cornerRadius = 35
        doneButton.backgroundColor = UIColor.grayColor()

        timerLabel.hidden = true
        timerLabelMinute.hidden = true
        datePicker.hidden = false
        countDownNow = false
        countUp = false
        restartFlag = false
        stopRestartButton.setTitle("スタート", forState: .Normal)
        setButtonEnable(false, start: true, done: false)
        
        let realm = try!Realm()
     
        let maxNote = realm.objects(Note).sorted("id", ascending: false)
        let note = Note()
        
        if maxNote.isEmpty{
            
            note.id = 1
            
        }else{
            
            note.id = maxNote[0].id + 1
            
        }
        
        note.createDate = NSDate()
        
        note.timerTime = allTimeBySecond
        
        try!realm.write({ () -> Void in
            print("ライト兄弟")
            realm.add(note, update: true)
        })
        
      
            //unlogin.realmにも保存.unlogin.realmいらないかもしれない仮説を検証する。
          /*  var config = Realm.Configuration()
            config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("unlogin").URLByAppendingPathExtension("realm").path
            print("よしお")

            let realms = try!Realm(configuration: config)
          print("よしお")
            let maxNotes = realms.objects(Note).sorted("id", ascending: false)
            let notes = Note()
            if maxNotes.isEmpty{
                notes.id = 1
            }else{
                notes.id = maxNotes[0].id + 1
            }
              print("よしお")
            notes.createDate = NSDate()
            notes.timerTime = allTimeBySecond
              print("よしお")
            try!realms.write({ () -> Void in
                realms.add(notes, update: true)
            })*/
            
        
        
        
        
        uploadDropbox()
        
        
        appDelegate?.noteFlag = true
        appDelegate?.timerFlag = true
        
        let vc:UINavigationController = self.tabBarController?.viewControllers![1] as! UINavigationController
        self.tabBarController?.selectedViewController = vc
        vc.popToRootViewControllerAnimated(false)
  
        vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: allTimeBySecond)
        allTimeBySecond = 0
        
    }
    
    func uploadDropbox(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count > 0{
            path = paths[0]
        }
        
        let documentURL = NSURL(fileURLWithPath: path!)
        let fileURL = documentURL.URLByAppendingPathComponent("default.realm")
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toNoteDetail"{
         
            let vc = segue.destinationViewController as! NoteDetailViewController
            vc.allTime = sender as? String
            
            
        }
        
        
    }
    
    func resetButtonTaped(){
    
       tmr?.invalidate()
       timerLabel.hidden = true
       timerLabelMinute.hidden = true
       datePicker.hidden = false
       countDownNow = false
       countUp = false
       restartFlag = false
        
        timerLabel.textColor = UIColor.blackColor()
        timerLabelMinute.textColor = UIColor.blackColor()
        
       stopRestartButtonHeight.constant = 90
       stopRestartButtonWidth.constant = 90
       stopRestartButton.layer.cornerRadius = 45
       stopRestartButton.backgroundColor = UIColor(red: 0, green: 0.7098, blue: 0.8667, alpha: 1.0)
        
       DoneButtonHeight.constant = 70
       DoneButtonWidth.constant = 70
       doneButton.layer.cornerRadius = 35
       doneButton.backgroundColor = UIColor.grayColor()

 
       stopRestartButton.setTitle("スタート", forState: .Normal)
       allTimeBySecond = 0
       setButtonEnable(false, start: true, done: false)
        
    }
    
    func setButtonEnable(reset:Bool,start:Bool,done:Bool){
        
        self.resetButton.enabled = reset
        self.stopRestartButton.enabled = start
        self.doneButton.enabled = done
        
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
