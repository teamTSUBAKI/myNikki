//
//  TextViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/24.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift


class TextViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var textView: UITextView!

   
    @IBOutlet weak var textViewBottomConst: NSLayoutConstraint!
    
    var path:String?
    
    //datePickerが出ている状態なら、true
    var dateEditFlag = false
        
    var appDelegate:AppDelegate?
    
    var centerButton:UIButton!
    
    let screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
    let screenWidth = Double(UIScreen.mainScreen().bounds.size.width)
    
    var textFields:UITextField?
    var datePickerImageView:UIImageView?
    var datePicker:UIDatePicker!
    
    var editKeyBoardView:UIView?
    var dateEditbutton:UIButton!
    var todayButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        

        self.tabBarController?.tabBar.hidden = true
        print("サブ\(self.tabBarController?.view.subviews[2])")
        self.tabBarController?.view.subviews[2].hidden = true
        
        
        
        centerButton = self.tabBarController?.view.subviews[3] as? UIButton
       
        if centerButton != nil{
        centerButton.enabled = false
        }
        
        
        
        datePicker = UIDatePicker()
        
        textFields = dateEditTextField(frame: CGRect(x: screenWidth-50,y: 0,width: 44,height: 44))
        textFields?.tintColor = UIColor.clearColor()
        textFields?.inputView = datePicker
        textFields?.delegate = self
        
        
        datePickerImageView = UIImageView(frame:CGRect(x:screenWidth-50, y: 0,width: 40,height: 40))
        datePickerImageView?.image = UIImage(named: "Clock-50 (2)")
        
        
        dateEditbutton = UIButton(frame: CGRect(x: screenWidth-50,y: 0,width: 44,height: 44))
        //dateEditbutton.setImage(UIImage(named: "Clock Filled-50"), forState: .Normal)
        dateEditbutton.addTarget(self, action: #selector(TextViewController.dateEditButtonTaped), forControlEvents: .TouchUpInside)
        
  
        editKeyBoardView = UIView(frame:CGRect(x: 0,y: 0,width: screenWidth,height: 50))
    
      
        editKeyBoardView?.addSubview(textFields!)
        //editKeyBoardView?.addSubview(todayButton)
        editKeyBoardView?.addSubview(dateEditbutton)
        editKeyBoardView?.addSubview(datePickerImageView!)
        
        textView.inputAccessoryView = editKeyBoardView

        
        self.textView.delegate = self
        
        self.navigationController?.navigationBar.barTintColor = colorFromRGB.colorWithHexString("0fb5c4")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

       
        
        //appdelegateを使うためにインスタンス化
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        //キーボードを立ち上げる
        self.textView.becomeFirstResponder()
        
        
        let OKButton = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: "okButtonTaped")
        self.navigationItem.rightBarButtonItem = OKButton
        
   

        
        
        
    textView.text = appDelegate?.textData
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        //ナビゲーションバーのタイトルは、日付の変更があれば、それを表示、なければ現在のノートの日付を表示。
        
        print("アド\(appDelegate?.addPhotoFlag)")
        if appDelegate?.addPhotoFlag == true{
            print("とこ")
            if appDelegate?.editDate != nil{
                
                let date = dateFormatter.stringFromDate((appDelegate?.editDate)!)
                self.title = date
                
            }else{
                
                print("はめこ")
                
                let realm = try!Realm()
                let editId = appDelegate?.editNoteId
                print(editId)
                let note = realm.objects(Note).filter("id = \(editId!)")
                
                
                let date = dateFormatter.stringFromDate(note[0].createDate!)
                
                self.title = date
                
            }
        }
        
        //新規ノートの場合
        if appDelegate?.noteFlag == true{
            
            // self.navigationController?.setNavigationBarHidden(true, animated: false)
            
        }else{
            
            
            if appDelegate?.textViewOfNoteDetail == false || appDelegate?.textViewOfNoteDetail == nil{
                let cancelButton = UIBarButtonItem(image: UIImage(named: "Delete Filled-50"), landscapeImagePhone:UIImage(named:"Delete Filled-50") , style: .Plain, target: self, action: "cancelButtonTaped")
                self.navigationItem.leftBarButtonItem = cancelButton
                
                if appDelegate?.editDate != nil{
                    
                    let date = dateFormatter.stringFromDate((appDelegate?.editDate)!)
                    self.title = date
                    
                }else{
                    
                    print("はめこ")
                    
                    let date = dateFormatter.stringFromDate(NSDate())
                    
                    self.title = date
                    
                }


            }
            
            print("レタス")
        }

        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "TextView")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 0, 8)
        self.textView.sizeToFit()
        
        self.textView.becomeFirstResponder()
        
        //キーボードの値をNSNotificationで取得
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keybordWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
    
    }
    
    func keybordWillChangeFrame(Notification:NSNotification){
        
        if let UserInfo = Notification.userInfo{
            
            let keyBoardVale:NSValue = UserInfo[UIKeyboardFrameEndUserInfoKey]! as! NSValue
            let keyBoradFrame:CGRect = keyBoardVale.CGRectValue()
            
            self.textViewBottomConst.constant = keyBoradFrame.height
            
        }
        
    }
    
    func okButtonTaped(){
        
        //ノートディテイルからならば。
        if appDelegate?.addPhotoFlag == true{
            print("ノートディテイル")
            let realm = try!Realm()
            let editId = appDelegate?.editNoteId
            print(editId)
            let note = realm.objects(Note).filter("id = \(editId!)")
            
            try!realm.write({ () -> Void in
                
                note[0].noteText = textView.text
                
                if appDelegate?.editDate != nil{
                    
                    note[0].createDate = appDelegate?.editDate
                    appDelegate?.editDate = nil
                    
                }
                
                realm.add(note)
            })
            
            appDelegate?.addPhotoFlag = false
            
            self.textView.resignFirstResponder()
            self.navigationController?.popViewControllerAnimated(true)
            
        }else{
           
            //新規追加ならば（タイムライン右上ボタン、タブバーのセンターボタン）
            print("ラブリー")
            let realm = try!Realm()
            let note = Note()
            
            let maxNote = realm.objects(Note).sorted("id", ascending: false)
            
            if maxNote.isEmpty{
                note.id = 1
            }else{
                note.id = maxNote[0].id + 1
            }
            
            //テストのため一時的にコメントアウト。必ず元に戻す。
            if appDelegate?.editDate != nil{
            
                note.createDate = appDelegate?.editDate
                appDelegate?.editDate = nil
                
            }else{
            
                note.createDate = NSDate()
            
            }
                
           /* let date:String = "2016-6-7 23:35:12"
             let dateformatter:NSDateFormatter = NSDateFormatter()
             dateformatter.locale = NSLocale(localeIdentifier: "ja")
             dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
             let changeDate = dateformatter.dateFromString(date)
             note.createDate = changeDate
             */
            

            
            note.noteText = textView.text
            
            
            note.modelName = ""
         
            try!realm.write({ () -> Void in
                realm.add(note, update: true)
            })
            
            appDelegate?.addPhotoFlag = false
            
            appDelegate?.noteFlag = true
            self.textView.resignFirstResponder()
            
            //新規作成→キャンセルからのコメント追加の場合
            if appDelegate?.cancelAdd == true{
                
                print("アーメンま")
                self.navigationController?.popViewControllerAnimated(true)
                appDelegate?.cancelAdd = false
                
            }else{
                
                print("nannn")
            self.dismissViewControllerAnimated(false, completion: nil)
            }

        }
        
        
       }
    
    func dateEditButtonTaped(){
    
        let navigation = UINavigationController()
        let vc =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("dateEdit")
        
        navigation.viewControllers = [vc]
        
        self.presentViewController(navigation, animated: true, completion: nil)
        
        /*
        if dateEditFlag == false{
            
            
            self.textFields?.becomeFirstResponder()
            datePickerImageView?.image = UIImage(named: "Ball Point Pen-48")
            dateEditFlag = true
        
        }else{
            
            
           
            self.textView.becomeFirstResponder()
            self.textFields?.resignFirstResponder()
            datePickerImageView?.image = UIImage(named: "Clock Filled-50")
            dateEditFlag = false
        }
         */
    
    }
    
    func todayButtonTaped(){
    
        datePicker.date = NSDate()
     print("むおお")
    }
    
    
    
     func cancelButtonTaped(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    override func viewWillDisappear(animated: Bool) {
  
 
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let viewControllers = self.navigationController?.viewControllers
        if indexOfArray(viewControllers!,searchObject:self) == nil{
            
            //戻る時だけ、addPhotoFlagをfalseにする
            appDelegate?.addPhotoFlag = false
            
            //戻る時だけ、cancelAddをfalseにする
            appDelegate?.cancelAdd = false
            
            appDelegate?.textViewOfNoteDetail = false
            
            appDelegate?.editDate = nil
            
        }

    }
    
    func indexOfArray(array:[AnyObject],searchObject:AnyObject)->Int?{
        
        
        for (index,value) in array.enumerate(){
            if value as! UIViewController == searchObject as! UIViewController{
                return index
                
            }
            
            
        }
        return nil
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

class dateEditTextField: UITextField {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        UIMenuController.sharedMenuController().menuVisible = false
        return false
    }
    
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        return CGRectZero
    }
    
}
