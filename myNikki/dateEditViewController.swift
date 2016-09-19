//
//  dateEditViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/09/19.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class dateEditViewController: UIViewController {

    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePicker2: UIDatePicker!
    @IBOutlet weak var todayButton: UIButton!
    
     var appDelegate:AppDelegate?
    
    var date:String!
    var time:String!
    
    var dateFormatter:NSDateFormatter!
    var timeFormatter:NSDateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = colorFromRGB.colorWithHexString("0fb5c4")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //appdelegateを使うためにインスタンス化
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        
        
        datePicker.addTarget(self, action: #selector(dateEditViewController.datepickervalueChange), forControlEvents: UIControlEvents.ValueChanged)
        
        datePicker2.addTarget(self, action: #selector(dateEditViewController.datepickervalueChange_2), forControlEvents:UIControlEvents.ValueChanged )
        
        datePicker2.hidden = true

        dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier:"ja")
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale(localeIdentifier:"ja")
        timeFormatter.dateFormat =  "HH:mm"
        
        if appDelegate?.addPhotoFlag == true{
            print("とこ")
            let realm = try!Realm()
            let editId = appDelegate?.editNoteId
            
            let note = realm.objects(Note).filter("id = \(editId!)")
            
            datelabel.text = dateFormatter.stringFromDate(note[0].createDate!) + timeFormatter.stringFromDate(note[0].createDate!)
        }else{
       
             datelabel.text = dateFormatter.stringFromDate(NSDate()) + timeFormatter.stringFromDate(NSDate())
            
        }
        
       
       // timeLabel.text = timeFormatter.stringFromDate(NSDate())
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {

        if appDelegate?.addPhotoFlag == true{
            print("とこ")
            let realm = try!Realm()
            let editId = appDelegate?.editNoteId
            
            let note = realm.objects(Note).filter("id = \(editId!)")
            
            datePicker.date = note[0].createDate!
            datePicker2.date = note[0].createDate!
            
        }
    }
    
    func datepickervalueChange(sender:UIDatePicker){
    
      
        date = dateFormatter.stringFromDate(sender.date)
        time = timeFormatter.stringFromDate(datePicker2.date)
        
        datelabel.text = date + time
    }
    
    func datepickervalueChange_2(sender:UIDatePicker){
        
        
        date = dateFormatter.stringFromDate(datePicker.date)
        time = timeFormatter.stringFromDate(sender.date)
        
        datelabel.text = date + time
        
    }

    @IBAction func segmentTaped(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex {
        case 0:
        
            datePicker.hidden = false
            datePicker2.hidden = true
            
            
        case 1:
            
            datePicker.hidden = true
            datePicker2.hidden = false
            
        default:
            print("エラー")
        }
        
    }
   
    @IBAction func todayButtonTaped(sender: AnyObject) {
        
        datePicker.date = NSDate()
        datePicker2.date = NSDate()
        
        datelabel.text = dateFormatter.stringFromDate(NSDate()) + timeFormatter.stringFromDate(NSDate())
        //timeLabel.text = timeFormatter.stringFromDate(NSDate())
    }
    
    @IBAction func saveButtonTaped(sender: AnyObject) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let dateFormatt = NSDateFormatter()
        dateFormatt.dateFormat = "yyyy-MM-dd"
        let date = dateFormatt.stringFromDate(datePicker.date)
        
        let timeFormat = NSDateFormatter()
        timeFormat.dateFormat = "HH:mm:ss"
        let time = timeFormat.stringFromDate(datePicker2.date)
        
        let editDateString = "\(date) \(time)"
        
        let editDate:NSDate = dateFormatter.dateFromString(editDateString)!
        
        appDelegate!.editDate = editDate
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
       
        
    }
    
    @IBAction func cancelBUttonTAped(sender: AnyObject) {
        
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
