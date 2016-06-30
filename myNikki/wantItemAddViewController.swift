//
//  wantItemAddViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/23.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class wantItemAddViewController: UIViewController,UITextViewDelegate{

    
    @IBOutlet weak var textView: UITextView!
    
    var delegate:addWantDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar(frame: CGRectMake(0,0,self.view.bounds.width,44))
        toolBar.barStyle = .Default
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self,action: nil)
        let doneBarButton = UIBarButtonItem(title:"OK!",style: .Plain,target:self,action:"doneButtonTaped")
      
        
        toolBar.items = [space,doneBarButton]
        
        textView.inputAccessoryView = toolBar
        
        textView.becomeFirstResponder()
        textView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func doneButtonTaped(){
    
        self.view.endEditing(true)
        addRealm()
    }
    
    func addRealm(){
        
        let realm = try!Realm()
        let wantItems = realm.objects(WantItem).sorted("id", ascending: false)
        
        let addItem = WantItem()
        
        if wantItems.isEmpty{
            
            addItem.id = 1
            
        }else{
            
            addItem.id = wantItems[0].id + 1
            
        }
        
        addItem.createDate = NSDate()
        addItem.done = false
        addItem.wantName = textView.text!
        
        try!realm.write({
            
            realm.add(addItem, update: true)
            
        })
        
        self.delegate.addRandomNumber()
        
        
        self.dismissViewControllerAnimated(true, completion: {
        

        
        
        })

        
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
