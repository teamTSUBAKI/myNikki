//
//  DayView.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/14.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

/*protocol modalViewDelegate{
    
    func buttonTaped()
    
}*/

class DayView: UIView {
    
    var path:String?
    //var dayButton:UIButton?
    //var delegate:modalViewDelegate! = nil
    
    //ここが決まり文句的な感じかな？
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect,year:Int,month:Int,day:Int, photo:String) {
        super.init(frame: frame)
        
        
        
        let dayWidth:Int = Int((UIScreen.mainScreen().bounds.size.width)/4.0)
        let dayHeight:CGFloat = CGFloat(dayWidth)
       // dayButton = UIButton(frame: CGRectMake(0,0,CGFloat(dayWidth),dayHeight))
        //dayButton?.addTarget(self, action: Selector("buttonTaped"), forControlEvents: .TouchUpInside)
        let dayPhoto:UIImageView = UIImageView(frame: CGRectMake(0, 0, CGFloat(dayWidth), dayHeight))
        dayPhoto.contentMode = UIViewContentMode.ScaleAspectFill
        dayPhoto.clipsToBounds = true
        let dayLabel:UILabel  = UILabel(frame: CGRectMake(0,20,CGFloat(dayWidth),dayHeight))
        dayLabel.textAlignment = NSTextAlignment.Center
        dayLabel.text = String(format: "%02d", day)
        
        if photo == "nil"{
            
            dayLabel.textColor = UIColor.grayColor()
            
        }else{
            
            dayLabel.textColor = UIColor.whiteColor()
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        
        
        if paths.count > 0{
            
            path = paths[0]
        
        }
        
        let filePaths = (path! as NSString).stringByAppendingPathComponent(photo)
        let image = UIImage(contentsOfFile: filePaths)
        
        dayPhoto.image = image
        
        self.addSubview(dayPhoto)
        //self.addSubview(dayButton!)
        self.addSubview(dayLabel)
        
    }
    
   

    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
