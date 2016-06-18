//
//  timeLineViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/27.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

//写真のリサイズのためにUIImageを拡張
extension UIImage{
    
    func resized(size:CGSize) -> UIImage{
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio:heightRatio
        let resizeSize = CGSize(width:(self.size.width * ratio),height: (self.size.height * ratio))
        
        UIGraphicsBeginImageContextWithOptions(resizeSize, false, 0.0)
        drawInRect(CGRect(x:0,y: 0,width: resizeSize.width,height: resizeSize.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage
    }
    
}


class timeLineViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    var appDelegate:AppDelegate?
    
    var downLoadObsever:NSObjectProtocol!
    
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
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //リサイズした写真をキャッシュする
    var imageCache = [NSIndexPath:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let dic = ["downloadRealmFile":false]
        userDefaults.registerDefaults(dic)
        
        //テーブルビューが空の時に表示する
        emptyStatLabel = UILabel(frame: CGRectMake(0,0,300,50))
        emptyStatLabel.center = CGPointMake(self.view.bounds.width/2,self.view.bounds.height/2-50)
        emptyStatLabel.textAlignment = NSTextAlignment.Center
        emptyStatLabel.text = "写真とノートで成長を記録しましょう"
        emptyStatLabel.textColor = colorFromRGB.colorWithHexString("B0C4DE")
        
        descriptionLabel = UITextView(frame: CGRectMake(0, 0, 180, 50))
        descriptionLabel.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.height - 100)
        // descriptionLabel.backgroundColor = UIColor.grayColor()
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.editable = false
        descriptionLabel.text = "カメラをタップすると\n写真やノートを記録できます"
        
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
        
        
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        
        
        
        if self.navigationController is timeLineNavigationController{
            
            let textButton = UIBarButtonItem(title: "ノートを書く", style: .Plain, target: self, action: "textButtonTaped")
            let settingButton = UIBarButtonItem(image: UIImage(named: "More-52"), style: .Plain, target: self, action: "settingButtonTaped")
            
            self.navigationItem.leftBarButtonItem = settingButton
            self.navigationItem.rightBarButtonItem = textButton
            
            self.navigationItem.title = "TimeLine"
        }else if self.navigationController is CalendarViewNavigationController{
            
            self.navigationItem.title = "\(month!)月\(day!)日ノート一覧"
            
        }
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if paths.count > 0{
            
           path = paths[0] as String
        
        }
        
        //realmをデータベースごと消したいときに使う
       /*if let path = Realm.Configuration.defaultConfiguration.path{
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
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //なぜか、ここで初期化することでうまくいった。
        imageCache = [:]
               
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "TimeLine")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        self.setupYearandMonth()
        self.tableView.reloadData()
        
        
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
    
    
        
        

  
    
    
    //セクションヘッダーに年月を入れるための準備
    func setupYearandMonth(){
    //使用するカレンダーを選択
    
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
    
        if self.navigationController is timeLineNavigationController{
            
           
            let realm = try!Realm()
            notes = realm.objects(Note).sorted("id", ascending: false)
      
      
    
        
        }else if self.navigationController is CalendarViewNavigationController{
            let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
            
            
            
            let targetDate:NSDate = calendar.dateWithEra(1, year: year!, month: month!, day: day!, hour: 0, minute: 0, second: 0, nanosecond: 0)!
            let lastTargetDate:NSDate = calendar.dateWithEra(1, year: year!, month: month!, day: day!, hour: 23, minute: 59, second: 59, nanosecond: 0)!
            
            let realm = try!Realm()
            
            let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}", targetDate,lastTargetDate)
            notes = realm.objects(Note).filter(predicate).sorted("id",ascending: false)
            
        }
        
        
        
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
        
        
            
            
            }else{
                
                print("エラー")
                
            }
    
        }
        
    }
    
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.tableViewSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ディクショナリーから取り出すためのキーを変数に入れる
        let key:NSString = tableViewSections[section] as! NSString
        //キーでノートデータ配列のデータ数を数える。
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
            
            
            cell.PhotoWidth.constant = 0
            cell.titleLabeX.constant = 10
            cell.bodyLabelX.constant = 10
            cell.timerX.constant = 10
            cell.timerLabel.backgroundColor = colorFromRGB.colorWithHexString("a1d8e6")
            cell.timerLabel.textColor = UIColor.whiteColor()
            cell.timerLabel.layer.cornerRadius = 5
            cell.timerLabel.layer.masksToBounds = true
            
            
            
            
        }else{
        
            cell.PhotoWidth.constant = 99
            cell.titleLabeX.constant = 115
            cell.bodyLabelX.constant = 115
            cell.timerX.constant = 115
           
            cell.timerLabel.backgroundColor = colorFromRGB.colorWithHexString("a1d8e6")

            cell.timerLabel.textColor = UIColor.whiteColor()
            cell.timerLabel.layer.cornerRadius = 5
            cell.timerLabel.layer.masksToBounds = true
            
        //写真のファイルネームを取得
        let filename = note.photos[0].filename
        
        //画像ファイルパス
        let filepath = (path! as NSString).stringByAppendingPathComponent(filename)
            
        cell.Photo.image = nil
            
            
            if let Image = imageCache[indexPath]{
                
                
                
                cell.Photo.image = Image
                
                
            }else{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                
                    //ファイルから写真を取り込む
                    let image =  UIImage(contentsOfFile: filepath)
                    
                    
                    let reImage:UIImage? = image?.resized(CGSizeMake(cell.PhotoWidth.constant, cell.Photo.frame.height + 60))
                    
                    
                    self.imageCache[indexPath] = reImage
                
                    dispatch_async(dispatch_get_main_queue(), {
                    
                    
                        cell.Photo.image = reImage
                    
                    
                    })
                
                
                
                })
                
            }
    
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
        if indexPath.section == 0{
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
        }
        
        if indexPath.section == 1{
        if indexPath.row == 0{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間21分"
        }

        if indexPath.row == 1{
            cell.timerLabel.hidden = false
            cell.timerLabel.text = "タイム：1時間15分"
        }
        
        
        }*/

        
        let mimute = comps.minute.description
        if mimute.characters.count == 1{
         
            cell.timeLabel.text = "\(comps.hour)"+":"+"0"+mimute
            
        }else{
        
        cell.timeLabel.text = "\(comps.hour)"+":"+"\(comps.minute)"

        }
        cell.dayLabel.text = "\(comps.day)"
        
        cell.weekDayLabel.text = weekDay[comps.weekday]
        
        return cell
        
    }
    
    func textButtonTaped(){
        
        let textViewControllers = self.storyboard?.instantiateViewControllerWithIdentifier("TextView")as! TextViewController
        let navigation = UINavigationController()
        navigation.viewControllers = [textViewControllers]
        self.presentViewController(navigation, animated: false, completion: {()->Void in
            
            let vc:UINavigationController = self.tabBarController?.viewControllers![0] as! UINavigationController
            self.tabBarController!.selectedViewController = vc
            vc.popViewControllerAnimated(false)
            vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: nil)
            
            })

    
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //セルの選択状態を解除
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        appDelegate?.noteFlag = false
        appDelegate?.albumFlag = false
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
            
            //キャッシュからも消す
            imageCache = [:]
            
            let realm = try!Realm()
            
            let key = tableViewSections[indexPath.section] as! NSString
            let note:Note = self.tableViewCells![key]![0][indexPath.row] as! Note
            
            self.tableViewCells![key]![0].removeObject(note)
            
            for photo in note.photos{
            
            let filePath = (path! as NSString).stringByAppendingPathComponent(photo.filename)
            
            try?NSFileManager.defaultManager().removeItemAtPath(filePath)
            
            }
                
            //realmから削除
            try!realm.write({ () -> Void in
             
                realm.delete(note.photos)
                realm.delete(note)
                
            })
            
            
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            NSNotificationCenter.defaultCenter().postNotificationName("deletePhoto", object: nil)
            }
    }
    
    func settingButtonTaped(){
        
        let settingVC:SettingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Setting")as! SettingViewController
        let navigation = UINavigationController()
        navigation.viewControllers = [settingVC]
        
        presentViewController(navigation, animated: true, completion: nil)
        
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
