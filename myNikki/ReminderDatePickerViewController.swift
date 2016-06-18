//
//  ReminderDatePickerViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/09.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class ReminderDatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        
        datePicker.date = remind[0].Time!
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "reminderSettingView")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        print("五右衛門")
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
        let reminder = Reminder()
        reminder.id = 1
        print("アベニュー\(datePicker.date)")
        reminder.Time = datePicker.date
        
        if remind[0].repitition == 0{
            reminder.repitition = 0
        }else{
            reminder.repitition = 1
        }
        
        try!realm.write({
            
            realm.add(reminder, update: true)
            
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
