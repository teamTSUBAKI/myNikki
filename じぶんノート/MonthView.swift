//
//  MonthView.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/14.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

protocol modalViewDelegate{
    
    func dayButtonTaped(buttonTag:Int)
    
}

class MonthView: UIView {
    

    var delegate:modalViewDelegate! = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect,year:Int,month:Int) {
        super.init(frame: frame)
        
        self.setUpDays(year,month:month)
    }

    func setUpDays(year:Int,month:Int){
        let subViews:[UIView] = self.subviews 
        for view in subViews{
            //よくわからないけど、おそらくMonthviewが持つviewがDayViewと被っているならば、重複しないように取り除いている感じだと思う。
            if view.isKindOfClass(DayView){
                view.removeFromSuperview()
                
            }
        }
        
        //その月の最終日の日付を取得する
        let lastDay:Int? = self.getLastDay(year,month:month)
        let dayWidth:Int = Int(frame.size.width/4.0)
        let dayHeight:Int = dayWidth + 5
        
        if lastDay != nil{
        
            var yCount = 0
            if lastDay < 29{
                yCount = 7
            }else{
                yCount = 8
            }
            
            let realm = try!Realm()
            
            let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            calendar.timeZone = NSTimeZone(abbreviation: "GMT")!
            //表示されている月の１日目をtargetDateにする。
            let targetDate:NSDate = calendar.dateWithEra(1, year:year , month: month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)!
            let lastTargetDate:NSDate = calendar.dateWithEra(1, year: year, month: month, day: lastDay!, hour: 0, minute: 0, second: 0, nanosecond: 0)!
            
            
            let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}",targetDate,lastTargetDate)
            //表示されている月のデータを取得した。
            let note = realm.objects(Note).filter(predicate)
            
            for var y = 0;y < yCount;{
                for var x = 0;x < 4;{
                    
                    let xPosition:Int = dayWidth * x
                    let yPosition:Int = dayHeight * y
                    
                    let frame:CGRect = CGRectMake(CGFloat(xPosition), CGFloat(yPosition), CGFloat(dayWidth),CGFloat(dayHeight))
                    
                    let days:Int = (x+1)+(y*4)
                    
                    if days <= lastDay{
                    
                    //ここでノートを日付で絞り込む。
                    let targetdate:NSDate = calendar.dateWithEra(1, year: year, month: month, day: days, hour: 0, minute: 0, second: 0, nanosecond: 0)!
                    let lastTargetdate:NSDate = calendar.dateWithEra(1, year: year, month: month, day: days, hour: 23, minute: 59, second: 59, nanosecond: 0)!
                    let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}", targetdate,lastTargetdate)
                    
                    let notes = note.filter(predicate)
                        var nots:[(Note)] = [(Note)]()
                        for notest in notes{
                            if notest.photos.isEmpty{
                                print("空")
                            }else{
                              nots.append(notest)
                                
                            }
                            
                        
                        }
                    
                
                    
                        if nots.isEmpty{
                            
                            let noPhoto:String = "nil"
                            let dayView:DayView = DayView(frame: frame, year: year, month: month, day:days,photo:noPhoto)
                            self.addSubview(dayView)
                            
                        }else{
                            
                            let photo:String = nots[0].photos[0].filename
                            let dayView:DayView = DayView(frame: frame, year: year, month: month, day: days, photo: photo)
                            
                            let dayButton = UIButton(frame:frame)
                            dayButton.addTarget(self, action: "buttonTaped:", forControlEvents: .TouchUpInside)
                            dayButton.tag = days
                         
                            self.addSubview(dayView)
                            self.addSubview(dayButton)
                        }
                    
                    
                    }else{
                        
                        print("空白")
                        
                    }
                    
                    x++
                }
                
                y++
            }
            
            
        }
        
        
    }
    
    func buttonTaped(button:UIButton){
    
        self.delegate.dayButtonTaped(button.tag)
        
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
            //月初めから１日前を計算し、月末の日付を取得する
            let orgDate = NSDate(timeInterval: (24*60*60)*(-1), sinceDate: targetDate!)
            let str:String = dateFormatter.stringFromDate(orgDate)
            
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
