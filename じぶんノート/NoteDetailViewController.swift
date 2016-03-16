//
//  NoteDetailViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/01.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift
import Photos
import Fabric
import Crashlytics
import SwiftyDropbox


class NoteDetailViewController: UIViewController,UITextViewDelegate{
    
    var path:String?
    var asset:PHFetchResult!
    
    let userDefault = NSUserDefaults()
    
    //共有などを行うためのボタン
    var shareButton:UIButton!
    
    @IBOutlet weak var topImage: UIImageView!
    
    @IBOutlet weak var noImagePhotoButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var allViewContainerConst: NSLayoutConstraint!
    @IBOutlet weak var textViewContainerConst: NSLayoutConstraint!
    @IBOutlet weak var textViewConst: NSLayoutConstraint!
    @IBOutlet weak var textButtonConst: NSLayoutConstraint!
    
    @IBOutlet weak var timerLabels: UILabel!
    @IBOutlet weak var timerLabelWidth: NSLayoutConstraint!
    
    @IBOutlet weak var nonImageView1: UIImageView!
    @IBOutlet weak var nonImageView2: UIImageView!
    @IBOutlet weak var nonImageView3: UIImageView!
    @IBOutlet weak var nonImageView4: UIImageView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var toPhotoDetailButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewContainer: UIView!
    
    @IBOutlet weak var textButton: UIButton!
    
    
    @IBOutlet weak var allViewContainer: UIView!
    
    @IBOutlet weak var topImageViewContainerHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var topImageViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewY: NSLayoutConstraint!
    
    
    
    
    
    @IBOutlet weak var noImagePhotoButton: UIButton!
    
    var presentTopImage = 0
    
    var note:Results<(Note)>?
    var Notes:Results<(Note)>?
    
    //タイムラインから選択されたセルのデータが入るプロパティ
    //default.realmのデータ
    var notes:Note?
    //unLogin.realmのデータ
    var unLoginNote:Note?
    
    var appDelegate:AppDelegate?
    
    //タイマーでの計測結果
    var allTime:String?
    
    
    var DateLabels:UILabel!
    var minutesAndHoursLabels:UILabel!
    
    let headerAttributes = [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    let bodyAttributes = [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    
    let screenWidth = Double(UIScreen.mainScreen().bounds.size.width)
    let screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //メール添付用にシェアモーダルに送る写真入れ
        appDelegate?.Photoes = nil
        
        self.textView.delegate = self
        
        print("タイマーの結果\(allTime)")
        

        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        appDelegate?.photosCount = 0
        
        let tabview = UIView(frame: (self.tabBarController?.tabBar.frame)!)
        tabview.backgroundColor = UIColor.blackColor()
        self.view.addSubview(tabview)
        
        
        let navigationRightButton = UIBarButtonItem(title: "写真追加", style: .Plain, target: self, action: "addPhotoButtonTaped")
        self.navigationItem.rightBarButtonItem = navigationRightButton
        
        
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.view.subviews[2].hidden = true
        
        view1.backgroundColor = colorFromRGB.colorWithHexString("d3d3d3")
        view2.backgroundColor = colorFromRGB.colorWithHexString("d3d3d3")
        view3.backgroundColor = colorFromRGB.colorWithHexString("d3d3d3")
        view4.backgroundColor = colorFromRGB.colorWithHexString("d3d3d3")
        
        nonImageView1.image = UIImage(named: "Stack of Photos-26")
        nonImageView2.image = UIImage(named: "Stack of Photos-26")
        nonImageView3.image = UIImage(named: "Stack of Photos-26")
        nonImageView4.image = UIImage(named: "Stack of Photos-26")
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count > 0{
            
            path = paths[0]
            
        }
        
        self.photoSet()
        //textviewの一行目を太字にしたい
        self.hightFirstLineInTextView(self.textView)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.view.subviews[2].hidden = true
        self.textView.textContainerInset = UIEdgeInsetsMake(18, 8, 0, 8)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName,value: "NoteDetail")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        //とりあえず最初は隠しておいて、状況に応じて表示する
        noImagePhotoButton.hidden = true
        timerLabels.hidden = true
        
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        let sizeThatShouldFitTheConst = textView.sizeThatFits(textView.frame.size)
        textViewContainerConst.constant = sizeThatShouldFitTheConst.height+60
        textViewConst.constant = sizeThatShouldFitTheConst.height+60
        textButtonConst.constant = sizeThatShouldFitTheConst.height+60
        allViewContainerConst.constant = (topImageViewContainerHeight.constant - 50) + sizeThatShouldFitTheConst.height+60
    }
    
    override func viewDidAppear(animated: Bool) {
        
        print("呼ばれる")
        
        self.photoSet()
        self.hightFirstLineInTextView(textView)
 
        
    }
    //一行目を太字にしたい
    func hightFirstLineInTextView(textViews:UITextView){
        let textAsNSString = textViews.text as NSString
        let lineBreakRange = textAsNSString.rangeOfString("\n")
        
        let newAttributedText = NSMutableAttributedString(attributedString: textViews.attributedText)
        let boldRange:NSRange!
        if lineBreakRange.location < textAsNSString.length{
            boldRange = NSRange(location: 0, length: lineBreakRange.location)
        }else{
            
            boldRange = NSRange(location: 0, length: textAsNSString.length)
            
        }
        
        let Font:UIFont = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)!
        newAttributedText.addAttribute(NSFontAttributeName, value: Font, range: boldRange)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 15
        newAttributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: boldRange)
        
        textViews.attributedText = newAttributedText
        
    }
    
    func getAllPhotos(){
        
        
        print("写真を入れたよ")
        
        
        appDelegate?.photosAssets = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        asset = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        asset?.enumerateObjectsUsingBlock({(asset,index,stop) -> Void in
            
            self.appDelegate?.photosAssets.append(asset as! PHAsset)
            
        })
        
        
    }

    
    
    func addPhotoButtonTaped(){
        
        self.getAllPhotos()
        
        //新規ノートの場合
        if appDelegate?.noteFlag == true{
            
            
            let realm = try!Realm()
            let note = realm.objects(Note).sorted("id", ascending: false)
            
            //ノートidを渡す
            appDelegate?.addPhotoFlag = true
            appDelegate?.editNoteId = note[0].id
            
            //appdelegateで写真選択画面に写真数を伝える。
            appDelegate?.photosCount = note[0].photos.count
            
            let PhotosAlbum = self.storyboard?.instantiateViewControllerWithIdentifier("photos")
            let navigation = UINavigationController()
            navigation.viewControllers = [PhotosAlbum!]
            self.presentViewController(navigation, animated: true, completion: nil)
            
        }else if appDelegate?.noteFlag == false{
            
            //ノートidを渡す。
            //追加であることを知らせる
            appDelegate?.addPhotoFlag = true
            appDelegate?.editNoteId = notes?.id
            
            print("愛")
            let realm = try!Realm()
            let Notes = realm.objects(Note).filter("id = \(notes!.id)")
            
            print("写真の数を送信\(Notes[0].photos.count)")
            appDelegate?.photosCount = Notes[0].photos.count
            print("写真の数を送信なんだよ\(appDelegate?.photosCount)")
            
            
            let PhotosAlbum = self.storyboard?.instantiateViewControllerWithIdentifier("photos")
            let navigation = UINavigationController()
            navigation.viewControllers = [PhotosAlbum!]
            self.presentViewController(navigation, animated: true, completion: nil)
            
        }else{
            
            appDelegate?.addPhotoFlag = false
            
            let photosAlbum = self.storyboard?.instantiateViewControllerWithIdentifier("photos")
            let navigation = UINavigationController()
            navigation.viewControllers = [photosAlbum!]
            self.presentViewController(navigation, animated: true, completion: nil)
        }
        
        
    }
    
    func photoSet(){
        
        //遷移元が新規ノート作成画面の時
        print("ノートフラグ\(appDelegate?.noteFlag)")
        if appDelegate?.noteFlag == true{
            
            //最後のデータをrealmから取り出して表示
            if userDefault.boolForKey("downloadRealmFile"){
                var config = Realm.Configuration()
                config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("merged").URLByAppendingPathExtension("realm").path
                
            let realm = try!Realm(configuration: config)
            note = realm.objects(Note).sorted("id", ascending: false)
            }else{
                var config = Realm.Configuration()
                
                config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("local").URLByAppendingPathExtension("realm").path
                
                let realm = try!Realm(configuration: config)
                note = realm.objects(Note).sorted("id", ascending: false)
                
                
            }
            
            if note![0].photos.count == 0{
                
                self.imageViewY.constant = 150
                self.topImageViewContainerHeight.constant = 250
                
                self.topImageViewHeight.constant = 0
                self.imageViewHeight.constant = 0
                
                
                toPhotoDetailButton.hidden = true
                noImagePhotoButton.hidden = false
                
                print("よ")
                
            }else{
                
                
                self.imageSize()
                
                toPhotoDetailButton.hidden = false
                noImagePhotoButton.hidden = true
                
                //メール添付用にシェアモーダルに送る
                appDelegate?.Photoes = note![0].photos
        
                for ind in 1...4{
                    
                    if ind == 1{
                        let filenames = note![0].photos[0].filename
                        let filepaths = (path! as NSString).stringByAppendingPathComponent(filenames)
                        let images = UIImage(contentsOfFile: filepaths)
                        topImage.image = images
                        
                        presentTopImage = note![0].photos[0].id
                    }
                    
                   
                    
                    if ind <= note![0].photos.count{
                        let imageView:UIImageView = self.view.viewWithTag(ind) as! UIImageView
                        let filenames = note![0].photos[ind-1].filename
                        let filepaths = (path! as NSString).stringByAppendingPathComponent(filenames)
                        let images = UIImage(contentsOfFile: filepaths)
                        imageView.image = images
                        
                    }else{
                        let imageView:UIImageView = self.view.viewWithTag(ind) as! UIImageView
                        imageView.image = nil
                        
                    }
                }
                
                
            }
            
            if note![0].noteText.isEmpty{
                
                textView.text = "練習メニューやメモを書く．．．"
                textView.textColor = UIColor.grayColor()
                
            }else{
                
                textView.text = note![0].noteText
                
                
                
            }
            
            let weekDays = ["","日曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日"]
            let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute,NSCalendarUnit.Weekday]
            let comps:NSDateComponents = calendar.components(unit, fromDate: note![0].createDate!)
            
            DateLabels = UILabel(frame: CGRectMake(0,0,170,44))
            DateLabels.text = "\(comps.year)年\(comps.month)月\(comps.day)日\(weekDays[comps.weekday])"
            DateLabels.textColor = UIColor.whiteColor()
            DateLabels.textAlignment = NSTextAlignment.Center
            DateLabels.center = CGPointMake(self.view.bounds.width/2-30, 20)
            self.view.subviews[3].addSubview(DateLabels)
            
            shareButton = UIButton(frame: CGRectMake(0,0,44,44))
            shareButton.setImage(UIImage(named:"Upload-50"), forState: .Normal)
            shareButton.addTarget(self, action: "sharedButtonTaped", forControlEvents: .TouchUpInside)
            shareButton.center = CGPointMake(self.view.bounds.width - 30, 20)
            self.view.subviews[3].addSubview(shareButton)


            
            let minute = comps.minute.description
            if minute.characters.count == 1{
                
                minutesAndHoursLabels = UILabel(frame: CGRectMake(0,0,100,44))
                minutesAndHoursLabels.center = CGPointMake(self.view.bounds.width/2+80,20)
                minutesAndHoursLabels.textAlignment = NSTextAlignment.Center
                minutesAndHoursLabels.text = "\(comps.hour):0\(comps.minute)"
                minutesAndHoursLabels.textColor = UIColor.whiteColor()
                self.view.subviews[3].addSubview(minutesAndHoursLabels)
                
            }else{
                
                minutesAndHoursLabels = UILabel(frame: CGRectMake(0,0,80,44))
                minutesAndHoursLabels.center = CGPointMake(self.view.bounds.width/2+80,20)
                minutesAndHoursLabels.textAlignment = NSTextAlignment.Center
                minutesAndHoursLabels.text = "\(comps.hour):\(comps.minute)"
                minutesAndHoursLabels.textColor = UIColor.whiteColor()
                
                self.view.subviews[3].addSubview(minutesAndHoursLabels)

                
            }
            
            self.navigationItem.title = "\(comps.year)/\(comps.month)/\(comps.day)"
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
            self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        
            //PDFメール用に日付データを入れる
            appDelegate?.dateForPDF = self.navigationItem.title
            
            var myTimes = note![0].timerTime
            let myTimers = note![0].timerTime
            
            let hours = myTimes / 3600
            myTimes -= hours * 3600
            
            let minutes = myTimes / 60
            myTimes -= minutes * 60
            
            let seconds = myTimes
            
            
            
            if myTimers >= 3600{
                
                timerLabels.hidden = false
                timerLabels.textColor = UIColor.whiteColor()
                timerLabels.text = "タイム：\(hours)時間\(minutes)分\(seconds)秒"
                timerLabels.backgroundColor = colorFromRGB.colorWithHexString("87CEEB")
                timerLabelWidth.constant = 160
                timerLabels.layer.masksToBounds = true
                timerLabels.layer.cornerRadius = 5

                
            }else if myTimers >= 1{
                
                timerLabels.hidden = false
                timerLabels.textColor = UIColor.whiteColor()
                timerLabels.text = "タイム：\(minutes)分\(seconds)秒"
                timerLabels.backgroundColor = colorFromRGB.colorWithHexString("87CEEB")
                timerLabelWidth.constant = 130
                timerLabels.layer.masksToBounds = true
                timerLabels.layer.cornerRadius = 5

            
            }else if myTimers == 0{
                
                timerLabels.hidden = true
                
            }
            
            
            
            
            
        }else if self.appDelegate?.noteFlag == false{
            //遷移元がタイムラインの時
            print("タムライン")
            
            let realm:Realm!
            if userDefault.boolForKey("downloadRealmFile"){
                var config = Realm.Configuration()
                config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("merged").URLByAppendingPathExtension("realm").path
                
                
                realm = try!Realm(configuration: config)
            
            }else{
                
                var config = Realm.Configuration()
                config.path = NSURL.fileURLWithPath(config.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("local").URLByAppendingPathExtension("realm").path
                
                
                realm = try!Realm(configuration: config)
                
            }
            
            print("ノートのid\(notes?.id)")
           
            
            Notes = realm.objects(Note).filter("id = \(notes!.id)")
            
            if ((Notes![0].photos.count) == 0){
                
                self.imageViewY.constant = 0
                self.topImageViewHeight.constant = 0
                self.topImageViewContainerHeight.constant = 0
                self.imageViewHeight.constant = 0
                noImagePhotoButton.hidden = true
                
            }else{
                
                self.imageSize()
                
                //メール添付用にシェアモーダルに送る
                appDelegate?.Photoes = Notes![0].photos
                print("写真の数\(notes?.photos.count)")
                
                for ind in 1...4{
                    
                    print("作動？")
                    if ind == 1{
                        let filename = Notes![0].photos[0].filename
                        let filePath = (path! as NSString).stringByAppendingPathComponent(filename)
                        let image = UIImage(contentsOfFile: filePath)
                        print(image)
                        topImage.image = image
                        
                        presentTopImage = (Notes![0].photos[0].id)
                        
                    }
                    
                    if ind <= Notes![0].photos.count{
                        
                        let imageView:UIImageView = self.view.viewWithTag(ind) as! UIImageView
                        let filenames = Notes![0].photos[ind-1].filename
                        let filepaths = (path! as NSString).stringByAppendingPathComponent(filenames)
                        let images = UIImage(contentsOfFile: filepaths)
                        imageView.image = images
                   
                    }else{
                        
                        let imageView:UIImageView = self.view.viewWithTag(ind) as! UIImageView
                        imageView.image = nil
                        
                    }
                    
                    
                    
                }
                
            }
            
            
            if Notes![0].noteText.isEmpty{
                
                self.textView.text = "練習メニューやメモを書く．．．"
                self.textView.textColor = UIColor.grayColor()
                
            }else{
                
                self.textView.text = Notes![0].noteText
            }
            
            let weekDays = ["","日曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日"]
            let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute,NSCalendarUnit.Weekday]
            let comps:NSDateComponents = calendar.components(unit, fromDate: Notes![0].createDate!)
            
            self.navigationItem.title = "\(comps.year)/\(comps.month)/\(comps.day)"
            //ナヴィゲーションのtitleの色を変更
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
            self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
            
            //PDFメール用に日付データを入れる
            appDelegate?.dateForPDF = self.navigationItem.title
            
            DateLabels = UILabel(frame: CGRectMake(0,0,170,44))
            DateLabels.text = "\(comps.year)年\(comps.month)月\(comps.day)日\(weekDays[comps.weekday])"
            DateLabels.textColor = UIColor.whiteColor()
            DateLabels.textAlignment = NSTextAlignment.Center
            DateLabels.center = CGPointMake(self.view.bounds.width/2-30, 20)
            self.view.subviews[3].addSubview(DateLabels)
            
            shareButton = UIButton(frame: CGRectMake(0,0,44,44))
            shareButton.setImage(UIImage(named:"Upload-50"), forState: .Normal)
            shareButton.addTarget(self, action: "sharedButtonTaped", forControlEvents: .TouchUpInside)
            shareButton.center = CGPointMake(self.view.bounds.width - 30, 20)
            self.view.subviews[3].addSubview(shareButton)
            
            let minute = comps.minute.description
            if minute.characters.count == 1{
                
        
                minutesAndHoursLabels = UILabel(frame: CGRectMake(0,0,100,44))
                minutesAndHoursLabels.center = CGPointMake(self.view.bounds.width/2+80,20)
                minutesAndHoursLabels.textAlignment = NSTextAlignment.Center
                minutesAndHoursLabels.text = "\(comps.hour):0\(comps.minute)"
                minutesAndHoursLabels.textColor = UIColor.whiteColor()
                self.view.subviews[3].addSubview(minutesAndHoursLabels)
                
            }else{
                
                
                minutesAndHoursLabels = UILabel(frame: CGRectMake(0,0,80,44))
                minutesAndHoursLabels.center = CGPointMake(self.view.bounds.width/2+80,20)
                minutesAndHoursLabels.textAlignment = NSTextAlignment.Center
                minutesAndHoursLabels.text = "\(comps.hour):\(comps.minute)"
                minutesAndHoursLabels.textColor = UIColor.whiteColor()
                
                self.view.subviews[3].addSubview(minutesAndHoursLabels)

            }
            
            
            
            let myTime = Notes![0].timerTime
            var myTimes = Notes![0].timerTime
            
    
            print("mytimes:\(myTimes)")
            
            let hours = myTimes / 3600
            myTimes -= hours * 3600
            
            let minutes = myTimes / 60
            myTimes -= minutes * 60
            
            let seconds = myTimes
            
            
            
            if myTime >= 3600{
                
                timerLabels.hidden = false
                timerLabels.textColor = UIColor.whiteColor()
                timerLabels.text = "タイム：\(hours)時間\(minutes)分\(seconds)秒"
                timerLabels.backgroundColor = colorFromRGB.colorWithHexString("87CEEB")
                timerLabelWidth.constant = 160
                timerLabels.layer.masksToBounds = true
                timerLabels.layer.cornerRadius = 5

            }else if myTime >= 1{
                print("ゆいこ")
                
                timerLabels.hidden = false
                timerLabels.textColor = UIColor.whiteColor()
                timerLabels.text = "タイム：\(minutes)分\(seconds)秒"
                timerLabelWidth.constant = 130
                timerLabels.layer.masksToBounds = true
                timerLabels.layer.cornerRadius = 5
                timerLabels.backgroundColor = colorFromRGB.colorWithHexString("87CEEB")
            }else if myTime == 0{
                
                print("ナッシング")
                timerLabels.hidden = true
            }
            
            
            
            print(hours)
            print(minutes)
            print(seconds)
            
            
        }else{
            
            if appDelegate?.timerFlag == true{
                appDelegate?.timerFlag = false
                noImagePhotoButton.hidden = false
                
                print("ゆい")
                self.imageViewY.constant = 0
                self.topImageViewHeight.constant = 0
                self.topImageViewContainerHeight.constant = 200
                self.imageViewHeight.constant = 0
                self.noImagePhotoButtonHeight.constant = 200
                toPhotoDetailButton.hidden = true
                
            }else{
                
                print("山")
                noImagePhotoButton.hidden = true
                
                timerLabels.hidden = true
                
                self.topImageViewHeight.constant = 0
                self.topImageViewContainerHeight.constant = 0
                self.imageViewHeight.constant = 0
                self.imageViewY.constant = 0
                toPhotoDetailButton.hidden = true
                
            }
            
            
        
            
            self.textView.text = "練習メニューやメモを書く．．．"
            
        }
        
        
        
    }
    
    func imageSize(){
        
        switch screenHeight{
            
        case 480:
            self.topImageViewContainerHeight.constant = 470
            self.topImageViewHeight.constant = 470
            self.imageViewY.constant = 330
            self.imageViewHeight.constant = 79
            
        case 568:
            self.topImageViewContainerHeight.constant = 510
            self.topImageViewHeight.constant = 510
            self.imageViewY.constant = 390
            self.imageViewHeight.constant = 79
            
        case 667:
            self.topImageViewContainerHeight.constant = 550
            self.topImageViewHeight.constant = 550
            self.imageViewY.constant = 430
            self.imageViewHeight.constant = 79
            
        case 736:
            self.topImageViewContainerHeight.constant = 570
            self.topImageViewHeight.constant = 570
            self.imageViewY.constant = 450
            self.imageViewHeight.constant = 79
            
        default:
            print("エラー")
            
            
        }
        
        
    }
    
    @IBAction func photoButtonTaped(sender:UIButton){
        switch sender.tag{
        case 5:
            
            if appDelegate?.noteFlag == true{
                let filename = note![0].photos[0].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = note![0].photos[0].id
                
                
            }else{
                let filename = notes?.photos[0].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename!)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                print("消したい写真id\(notes?.photos[0].id)")
                presentTopImage = (notes?.photos[0].id)!
                
            }
            
            /*imageView1.layer.borderColor = UIColor(red: 0, green: 0.545, blue: 0.545, alpha: 1.0).CGColor
            imageView1.layer.borderWidth = 2.0
            
            imageView2.layer.borderColor = UIColor.clearColor().CGColor
            imageView2.layer.borderWidth = 0.0
            imageView3.layer.borderColor = UIColor.clearColor().CGColor
            imageView3.layer.borderWidth = 0.0
            imageView4.layer.borderColor = UIColor.clearColor().CGColor
            imageView4.layer.borderWidth = 0.0
            */
            
            
            
            
        case 6:
            
            
            if appDelegate?.noteFlag == true{
                //選択された写真が１枚なら無効
                if note![0].photos.count <= 1{
                    
                    return
                    
                }
                
                
                let filename = note![0].photos[1].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = note![0].photos[1].id
                
            }else{
                
                if notes?.photos.count <= 1{
                    return
                }
                
                let filename = notes?.photos[1].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename!)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = (notes?.photos[1].id)!
                
            }
            
            
           /* imageView2.layer.borderColor = UIColor(red: 0, green: 0.545, blue: 0.545, alpha: 1.0).CGColor
            imageView2.layer.borderWidth = 2.0
            
            imageView1.layer.borderColor = UIColor.clearColor().CGColor
            imageView1.layer.borderWidth = 0.0
            imageView3.layer.borderColor = UIColor.clearColor().CGColor
            imageView3.layer.borderWidth = 0.0
            imageView4.layer.borderColor = UIColor.clearColor().CGColor
            imageView4.layer.borderWidth = 0.0
            */
            
            
        case 7:
            if appDelegate?.noteFlag == true{
                //選択された写真が１枚なら無効
                
                if note![0].photos.count <= 2{
                    
                    return
                    
                }
                
                
                let filename = note![0].photos[2].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = note![0].photos[2].id
                
            }else{
                
                if notes?.photos.count <= 2{
                    return
                }
                
                let filename = notes?.photos[2].filename
                print("写真数：ボタン\(notes?.photos[2].filename)")
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename!)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = (notes?.photos[2].id)!
                
            }
            
            /*
            imageView3.layer.borderColor = UIColor(red: 0, green: 0.545, blue: 0.545, alpha: 1.0).CGColor
            imageView3.layer.borderWidth = 2.0
            
            imageView1.layer.borderColor = UIColor.clearColor().CGColor
            imageView1.layer.borderWidth = 0.0
            imageView2.layer.borderColor = UIColor.clearColor().CGColor
            imageView2.layer.borderWidth = 0.0
            imageView4.layer.borderColor = UIColor.clearColor().CGColor
            imageView4.layer.borderWidth = 0.0
            */
            
            
        case 8:
            if appDelegate?.noteFlag == true{
                //選択された写真が１枚なら無効
                if note![0].photos.count <= 3{
                    
                    return
                    
                }
                
                
                let filename = note![0].photos[3].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = note![0].photos[3].id
                
            }else{
                
                if notes?.photos.count <= 3{
                    return
                }
                
                let filename = notes?.photos[3].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename!)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = (notes?.photos[3].id)!
                
            }
            
            /*
            imageView4.layer.borderColor = UIColor(red: 0, green: 0.545, blue: 0.545, alpha: 1.0).CGColor
            imageView4.layer.borderWidth = 2.0
            
            imageView1.layer.borderColor = UIColor.clearColor().CGColor
            imageView1.layer.borderWidth = 0.0
            imageView2.layer.borderColor = UIColor.clearColor().CGColor
            imageView2.layer.borderWidth = 0.0
            imageView3.layer.borderColor = UIColor.clearColor().CGColor
            imageView3.layer.borderWidth = 0.0
            */
            
            
        case 10:
            
            if appDelegate?.noteFlag == true{
                //選択された写真が１枚なら無効
                if note![0].photos.count <= 4{
                    
                    return
                    
                }
                
                
                let filename = note![0].photos[4].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = note![0].photos[4].id
                
            }else{
                
                if notes?.photos.count <= 4{
                    return
                }
                
                let filename = notes?.photos[4].filename
                let filepath = (path! as NSString).stringByAppendingPathComponent(filename!)
                let image = UIImage(contentsOfFile: filepath)
                topImage.image = image
                
                presentTopImage = (notes?.photos[4].id)!
                
            }
            
            
            /*
            imageView1.layer.borderColor = UIColor.clearColor().CGColor
            imageView1.layer.borderWidth = 0.0
            imageView2.layer.borderColor = UIColor.clearColor().CGColor
            imageView2.layer.borderWidth = 0.0
            imageView3.layer.borderColor = UIColor.clearColor().CGColor
            imageView3.layer.borderWidth = 0.0
            imageView4.layer.borderColor = UIColor.clearColor().CGColor
            imageView4.layer.borderWidth = 0.0
            */
            
            
        default:
            print("error")
            
            
        }
        
        
        
        
    }
    
    func sharedButtonTaped(){
        
        let vc:shareViewController = self.storyboard?.instantiateViewControllerWithIdentifier("shareVC") as!
            shareViewController
        let navigation = UINavigationController()
        navigation.viewControllers = [vc]
        presentViewController(navigation, animated: true, completion: nil)
        
        
        self.createPDFFromView(self.view,saveToDocumentsWithFileName: "PDFファイル")
        
    }
    
    func createPDFFromView(aView:UIView,saveToDocumentsWithFileName FileName:String){
    
        //乱数
        let n = arc4random() % 1000 + 1
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day]

        let comps:NSDateComponents!
        
        if appDelegate?.noteFlag == true{
        
            comps = calendar?.components(unit, fromDate: note![0].createDate!)
            
        }else{
            
            comps = calendar?.components(unit, fromDate: Notes![0].createDate!)
        
        }

        
        
        let fileName = "ノートtrim\(comps.year)年\(comps.month)月\(comps.day)日\(n)"
        appDelegate?.nameOfPDF = fileName
        appDelegate?.nameOfPDFForMail = "noteInTrim.\(comps.year).\(comps.month).\(comps.day).\(n)"
        
        
        let tmpPath:NSString = NSTemporaryDirectory()
        
     
        let fullname = fileName.stringByAppendingString(".pdf")
        //PDFを作成し、一時的にtmpフォルダに保存。
        let pdfFileName = tmpPath.stringByAppendingPathComponent(fullname)
        
        let PDFSize = CGRectMake(0, 0, 610, 795)
        print(aView.bounds)
        
        UIGraphicsBeginPDFContextToFile(pdfFileName,PDFSize, nil)
        
        //.DocumentDirectryから写真データを引っ張ってくるために使うパス
        let Path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if Path.count > 0{
            path = Path[0]
        }
        
        if appDelegate?.noteFlag == true{
            
            drawPDF(note!)
            
        }else{
            
            drawPDF(Notes!)
            
        }
        
        UIGraphicsEndPDFContext()
        
        
       
        
    }
    
    //写真や文字を描画する感じのメソッド
    func drawPDF(noten:Results<(Note)>){
        
        let weekDay = ["","日曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日"]
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute,NSCalendarUnit.Weekday]
        let comps:NSDateComponents = (calendar?.components(unit, fromDate: (noten[0].createDate)!))!
        
        if noten[0].photos.isEmpty != true{
            
            for ind in 1...noten[0].photos.count{
                
                //ページを定義
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0,0,610,795), nil)
                if ind == 1{
                    
                    let day = "\(comps.year)年\(comps.month)月\(comps.day)日\(weekDay[comps.weekday])\(comps.hour):\(comps.minute)"
                    let rect = CGRectMake(100, 20, 300, 300)
                    let color:UIColor = colorFromRGB.colorWithHexString("2860A3")
                    
                    print("\(timerLabels.text)")
                    if timerLabels.text != "Label"{
                    
                        let rects = CGRectMake(280, 20, 600, 300)
                        drawString(timerLabels.text!, rect: rects, Color: UIColor.blackColor().CGColor, FontSize: 14, Font: "AppleSDGothicNeo-Light", ul: false)
                    }
                    
                    drawString(day, rect: rect, Color: color.CGColor, FontSize: 14, Font: "AppleSDGothicNeo-Light", ul: false)
                }
                
                let fileName = noten[0].photos[ind-1].filename
                let filePath = (path! as NSString).stringByAppendingPathComponent(fileName)
                let image = UIImage(named: filePath)
                
                image?.drawInRect(CGRectMake(124, 100, 361, 482))
                
                
            }
            
        }
        
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0,0,610,795), nil)
        
        //写真がない時は、ここで日付を表示したい
        if (noten[0].photos.isEmpty){
            
            if timerLabels.text != "Label"{
                
                let rects = CGRectMake(280, 50, 600, 300)
                drawString(timerLabels.text!, rect: rects, Color: UIColor.blackColor().CGColor, FontSize: 14, Font: "AppleSDGothicNeo-Light", ul: false)
            }

            
            let day = "\(comps.year)年\(comps.month)月\(comps.day)日\(weekDay[comps.weekday])\(comps.hour):\(comps.minute)"
            let rect = CGRectMake(100, 50, 300, 300)
            let color:UIColor = colorFromRGB.colorWithHexString("2860A3")
            
            drawString(day, rect: rect, Color: color.CGColor, FontSize: 14, Font: "AppleSDGothicNeo-Light", ul: false)
            
        }
        
        let descriptionRect:CGRect = CGRectMake(100, 130, 200, 200)
        let description:String = "ノート"
        
        
        //メモの下に下線を引きたい
        //グラフィックコンテキストをサイズ指定
        
        //グラフィックコンテキストを取得
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        //ラインの幅を決める
        CGContextSetLineWidth(context, 2.0)
        let Color:CGColorRef = UIColor.grayColor().CGColor
        CGContextSetStrokeColorWithColor(context, Color)
        
        //ラインの始点を設定
        CGContextMoveToPoint(context, 130, 100)
        CGContextAddLineToPoint(context, 500, 100)
        //パスを閉じる
        CGContextClosePath(context)
        //パスで指定した線を描画
        CGContextStrokePath(context)
        
        drawString(description, rect: descriptionRect, Color: UIColor.blackColor().CGColor, FontSize: 24, Font: "AppleSDGothicNeo-Medium", ul: false)
        
        let textRect:CGRect = CGRectMake(100, -450, 320, 700)
        drawString(textView.text, rect: textRect, Color: UIColor.blackColor().CGColor, FontSize: 12, Font: "AppleSDGothicNeo-Light", ul: false)
        
        let colors:CGColorRef = colorFromRGB.colorWithHexString("2860A3").CGColor
        
        drawString("Created in trim", rect: CGRectMake(222, -1070, 320, 700), Color: colors, FontSize: 12, Font: "AppleSDGothicNeo-Light", ul: false)
        
        print("ギリギリ入る高さ\(textView.bounds.size.height)")
        
    }
    
    //pdfに文字を描画するためのメソッド
    func drawString(string:String,rect:CGRect,Color color:CGColorRef,FontSize fontSize:CGFloat,Font fontname:String,ul:Bool){
        
        //文字色やサイズを設定。
        let newAttributedText = NSMutableAttributedString(string: string)
        let Font:UIFont = UIFont(name: fontname, size: fontSize)!
        let ranges = NSRange(location: 0, length: newAttributedText.length)

        newAttributedText.addAttribute(NSFontAttributeName, value: Font, range: ranges)
        let textLength = newAttributedText.length
        
        
        //文字色を変えたい
        //let rgbColorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        //let components:[CGFloat] = [1.0,0.0,0.0,0.8]
        // let color:CGColorRef = CGColorCreate(rgbColorSpace, components)!
        CFAttributedStringSetAttribute(newAttributedText, CFRangeMake(0,textLength),kCTForegroundColorAttributeName, color)
        
        
        
        //描画領域の準備
        let frameSetter:CTFramesetterRef = CTFramesetterCreateWithAttributedString(newAttributedText)
        let framePath:CGMutablePathRef = CGPathCreateMutable()
        CGPathAddRect(framePath, nil, rect)
        
        //レンダリングをするフレームを取得
        let currentRange:CFRange = CFRangeMake(0, 0)
        let frameRef:CTFrameRef = CTFramesetterCreateFrame(frameSetter, currentRange, framePath, nil)
        
        //グラフィックコンテキストを取得
        let currentContext:CGContextRef = UIGraphicsGetCurrentContext()!
        
        //コンテキストの保存
        CGContextSaveGState(currentContext)
        
        //テキスト行列を既知の状態にする
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity)
        
        //coreTextは左下隅から上に向かって描画されるため、反転処理を行う
        CGContextTranslateCTM(currentContext,50, 400)
        
        print("高さ\(self.view.bounds.height)")
        CGContextScaleCTM(currentContext, 1.0, -1.0)
        
        //フレームを描画する
        CTFrameDraw(frameRef, currentContext)
        
        //コンテキストの復元
        CGContextRestoreGState(currentContext)
        
}

    @IBAction func toPhotoDetailButtonTaped(sender: AnyObject) {

        appDelegate?.detailPhoto = topImage.image
        appDelegate?.detailPhotoId = presentTopImage
        
        let photoDetail = self.storyboard?.instantiateViewControllerWithIdentifier("photoDetail")
        let navigation = UINavigationController()
        navigation.viewControllers = [photoDetail!]
        self.presentViewController(navigation, animated: true, completion: nil)
        
    }
    
    /* override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "toDetailPhotos"{
    
    let vc = segue.destinationViewController as! PhotoDetailViewController
    vc.image = topImage.image!
    
    vc.photoId = sender as! Int
    
    }
    
    
    }*/
    
    @IBAction func writeNoteButtonTaped(sender: AnyObject) {
        
        //新規ノートの場合
        if appDelegate?.noteFlag == true{
            let realm = try!Realm()
            let note = realm.objects(Note).sorted("id", ascending: false)
            
            //ノートidを渡す
            appDelegate?.editNoteId = note[0].id
            //ノートが追加だということを知らせる。フラグ名がわかりづらいな。
            appDelegate?.addPhotoFlag = true
            //ノートのテキストを送る
            appDelegate?.textData = note[0].noteText
            performSegueWithIdentifier("toTextView", sender: nil)
            
            
            
        }else if appDelegate?.noteFlag == false{
            
            //ノートidを渡す
            appDelegate?.editNoteId = notes?.id
            //ノートが追加だということを知らせる。フラグ名がわかりづらいな。
            appDelegate?.addPhotoFlag = true
            //ノートディテールのテキストビューを押したことを伝える
            appDelegate?.textViewOfNoteDetail = true
            //ノートのテキストを送る
            appDelegate?.textData = notes?.noteText
            
            performSegueWithIdentifier("toTextView", sender: nil)
            
            
        }else{
            
            appDelegate?.textViewOfNoteDetail = true
            appDelegate?.cancelAdd = true
            performSegueWithIdentifier("toTextView", sender: nil)
            
        }
        
        
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        self.tabBarController?.view.subviews[2].hidden = false
        
        
        //タイムラインに戻るボタンが押されたら
        let viewControllers = self.navigationController?.viewControllers
        if indexOfArray(viewControllers!,searchObject:self) == nil{
            
            //ここをnilじゃなくて、falseにしたらどうかな。影響を考える。
            appDelegate?.noteFlag = false
            appDelegate?.noteReturn = true
            appDelegate?.textData = nil
            appDelegate?.photosCount = 0
            
        }
        
        super.viewWillDisappear(animated)
        
    }
    

    
    func indexOfArray(array:[AnyObject],searchObject:AnyObject)->Int?{
        
        
        for (index,value) in array.enumerate(){
            if value as! UIViewController == searchObject as! UIViewController{
                return index
                
            }
            
            
        }
        return nil
    }
    
    
    
    /* override func viewDidLayoutSubviews() {
    let fixedWidth = textView.frame.size.width
    let textViewNewSize = textView.sizeThatFits(CGSizeMake(fixedWidth,CGFloat.max))
    
    
    /*var newFrame = allViewContainer.frame
    newFrame.size = CGSizeMake(max(textViewNewSize.width, fixedWidth), 100 + textViewNewSize.height)
    allViewContainer.frame = newFrame
    print(allViewContainer.frame)*/
    
    var newFrame = textView.frame
    newFrame.size = CGSizeMake(max(textViewNewSize.width, fixedWidth), textViewNewSize.height)
    textView.frame = newFrame
    print("テキストビュー\(textView.frame)")
    textView.backgroundColor = UIColor.purpleColor()
    
    newFrame = textViewContainer.frame
    newFrame.size = CGSizeMake(max(textViewNewSize.width,fixedWidth), textViewNewSize.height)
    textViewContainer.frame = newFrame
    textViewContainer.backgroundColor = UIColor.redColor()
    
    
    newFrame = textButton.frame
    newFrame.size = CGSizeMake(max(textViewNewSize.width, fixedWidth), textViewNewSize.height)
    textButton.frame = newFrame
    
    
    
    }*/
    
    @IBAction func NoImagePhotoButtonTaped(sender: AnyObject) {
        
        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        switch status{
        case AVAuthorizationStatus.Authorized:
            //許可されている場合
            let cameraViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Camera")
            appDelegate?.tabBarCamera = true
            appDelegate?.addPhotoFlag = true
            appDelegate?.noteFlag = true
            appDelegate?.noPhotoButtonTaped = true
            appDelegate?.editNoteId = note![0].id
            
            self.presentViewController(cameraViewController!, animated: true, completion: nil)
            
            
        case AVAuthorizationStatus.Denied:
            //カメラの使用が禁止されている場合
            break;
        case AVAuthorizationStatus.NotDetermined:
            //まだ確認されていない場合、許可を求めるダイアログを表示
            print("やぁ")
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                
                if granted{
                    //許可された場合
                    let cameraViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Camera")
                    self.appDelegate?.tabBarCamera = true
                    self.appDelegate?.addPhotoFlag = true
                    self.appDelegate?.noPhotoButtonTaped = true
                    self.appDelegate?.noteFlag = true
                    self.appDelegate?.editNoteId = self.note![0].id
                    self.presentViewController(cameraViewController!, animated: true, completion: nil)
                    
                    
                }else{
                    
                    print("不許可")
                    
                }
                
            })
            
        default:
            break
            
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