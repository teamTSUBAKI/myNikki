//
//  timeLineViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/27.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyDropbox

class timeLineViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    var appDelegate:AppDelegate?
    
    
    
    @IBOutlet weak var tableView: UITableView!

    var tableViewSections:NSMutableArray = []
    var tableViewCells:[NSString:[NSMutableArray]]?

    var sectionHeding:NSString!
    
    var emptyStatLabel:UILabel!
    var descriptionLabel:UITextView!
    var arrowImageView:UIImageView!
    
    var path:String?
   
    var year:Int?
    var month:Int?
    var day:Int?
    
    var notes:Results<(Note)>?

    var deletePhotoObserver:NSObjectProtocol?
    var savePhotoObserver:NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューが空の時に表示する
        emptyStatLabel = UILabel(frame: CGRectMake(0,0,300,50))
        emptyStatLabel.center = CGPointMake(self.view.bounds.width/2,self.view.bounds.height/2-50)
        emptyStatLabel.textAlignment = NSTextAlignment.Center
        emptyStatLabel.text = "写真とメモで成長を記録しましょう"
        emptyStatLabel.textColor = colorFromRGB.colorWithHexString("B0C4DE")
        
        descriptionLabel = UITextView(frame: CGRectMake(0, 0, 180, 50))
        descriptionLabel.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.height - 100)
        // descriptionLabel.backgroundColor = UIColor.grayColor()
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.editable = false
        descriptionLabel.text = "カメラをタップすると\n写真やメモを記録できます"
        
        arrowImageView = UIImageView(frame: CGRectMake(0, 0,44, 44))
        arrowImageView.center = CGPointMake(self.view.bounds.width/2, self.view.bounds.height - 70)
        arrowImageView.image = UIImage(named: "Down-50")
        
        self.view.addSubview(arrowImageView)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(emptyStatLabel)

        
        
        //テーブルビューの余計な線をなくす
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = view
        tableView.tableHeaderView = view
        
        print(NSDate())
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        
        let textButton = UIBarButtonItem(title: "メモを書く", style: .Plain, target: self, action: "textButtonTaped")
     
        
        
        self.navigationItem.rightBarButtonItem = textButton
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if paths.count > 0{
            
           path = paths[0] as String
        
        }
        
        //realmをデータベースごと消したいときに使う
    /*   if let path = Realm.Configuration.defaultConfiguration.path{
            try?NSFileManager.defaultManager().removeItemAtPath(path)
            
        }*/
        
        //最後のデータを消したいときに使う
        /*let realm = try!Realm()
        let note = realm.objects(Note).sorted("id", ascending: false)
        
        try!realm.write({ () -> Void in
            
            realm.delete(note[0])
            
        })*/
        
        //Documentのデータを全部消す
      // try?NSFileManager.defaultManager().removeItemAtPath(path!)
        
         self.setupYearandMonth()
        
        
        // Do any additional setup after loading the view.
        
         deletePhotoObserver = NSNotificationCenter.defaultCenter().addObserverForName("deletePhoto", object: nil, queue: nil, usingBlock: {(Notification) in
            
            self.setupYearandMonth()
            self.tableView.reloadData()
            
            })
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "savePhoto", object: nil)
    }
    
    func reload(){
        
        self.setupYearandMonth()
        self.tableView.reloadData()
        print("リワーズ")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        //Dropboxにログイン後、一回目のタイムライン表示のタイミングですべての写真、realmデータをdropboxに保存する
        //Dropboxにログイン済みなら
        print(Dropbox.authorizedClient)
        if (Dropbox.authorizedClient != nil){
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let dic = ["firstAfterDropBoxLogin":true]
            userDefaults.registerDefaults(dic)
            
            userDefaults.setBool(true, forKey: "firstAfterDropBoxLogin")
            if userDefaults.boolForKey("firstAfterDropBoxLogin"){
                print("ログイン")
                //dropboxへすべての写真、default.realmをバックアップ
                self.downLoadFromDropbox()
                
                userDefaults.setBool(true, forKey: "firstAfterDropBoxLogin")
                
                
            }
            
            
            
        }
        

        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "TimeLine")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        self.setupYearandMonth()
        self.tableView.reloadData()
        print("リローダー")
        
        //データがない場合のエンプティステイト
        if tableViewSections.count == 0{
            
            tableView.hidden = true
            emptyStatLabel.hidden = false
            descriptionLabel.hidden = false
            arrowImageView.hidden = false
            
            
            
        }else{
            
            tableView.hidden = false
            emptyStatLabel.hidden = true
            descriptionLabel.hidden = true
            arrowImageView.hidden = true
            
            
        }

      
       

    }
    
    override func viewDidAppear(animated: Bool) {
        
        

        
        
        //ノートから戻るボタンで戻ってきた場合はnoteFlagを一度nilにする。
        if appDelegate!.noteReturn == true{
            
            appDelegate!.noteFlag = nil
            appDelegate!.noteReturn = false
            
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
                    
                    
                    
                    autoreleasepool({ () -> () in
                        
                        let realm = try!Realm()
                        let realmNote = realm.objects(Note)
                        
                        var configs = Realm.Configuration()
                        configs.path = NSURL.fileURLWithPath(configs.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("defaults").URLByAppendingPathExtension("realm").path
                        
                        let realms = try!Realm(configuration: configs)
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
                        
                        //上記のコードで、ドロップボックスからDocumenetDirectoryにdefault.realmをdefaults.realmという名前でダウンロード(同じ名前だとダウンロードできないため)し、もともとあったdefault.realmをdefaults.realmにコピーした。ここでdefault.realmを削除して、defaults.realmをdefault.realmに名前変更したい。
                        let documentDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        let fileName = "defaults.realm"
                        let fileNames = "default.realm"
                        
                        print("ダウンロード２")
                        if NSFileManager.defaultManager().fileExistsAtPath("\(documentDirPath)/\(fileName)") && NSFileManager.defaultManager().fileExistsAtPath("\(documentDirPath)/\(fileNames)"){
                            
                            try!NSFileManager.defaultManager().removeItemAtPath("\(documentDirPath)/\(fileNames)")
                            try!NSFileManager.defaultManager().moveItemAtPath("\(documentDirPath)/\(fileName)", toPath: "\(documentDirPath)/\(fileNames)")
                            print("エレガンス")
                        }
                        
                        print("ムッシュー")
                        
                        
                    })
                    
                    autoreleasepool({ () -> () in
                        
                        let realmss = try!Realm()
                        let Photo = realmss.objects(Photos)
                        print("写真１\(Photo)")
                        for photo in Photo{
                            
                            let filename = photo.filename
                            if let client = Dropbox.authorizedClient{
                                
                                client.files.download(path: "/\(filename)", destination: destination).response({ (response, error) -> Void in
                                    
                                    if let metadata = response{
                                        print("download \(metadata)")
                                    }else{
                                        print(error)
                                    }
                                    
                                })
                                
                            }
                            
                        }
                        
                        
                        
                    })
                    
                    self.uploadToDropBox()
                    
                    
                }else{
                
                    print(error)
                }
                
                
                
            })
            
           self.uploadToDropBox() 
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
        
        //写真データをバックアップ。元のdefault.realmが参照されている。なぜだろう？元のはコピーして消したはずなのに。
        autoreleasepool { () -> () in
            let realm = try!Realm()
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
    

    

    

  
    
    
    //セクションヘッダーに年月を入れるための準備
    func setupYearandMonth(){
    //使用するカレンダーを選択
    print("男はつらいよ")
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    //NSDate形式の情報から変換するフォーマットを作る
    let dateFormattaer:NSDateFormatter = NSDateFormatter()
    dateFormattaer.locale = NSLocale(localeIdentifier: "en_US")
    //日付のフォーマット。年と月。
    dateFormattaer.dateFormat = "yyyy/MM"
    
    //ユニットに選択したい月日を選択
    let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month]
    
    var previousYear:Int = -1
    var previousMonth:Int = -1
    
    var tableViewCellsForSection:NSMutableArray = []
    //宣言しただけで初期化していなかったためにエラーになっていた。
    tableViewCells = [:]
    tableViewSections = []
    print("男はつらいね")
        if self.navigationController is timeLineNavigationController{
            print("男はつらいか")
            let realm = try!Realm()
            notes = realm.objects(Note).sorted("id", ascending: false)
            print("エントリー数\(notes?.count)")
        
        }else if self.navigationController is CalendarViewNavigationController{
            let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
            
            print("カレンダー\(day!)")
            
            let targetDate:NSDate = calendar.dateWithEra(1, year: year!, month: month!, day: day!, hour: 0, minute: 0, second: 0, nanosecond: 0)!
            let lastTargetDate:NSDate = calendar.dateWithEra(1, year: year!, month: month!, day: day!, hour: 23, minute: 59, second: 59, nanosecond: 0)!
            
            let realm = try!Realm()
            
            let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}", targetDate,lastTargetDate)
            notes = realm.objects(Note).filter(predicate).sorted("id",ascending: false)
            
        }
        
        
         print("男はつらいて")
        //帰ってきた全てのノートデータを取り出す
        for note in notes!  {
            
            if note.createDate != nil{
            let coms:NSDateComponents = (calendar?.components(unit, fromDate: note.createDate!))!
             year = coms.year
             month = coms.month
            
            //ノートデータの年月が年、もしくは月が違うならば。次の月ならば。
            //こうすることで、同じ年の同じ月のデータの時は回らない。
                if (year != previousYear || month != previousMonth){
    
                sectionHeding = dateFormattaer.stringFromDate(note.createDate!)
                
                //tableViewSectionsという配列に年月のデータを入れる。これがセクション数になる
                self.tableViewSections.addObject(sectionHeding)
                //これがないと、セルを消そうとした時おかしくなる。
                tableViewCellsForSection = []
                //sectionHeding=2015/7をキーに、ノートデータの配列を入れる
                self.tableViewCells!["\(sectionHeding)"] = [tableViewCellsForSection]
                
                //ノートデータの年、月を入れる
                previousYear = year!
                previousMonth = month!
                
                
            }
        
        tableViewCellsForSection.addObject(note)
        print("データ数\(tableViewCellsForSection.count)")
        
            
            
            }else{
                
                print("エラー")
                
            }
    
        }
        
    }
    
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        print("セクションの数！\(self.tableViewSections.count)")
        return self.tableViewSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ディクショナリーから取り出すためのキーを変数に入れる
        let key:NSString = tableViewSections[section] as! NSString
        //キーでノートデータ配列のデータ数を数える。
    
        print("セルの数：\(self.tableViewCells![key]![0].count)")
        
      
        
        
        return self.tableViewCells![key]![0].count
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
      return self.tableViewSections[section] as? String
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = colorFromRGB.colorWithHexString("FCFCFC")
        label.textAlignment = NSTextAlignment.Center
        label.textColor = colorFromRGB.colorWithHexString("999999")
        label.text = self.tableViewSections[section] as? String
        
        return label
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:timeLineTableViewCell = tableView.dequeueReusableCellWithIdentifier("noteCell")as! timeLineTableViewCell
    

        
        let key = self.tableViewSections[indexPath.section] as! NSString
        let note:Note = self.tableViewCells![key]![0][indexPath.row] as! Note
        
        if note.photos.isEmpty{
            
            print("ゆい")
            cell.PhotoWidth.constant = 0
            print("写真の幅\(cell.PhotoWidth.constant)")
            cell.titleLabeX.constant = 10
            cell.bodyLabelX.constant = 10
            cell.timerX.constant = 10
            cell.timerLabel.backgroundColor = colorFromRGB.colorWithHexString("87CEEB")
            cell.timerLabel.textColor = UIColor.whiteColor()
            cell.timerLabel.layer.cornerRadius = 5
            cell.timerLabel.layer.masksToBounds = true
            
            
        }else{
        
            cell.PhotoWidth.constant = 99
            cell.titleLabeX.constant = 115
            cell.bodyLabelX.constant = 115
            cell.timerX.constant = 115
            cell.timerLabel.backgroundColor = colorFromRGB.colorWithHexString("87CEEB")
            cell.timerLabel.textColor = UIColor.whiteColor()
            cell.timerLabel.layer.cornerRadius = 5
            cell.timerLabel.layer.masksToBounds = true
            
        //写真のファイルネームを取得
        let filename = note.photos[0].filename
        
        //画像ファイルパス
        let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
        //ファイルから写真を取り込む
        let image =  UIImage(contentsOfFile: filepath)
            
        cell.Photo.image = image
    
        //エラーハンドリングの実装例。とりあえず、エラーハンドリングしなくてもクラッシュはしないみたいだからおいおい実装していく
         /*   do {
        
                //let image = try UIImage(contentsOfFile: filepath)
                let image = try UIImage(contentsOfFile: "yui.jpg")
            
                cell.Photo.image = image
            }catch{
                
                print("エラーず")
            }*/
           
        }
        
        //ノートのコメントの一行目を取得
        let title = note.noteText.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())[0]

        let font:UIFont = UIFont(name: "HelveticaNeue-Bold", size: 17)!
        cell.titleLabel.font = font
        cell.titleLabel.text = title
        
        //ノートの一行目以降を取得。
        //削除したタイトルの空白と改行が残っているので、トリミング。
    
        
        let bodytext = note.noteText.stringByReplacingOccurrencesOfString(title, withString: "")
        let afterText = bodytext.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        cell.bodyTextLabel.text = afterText
        
        var myTime = note.timerTime
        let myTimes = note.timerTime
    
        
        let hour = myTime / 3600
        myTime -= hour * 3600
        
        let minutes = myTime / 60
        myTime -= minutes * 60
        
        let seconds = myTime
        
        if myTimes == 0 {
            
            cell.timerLabel.hidden = true
            
        }else{
            if myTimes >= 3600{
                
                cell.timerLabel.text = "タイム：\(hour)時間\(minutes)分\(seconds)秒"
                cell.timerLabel.hidden = false
                cell.timerLabelWidth.constant = 145
                cell.timerLabel.textAlignment = NSTextAlignment.Center
                
            }else{
                
                cell.timerLabel.text = "タイム：\(minutes)分\(seconds)秒"
                cell.timerLabel.hidden = false
                cell.timerLabelWidth.constant = 130
                cell.timerLabel.textAlignment = NSTextAlignment.Center
            }
            
            
        }
        
        
        //時間を表示する。曜日を配列に入れる
        let weekDay:Array = ["","日曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日"]
        let calendar:NSCalendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        let unit:NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month,NSCalendarUnit.Day,NSCalendarUnit.Hour,NSCalendarUnit.Minute,NSCalendarUnit.Weekday]
        let comps:NSDateComponents = calendar.components(unit, fromDate:note.createDate!)
        
        //スクショ撮影用
        /*
        if indexPath.row == 0{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間35分"
            
        }
        
        if indexPath.row == 1{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間02分"
            
        }
        
        if indexPath.row == 2{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間11分"
        }
        
        if indexPath.row == 3{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間21分"
        }

        if indexPath.row == 4{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間15分"
        }
        
        if indexPath.row == 5{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間2分"
        }*/


        
        
        print("時間：\(comps.minute)")
        let mimute = comps.minute.description
        if mimute.characters.count == 1{
         
            cell.timeLabel.text = "\(comps.hour)"+":"+"0"+mimute
            
        }else{
        
        cell.timeLabel.text = "\(comps.hour)"+":"+"\(comps.minute)"

        }
        cell.dayLabel.text = "\(comps.day)"
        print(comps.weekday)
        cell.weekDayLabel.text = weekDay[comps.weekday]
        
        return cell
        
    }
    
    func textButtonTaped(){
        
        let textViewControllers = self.storyboard?.instantiateViewControllerWithIdentifier("TextView")as! TextViewController
        let navigation = UINavigationController()
        navigation.viewControllers = [textViewControllers]
        self.presentViewController(navigation, animated: false, completion: {()->Void in
            
            let vc:UINavigationController = self.tabBarController?.viewControllers![1] as! UINavigationController
            self.tabBarController!.selectedViewController = vc
            vc.popViewControllerAnimated(false)
            vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: nil)
            
            })

    
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //セルの選択状態を解除
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        appDelegate?.noteFlag = false
        //画面遷移
        performSegueWithIdentifier("toNoteDetail", sender: indexPath)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toNoteDetail"{
         
            let vc = segue.destinationViewController as! NoteDetailViewController
            if let indexPath = sender as? NSIndexPath{
            let key = self.tableViewSections[indexPath.section] as! NSString
            vc.notes = self.tableViewCells![key]![0][indexPath.row] as? Note
            
            }
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //削除の場合
        if editingStyle == .Delete{
            let realm = try!Realm()
            let key = tableViewSections[indexPath.section] as! NSString
            let note:Note = self.tableViewCells![key]![0][indexPath.row] as! Note
            
            self.tableViewCells![key]![0].removeObject(note)
            
            for photo in note.photos{
            
            let filePath = (path! as NSString).stringByAppendingPathComponent(photo.filename)
            
            //ドロップボックスにログインしているなら、ドロップボックスからも削除。
            if let client = Dropbox.authorizedClient{
                    client.files.delete(path: "/\(photo.filename)").response({ (response, error) -> Void in
                        
                        if let metadata = response{
                            print("delete file name:\(metadata)")
                        }else{
                            print(error)
                        }
                        
                    })
                }
                
            try?NSFileManager.defaultManager().removeItemAtPath(filePath)
            
            }
                
            //realmから削除
            try!realm.write({ () -> Void in
             
                realm.delete(note.photos)
                realm.delete(note)
                
            })
            
            uploadRealmToDropbox()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            NSNotificationCenter.defaultCenter().postNotificationName("deletePhoto", object: nil)
            }
    }
    
    //realmファイルを最新の状態に。
    func uploadRealmToDropbox(){
        
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
   
    
       
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self.deletePhotoObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
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
