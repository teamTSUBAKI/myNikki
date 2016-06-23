//
//  wantItemAddViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/23.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class wantItemAddViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
        textField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
        addItem.wantName = textField.text!
        
        try!realm.write({
            
            realm.add(addItem, update: true)
            
        })
        
        
        self.dismissViewControllerAnimated(true, completion: nil)

        return true
        
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
