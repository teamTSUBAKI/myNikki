//
//  CalendarView.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/14.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

protocol ModalViewDelegate{
    
    func dayButtonTaped()
    
}


class CalendarView: UIView,UIScrollViewDelegate {
    
    var delegate:ModalViewDelegate!
    
    var currentYear:Int = 0
    var currentMonth:Int = 0
    var currentDay:Int = 0
    var scrollView:UIScrollView!
    var prevMonthView:MonthView!
    var currentMonthView:MonthView!
    var nextMonthView:MonthView!
    
    var photoCountView:UIView!
    var monthPhotoCount:UILabel!
    var allPhotoCount:UILabel!
    
    var yearAndMonthView:UIView!
    var yearAndManthLabel:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        let dateForMatter:NSDateFormatter = NSDateFormatter()
        dateForMatter.dateFormat = "yyyy/MM/dd"
        let dateString:String = dateForMatter.stringFromDate(NSDate())
        var dates:[String] = dateString.componentsSeparatedByString("/")
        currentYear = Int(dates[0])!
        currentMonth = Int(dates[1])!
        
        photoCountView = UIView(frame: CGRectMake(0,0,frame.size.width,40))
        photoCountView.backgroundColor = UIColor.clearColor()
        
        yearAndMonthView = UIView(frame: CGRectMake(0,40,frame.size.width,40))
        yearAndMonthView.backgroundColor = UIColor.clearColor()
        
        self.addSubview(photoCountView)
        self.addSubview(yearAndMonthView)
        
        let realm = try!Realm()
        
        let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        let targetDate:NSDate = calendar.dateWithEra(1, year: currentYear, month: currentMonth, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)!
        let lastday = getLastDay(currentYear, month: currentMonth)
        let lastTargetDate:NSDate = calendar.dateWithEra(1, year: currentYear, month: currentMonth, day:lastday!, hour: 23, minute: 59, second: 59, nanosecond: 0)!
        
        let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}",targetDate,lastTargetDate)
        let monthPhotos = realm.objects(Photos).filter(predicate)
        let allPhotos = realm.objects(Photos)
        
        monthPhotoCount = UILabel(frame: CGRectMake(photoCountView.frame.size.width/4.0-40,20,140,21))
        monthPhotoCount.textColor = UIColor.grayColor()
        monthPhotoCount.text = "今月：\(monthPhotos.count)フォト"
    
        
        allPhotoCount = UILabel(frame: CGRectMake(photoCountView.frame.size.width/4.0*3.0-70,20,150,21))
        allPhotoCount.textColor = UIColor.grayColor()
        allPhotoCount.text = "すべて：\(allPhotos.count)フォト"
        
        
        
        yearAndManthLabel = UILabel(frame:CGRectMake(yearAndMonthView.frame.size.width/2 - 30,20,70,21))
        yearAndManthLabel.text = "\(currentYear)"+"/"+"\(currentMonth)"
        yearAndManthLabel.textColor = UIColor.grayColor()
        
        photoCountView.addSubview(allPhotoCount)
        photoCountView.addSubview(monthPhotoCount)
        yearAndMonthView.addSubview(yearAndManthLabel)
        
        print(self.bounds)
        scrollView = UIScrollView(frame: CGRectMake(0,84,frame.size.width,frame.size.height))
        
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.contentSize = CGSizeMake(frame.size.width*3.0,frame.size.height)
        print("よこす\(frame.size.width * 3.0)")
        scrollView.contentOffset = CGPointMake(frame.size.width, 0.0)
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        self.addSubview(scrollView)
        
        //今月
        currentMonthView = MonthView(frame: CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height), year: currentYear, month: currentMonth)
    
        print("カレンダー今年\(currentYear)")
         print("カレンダー今月\(currentMonth)")
        
        //翌月
        var ret = self.getNextYearAndMonth()
        nextMonthView = MonthView(frame: CGRectMake(frame.size.width * 2.0, 0, frame.size.width, frame.size.height), year: ret.year, month: ret.month)
        
        //先月
        ret = self.getPrevYearAndMonth()
        prevMonthView = MonthView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height), year: ret.year, month: ret.month)
        
        scrollView.addSubview(currentMonthView)
        scrollView.addSubview(nextMonthView)
        scrollView.addSubview(prevMonthView)
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("スクロールず")
        let pos:CGFloat = scrollView.contentOffset.x / scrollView.bounds.width
        var deff:CGFloat = pos - 1.0
        
        if fabs(deff) >= 1.0{
            if (deff > 0){
                self.showNextView()
            }else{
                self.showPrevView()
                
            }
            
            
        }
        
    }
    
    //次の月にスクロールされたら
    func showNextView(){
        currentMonth++
        if (currentMonth > 12){
           
            currentMonth = 1
            currentYear++
        }
        
        //三つのUIViewの位置を入れ替える
        let tmpView:MonthView = currentMonthView
        currentMonthView = nextMonthView
        nextMonthView = prevMonthView
        prevMonthView = tmpView
        
        let ret = self.getNextYearAndMonth()
        nextMonthView.setUpDays(ret.year, month: ret.month)
        
        
        yearAndManthLabel.text = "\(currentYear)"+"/"+"\(currentMonth)"
        
        
        let realm = try!Realm()
        
        let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        print("表示中の月\(currentMonth)")
        let targetDate:NSDate = calendar.dateWithEra(1, year: currentYear, month: currentMonth, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)!
        let lastday = getLastDay(currentYear, month: currentMonth)
        let lastTargetDate:NSDate = calendar.dateWithEra(1, year: currentYear, month: currentMonth, day:lastday!, hour: 23, minute: 59, second: 59, nanosecond: 0)!
        
        let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}",targetDate,lastTargetDate)
        let monthPhotos = realm.objects(Photos).filter(predicate)
        
        monthPhotoCount.text = "今月：\(monthPhotos.count)フォト"

        
        //ポジショニング調整
        self.resetContentOffSet()
        
        
    }
    
    func showPrevView(){
        currentMonth--
        if (currentMonth == 0){
            currentMonth = 12
            currentYear--
            
        }
        
        let tmpView = currentMonthView
        currentMonthView = prevMonthView
        prevMonthView = nextMonthView
        nextMonthView = tmpView
        
        let ret = self.getPrevYearAndMonth()
        prevMonthView.setUpDays(ret.year, month: ret.month)
        
        yearAndManthLabel.text = "\(currentYear)"+"/"+"\(currentMonth)"
        
        let realm = try!Realm()
        
        let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        let targetDate:NSDate = calendar.dateWithEra(1, year: currentYear, month: currentMonth, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)!
        let lastday = getLastDay(currentYear, month: currentMonth)
        let lastTargetDate:NSDate = calendar.dateWithEra(1, year: currentYear, month: currentMonth, day:lastday!, hour: 23, minute: 59, second: 59, nanosecond: 0)!
        
        let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}",targetDate,lastTargetDate)
        let monthPhotos = realm.objects(Photos).filter(predicate)
        
        monthPhotoCount.text = "今月：\(monthPhotos.count)フォト"

        //ポジショニング調整
        self.resetContentOffSet()
    }
    
    //ポジショニング調整
    func resetContentOffSet(){
        prevMonthView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        currentMonthView.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)
        nextMonthView.frame = CGRectMake(frame.size.width * 2.0, 0, frame.size.width, frame.size.height)
        
        var scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
        //デリゲートを呼びたくないので、一時的にデリゲートを止める。
        scrollView.delegate = nil
        //スクロール位置を正面に。
        scrollView.contentOffset = CGPointMake(frame.size.width, 0.0)
        scrollView.delegate = scrollViewDelegate
    }
    
    func getNextYearAndMonth() -> (year:Int,month:Int){
        //基本的には来月も同じ年
        var next_year:Int = currentYear
        var next_month:Int = currentMonth + 1
        if next_month > 12{
            next_month = 1
            next_year++
        }
        
        return (next_year,next_month)
        
        
    }
    
    func getPrevYearAndMonth()-> (year:Int,month:Int){
        
        var prev_year:Int = currentYear
        var prev_month:Int = currentMonth - 1
        if prev_month == 0{
            prev_month = 12
            prev_year--
            
        }
        
        return (prev_year,prev_month)
        
    }
    
    func getLastDay(var year:Int,var month:Int)-> Int?{
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        if month == 12{
            month = 0
            year++
        }
        
        let targetDate:NSDate? = dateFormatter.dateFromString(String(format: "%04d/%02d/01", year,month+1))
        if targetDate != nil{
            //月初めから１日前を取得
            let orgdate:NSDate = NSDate(timeInterval: (60*60*24)*(-1), sinceDate: targetDate!)
            let str:String = dateFormatter.stringFromDate(orgdate)
        
            return Int((str as NSString).lastPathComponent)!
        }
        
        return nil
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
