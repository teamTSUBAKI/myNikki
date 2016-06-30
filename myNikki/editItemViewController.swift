//
//  editItemViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/23.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class editItemViewController: UIViewController,UITextViewDelegate {
    
    private var editItem:String?
    var editItemCatch:String?{
        
        get{
            return self.editItem
        }
        set(value){
            self.editItem = value
        }
        
        
    }
    
    private var editItemId:Int?
    var editItemIdCatch:Int?{
        
        get{
            
            return self.editItemId
            
        }
        set(value){
            
            self.editItemId = value
        }
    }
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = editItemCatch
        textView.becomeFirstResponder()
        
        let toolBar = UIToolbar(frame:CGRectMake(0,0,self.view.bounds.width,44))
        toolBar.barStyle = .Default
        
        let space = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace,target: self ,action:nil)
        let doneButton = UIBarButtonItem(title: "OK!",style: .Plain,target: self,action: "doneButtontaped")
        
        toolBar.items = [space,doneButton]
        
        textView.inputAccessoryView = toolBar
        textView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func doneButtontaped(){
        
        self.view.endEditing(true)
        editRealm()
        
    }
    
    func editRealm(){
        
        let realm = try!Realm()
        let editItem = realm.objects(WantItem).filter("id = \(editItemIdCatch!)").first
        
        try!realm.write({ 
            
            editItem?.editDate = NSDate()
            editItem?.wantName = textView.text
            
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
