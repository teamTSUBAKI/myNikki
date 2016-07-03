//
//  wantsListSettingViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/07/01.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class wantsListSettingViewController: UIViewController {
    
    
    private var wantListIds:Int?
    
    var wantListId:Int?{
        
        get{
            
            return wantListIds
        }
        
        set(value){
            
            wantListIds = value
            
        }
        
    }
    

    @IBOutlet weak var listNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "やりたいことリストの編集"

        
        let realm = try!Realm()
        let wantList = realm.objects(WantItemList).filter("id = \(wantListId!)").first
        
        listNameTextField.text = wantList?.listName
        listNameTextField.becomeFirstResponder()
        
        
        let saveButton = UIBarButtonItem(title: "保存",style: .Plain,target: self,action: "saveButtonTaped")
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.navigationController?.navigationBar.barTintColor = colorFromRGB.colorWithHexString("0fb5c4")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        // Do any additional setup after loading the view.
    }


    func saveButtonTaped() {
        
        if listNameTextField.text != ""{
        
            let realm = try!Realm()
            let wantList = realm.objects(WantItemList).filter("id = \(wantListId!)").first
        
            try!realm.write({
            
                wantList!.editDate = NSDate()
                wantList!.listName = listNameTextField.text!
            
            })
        
        }
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
