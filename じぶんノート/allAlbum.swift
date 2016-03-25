//
//  allAlbum.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/22.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class allAlbum: UIView,UIScrollViewDelegate{
    
    var currentYear:Int = 0
    var currentMonth:Int = 0
    var scrollView:UIScrollView!
    var prevMonthAlbum:monthAlbum!
    var currentMonthAlbum:monthAlbum!
    var nextMonthAlbum:monthAlbum!
    
    var Notes:Results<(Note)>!
    var photoes:[String]!
    
    var startPoint:CGPoint!
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let dateString:String = dateFormatter.stringFromDate(NSDate())
        var dates:[String] = dateString.componentsSeparatedByString("/")
        currentYear = Int(dates[0])!
        currentMonth = Int(dates[1])!
        
        scrollView = UIScrollView(frame: CGRectMake(0,0,frame.size.width,3000))
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.contentSize = CGSizeMake(frame.size.width * 3.0, 3000)
    
        scrollView.contentOffset = CGPointMake(frame.size.width, 0.0)
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.scrollsToTop = false
        
        self.addSubview(scrollView)
        

        
            let realm = try!Realm()
        
            while 1 > 0{
                print("yui")
         
                
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                calendar?.timeZone = NSTimeZone(abbreviation: "GMT")!
                
                let startTarget:NSDate = (calendar?.dateWithEra(1, year: currentYear, month: currentMonth, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0))!
                
                let lastDay = self.getLastDay(currentYear,month: currentMonth)
                
                let lastTarget = calendar?.dateWithEra(1, year: currentYear, month: currentMonth, day: lastDay!, hour: 23, minute:59  , second: 59, nanosecond: 59)
                
                let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}", startTarget,lastTarget!)
                
                Notes = realm.objects(Note).filter(predicate).sorted("id", ascending: false)
                photoes = []

                
                if Notes.count > 0{
            
                    for ind in 1...Notes.count {
                
                    let Photo = Notes[ind-1].photos
                    print(Photo)
                
                    for photo in Photo{
                        print(photo.filename)
                        photoes.append(photo.filename)
                    
                        }
                
                    }
                }
                
                    if photoes.count != 0{
                    currentMonthAlbum = monthAlbum(frame: CGRectMake(frame.size.width,0,frame.size.width,500),year:currentYear,month:currentMonth)
                    print("今年\(currentYear)")
                    print("今月\(currentMonth)")
                    print(currentMonthAlbum)
                    break
                }else{
                    
                    print("角田")
                    
                    currentMonth--
                    
                }
                
                
            
        }
        
        
    
        
        //翌月
        var ret = self.getNextYearMonth()
        nextMonthAlbum = monthAlbum(frame: CGRectMake(frame.size.width * 2.0, 0, frame.size.width, 500), year: ret.year, month: ret.month)
        
        //前月
         ret = self.getPrevYearMonth()
         prevMonthAlbum = monthAlbum(frame: CGRectMake(0, 0, frame.size.width, 500), year: ret.year, month: ret.month)
        
        self.scrollView.addSubview(currentMonthAlbum)
        self.scrollView.addSubview(nextMonthAlbum)
        self.scrollView.addSubview(prevMonthAlbum)
    }


    
    func scrollViewDidScroll(scrollView: UIScrollView) {
     print("スクロール")
        
        
        let pos:CGFloat = scrollView.contentOffset.x / scrollView.bounds.width
        let deff:CGFloat = pos - 1.0
        if fabs(deff) >= 1.0{
            if (deff > 0){
                self.showNextMonth()
            }else{
                
                self.showPrevMonth()
            }
            
            
        }
        
    }
    
   
    
    func showNextMonth(){
        
        currentMonth++
        if(currentMonth > 12){
            
            currentMonth = 1
            currentYear++
            
        }
        
        let tmpView:monthAlbum = currentMonthAlbum
        currentMonthAlbum = nextMonthAlbum
        nextMonthAlbum = prevMonthAlbum
        prevMonthAlbum = tmpView
        
        let ret = getNextYearMonth()
        nextMonthAlbum.PhotoSet(ret.year, month: ret.month)
        
        //ポジション調整
        self.resetContentOffSet()
        
        
    }
    
    func showPrevMonth(){
    
        currentMonth--
        if(currentMonth == 0){
            
            currentMonth = 12
            currentYear--
            
        }
        
        let tmpView:monthAlbum = currentMonthAlbum
        currentMonthAlbum = prevMonthAlbum
        prevMonthAlbum = nextMonthAlbum
        nextMonthAlbum = tmpView
        
        let ret = getPrevYearMonth()
        prevMonthAlbum.PhotoSet(ret.year, month:ret.month )
        print("次のデータ\(ret.year)年\(ret.month)月")
        
        self.resetContentOffSet()
        

        
    }
    
    func resetContentOffSet(){
        prevMonthAlbum.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        currentMonthAlbum.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)
        nextMonthAlbum.frame = CGRectMake(frame.size.width * 2.0, 0, frame.size.width, frame.size.height)
        
        let scrollViewDelegate:UIScrollViewDelegate = scrollView.delegate!
        
        //一度デリゲートを解除してから、スクロール位置を元に戻す
        scrollView.delegate = nil
        scrollView.contentOffset = CGPointMake(frame.size.width, 0)
        scrollView.delegate = scrollViewDelegate
    }
    
    func getNextYearMonth() -> (year:Int,month:Int){
        
        var next_year:Int = currentYear
        var next_month:Int = currentMonth + 1
        if next_month > 12{
           
            next_month = 1
            next_year++
            
        }
        
        return (next_year,next_month)
    }
    
    func getPrevYearMonth()-> (year:Int,month:Int){
        
        var prev_Year:Int = currentYear
        var prev_Month:Int = currentMonth - 1
        
        if prev_Month == 0{
            prev_Month = 12
            prev_Year--
            
        }
        
        return (prev_Year,prev_Month)
    }
    
    func getLastDay(var year:Int,var month:Int) -> Int?{
        
        let dateForMatter = NSDateFormatter()
        dateForMatter.dateFormat = "yyyy/MM/dd"
        
        if month == 12{
            month = 0
            year++
            
        }
        
        let targetDate:NSDate? = dateForMatter.dateFromString(String(format: "%04d/%02d/1", year,month + 1))!
        
        if targetDate != nil{
            
            let orgDate = NSDate(timeInterval:(24 * 60 * 60) * (-1) , sinceDate: targetDate!)
            let str = dateForMatter.stringFromDate(orgDate)
            
            return Int((str as! NSString).lastPathComponent)!
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
