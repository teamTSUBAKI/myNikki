//
//  CalendarViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/14.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController,modalViewDelegate{

       @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerHeight: NSLayoutConstraint!
    
    
    var calendarView:CalendarView!
    let photo = Photos()
    
    let screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("更新")
        
        self.viewContainerHeights()
        
        calendarView = CalendarView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,1000))
        calendarView.currentMonthView.delegate = self
        calendarView.nextMonthView.delegate = self
        calendarView.prevMonthView.delegate = self
        
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.viewContainer.addSubview(calendarView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "savePhoto", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "deletePhoto", object: nil)
        
      
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Calendar")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    
    func viewContainerHeights(){
        
        switch screenHeight{
        case 480:
            viewContainerHeight.constant = 800
        case 568:
            viewContainerHeight.constant = 800
        case 667:
            viewContainerHeight.constant = 900
        case 736:
            viewContainerHeight.constant = 1000
            
        default:
            print("エラー")
            
            
        }
        
    }
    
    func reload(){
        print("リロードさん")
        let subViews:[UIView] = self.viewContainer.subviews
        
        for view in subViews{
            
            if view.isKindOfClass(CalendarView){
                
                view.removeFromSuperview()
                
            }
            
        }
        
        calendarView = CalendarView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,1000))
        calendarView.currentMonthView.delegate = self
        calendarView.nextMonthView.delegate = self
        calendarView.prevMonthView.delegate = self
        
        
        self.viewContainer.addSubview(calendarView)
        
        
        
    }
    
    /* override func viewWillAppear(animated: Bool) {
      
        let subViews:[UIView] = self.viewContainer.subviews
        
        for view in subViews{
            
            if view.isKindOfClass(CalendarView){
                
                view.removeFromSuperview()
                
            }
            
        }
        
        calendarView = CalendarView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,1000))
        calendarView.currentMonthView.delegate = self
        calendarView.nextMonthView.delegate = self
        calendarView.prevMonthView.delegate = self
        
        
        self.viewContainer.addSubview(calendarView)
    }*/
    
    func dayButtonTaped(button:Int) {
        //タイムラインに画面遷移
          performSegueWithIdentifier("toTimeLine", sender: button)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toTimeLine"{
        
            let vc = segue.destinationViewController as! timeLineViewController
            if let tag = sender as? Int{
                
                vc.year = calendarView.currentYear
                vc.month = calendarView.currentMonth
                vc.day = tag
                
            }
            
            
        }
        
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
