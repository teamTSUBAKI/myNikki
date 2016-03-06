//
//  TextViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/24.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class TextViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConst: NSLayoutConstraint!
    
    
        
    var appDelegate:AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.delegate = self
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()

       
        
        //appdelegateを使うためにインスタンス化
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        //キーボードを立ち上げる
        self.textView.becomeFirstResponder()
        
        
        let OKButton = UIBarButtonItem(title: "OK", style: .Plain, target: self, action: "okButtonTaped")
        self.navigationItem.rightBarButtonItem = OKButton
        
        if appDelegate?.noteFlag == true{
            
           // self.navigationController?.setNavigationBarHidden(true, animated: false)
            
        }else{
            
            if appDelegate?.cancelAdd == true{
             
               // self.navigationController?.setNavigationBarHidden(true, animated: false)
                
            }else{
            
            let cancelButton = UIBarButtonItem(image: UIImage(named: "Delete Filled-50"), landscapeImagePhone:UIImage(named:"Delete Filled-50") , style: .Plain, target: self, action: "cancelButtonTaped")
            self.navigationItem.leftBarButtonItem = cancelButton
            }
            
        }

        
        
        
    textView.text = appDelegate?.textData
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "TextView")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 0, 8)
        self.textView.sizeToFit()
        
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
            let realm = try!Realm()
            let editId = appDelegate?.editNoteId
            print(editId)
            let note = realm.objects(Note).filter("id = \(editId!)")
            
            try!realm.write({ () -> Void in
                note[0].noteText = textView.text
                realm.add(note)
            })
            
            appDelegate?.addPhotoFlag = false
            
            self.textView.resignFirstResponder()
            self.navigationController?.popViewControllerAnimated(true)
            
        }else{
           
            //新規追加ならば（タイムライン右上ボタン、タブバーのセンターボタン）
            let realm = try!Realm()
            let note = Note()
            
            let maxNote = realm.objects(Note).sorted("id", ascending: false)
            
            if maxNote.isEmpty{
                note.id = 1
            }else{
                note.id = maxNote[0].id + 1
            }
            
            note.createDate = NSDate()
            
            note.noteText = textView.text
            
            
            note.modelName = ""
         //   note.timerTime = ""
            
            try!realm.write({ () -> Void in
                realm.add(note, update: true)
            })
            
            appDelegate?.addPhotoFlag = false
            
            appDelegate?.noteFlag = true
            self.textView.resignFirstResponder()
            
            //新規作成→キャンセルからのコメント追加の場合
            if appDelegate?.cancelAdd == true{
                
                self.navigationController?.popViewControllerAnimated(true)
                appDelegate?.cancelAdd = false
                
            }else{
            self.dismissViewControllerAnimated(false, completion: nil)
            }

            
        }
        
        
        
        
               
    }
    
    func cancelButtonTaped(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
