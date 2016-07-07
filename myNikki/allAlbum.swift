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
    
    var yearAndMonthLabel:UILabel!
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
   
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
       
        if appDelegate.nowYear == nil{
        let dateString:String = dateFormatter.stringFromDate(NSDate())
        var dates:[String] = dateString.componentsSeparatedByString("/")
        currentYear = Int(dates[0])!
        currentMonth = Int(dates[1])!
        }else{
            currentYear = appDelegate.nowYear
            currentMonth = appDelegate.nowMonth
            
        }
            
        yearAndMonthLabel = UILabel(frame: CGRectMake(0,4,frame.size.width,30))
        yearAndMonthLabel.textAlignment = NSTextAlignment.Center
        yearAndMonthLabel.text = "\(currentYear)/\(currentMonth)"
        yearAndMonthLabel.textColor = UIColor.grayColor()
        yearAndMonthLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17)
        self.addSubview(yearAndMonthLabel)
        
        
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
        
        
        
        
        
        currentMonthAlbum = monthAlbum(frame: CGRectMake(frame.size.width,0,frame.size.width,500),year:currentYear,month:currentMonth)
       
    

        
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
        
        yearAndMonthLabel.text = "\(currentYear)/\(currentMonth)"
        
        appDelegate.nowYear = currentYear
        appDelegate.nowMonth = currentMonth
        
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
        
        yearAndMonthLabel.text = "\(currentYear)/\(currentMonth)"
        
        appDelegate.nowYear = currentYear
        appDelegate.nowMonth = currentMonth
        
        let ret = getPrevYearMonth()
        prevMonthAlbum.PhotoSet(ret.year, month:ret.month )
        
        
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
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}