//
//  WalkTroughViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/02/09.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class WalkTroughViewController: UIPageViewController,UIScrollViewDelegate {

    var appdelegate:AppDelegate!
    var asset:PHFetchResult?
    
    var reminderImageView:UIImageView!
    var remindTitleLabel:UILabel!
    var subTextLabel:UILabel!
    
    var reminderButton:UIButton!
  
    let screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
   
    
    
    var descriptionTextView:UITextView!
    var scrollView:UIScrollView!
    var pageControll:UIPageControl!
    let pageNum = 6
    let pageImage:[Int:String] = [1:"4-inch (iPhone 5) - Screenshot 3",0:"4-inch (iPhone 5) - Screenshot 1",3:"4-inch (iPhone 5) - Screenshot 5",4:"4-inch (iPhone 5) - Screenshot 2",5:"4-inch (iPhone 5) - Screenshot 4"]
    var startButton:UIButton!
    var viewContainer:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print("ギットハブテスト")

       // getAllPhotos()
        
        self.view.backgroundColor = colorFromRGB.colorWithHexString("B0C4DE")
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.width * CGFloat(pageNum),self.view.bounds.height)
        self.scrollView.pagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        self.viewContainer = UIView(frame: CGRectMake(0,self.view.bounds.height-150,self.view.bounds.width,200))
        viewContainer.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(viewContainer)
        
        self.startButton = UIButton(frame: CGRectMake(0,0,self.view.bounds.width - 40,44))
        startButton.backgroundColor = colorFromRGB.colorWithHexString("d3d3d3")
        startButton.tintColor = UIColor.whiteColor()
        startButton.addTarget(self, action: "startButtontaped", forControlEvents: .TouchUpInside)
        startButton.center = CGPointMake(self.view.bounds.width/2,self.view.bounds.height-100)
        startButton.setTitle("はじめる", forState: .Normal)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 10
        self.view.addSubview(startButton)
        
        self.pageControll = UIPageControl(frame: CGRectMake(0,self.view.bounds.height-50,self.view.bounds.width,50))
        self.pageControll.numberOfPages = pageNum
        self.pageControll.currentPage = 0
        self.pageControll.pageIndicatorTintColor = UIColor.lightGrayColor()
        self.pageControll.currentPageIndicatorTintColor = UIColor.grayColor()
        
        self.view.addSubview(self.pageControll)
        
        for p in 1...pageNum{
            
            
            if p != 3{
            
            //titleLabel.hidden = true
            //descroptionLabel.hidden = true
            
               switch screenHeight{
                
                case 480:
                 let v = UIImageView(frame: CGRectMake(self.view.bounds.width * CGFloat(p-1),20,self.view.bounds.width,self.view.bounds.height-150))
                 v.image = UIImage(named: pageImage[p-1]!)
                 v.backgroundColor = colorFromRGB.colorWithHexString("B0C4DE")
                 v.contentMode = UIViewContentMode.ScaleAspectFit
                 self.scrollView.addSubview(v)
               
                case 568:
                 let v = UIImageView(frame: CGRectMake(self.view.bounds.width * CGFloat(p-1) , 70, self.view.bounds.width, self.view.bounds.height - 170))
                 v.image = UIImage(named: pageImage[p-1]!)
                 v.backgroundColor = colorFromRGB.colorWithHexString("B0C4DE")
                 v.contentMode = UIViewContentMode.ScaleAspectFit
                self.scrollView.addSubview(v)
                
                case 667:
                let v = UIImageView(frame: CGRectMake(self.view.bounds.width * CGFloat(p-1) , 70, self.view.bounds.width, self.view.bounds.height - 200))
                v.image = UIImage(named: pageImage[p-1]!)
                v.backgroundColor = colorFromRGB.colorWithHexString("B0C4DE")
                v.contentMode = UIViewContentMode.ScaleAspectFit
                self.scrollView.addSubview(v)
                
                case 736:
                let v = UIImageView(frame: CGRectMake(self.view.bounds.width * CGFloat(p-1) , 70, self.view.bounds.width, self.view.bounds.height - 200))
                v.image = UIImage(named: pageImage[p-1]!)
                v.backgroundColor = colorFromRGB.colorWithHexString("B0C4DE")
                v.contentMode = UIViewContentMode.ScaleAspectFit
                self.scrollView.addSubview(v)

                default:
                print("エラー")
                }
           
            }else{
                
                reminderImageView = UIImageView(frame:CGRectMake(self.view.bounds.width * 2, 0, self.view.bounds.width, self.view.bounds.height))
                reminderImageView.image = UIImage(named: "mockDrop_iPhone 6")
                reminderImageView.contentMode = .ScaleAspectFill
                reminderImageView.clipsToBounds = true
                reminderImageView.center = CGPointMake(self.view.bounds.width * 2.5, 270)
                
                switch screenHeight{
                    
                case 480:
                    remindTitleLabel = UILabel(frame:CGRectMake(self.view.bounds.width * 2,0,self.view.bounds.width,44))

                    
                case 568:
                    
                    remindTitleLabel = UILabel(frame:CGRectMake(self.view.bounds.width * 2,0,self.view.bounds.width,44))

                    
                case 667:
                    remindTitleLabel = UILabel(frame:CGRectMake(self.view.bounds.width * 2,50,self.view.bounds.width,100))
                    remindTitleLabel.font = UIFont(name: "HiraKakuProN-W6",size: 23)
                    
                    subTextLabel = UILabel(frame: CGRectMake(self.view.bounds.width * 2,80,self.view.bounds.width,100))
                    subTextLabel.font = UIFont(name: "HiraKakuProN-W3",size:20)
                    
                    reminderButton = UIButton(frame: CGRectMake(0,0,self.view.bounds.width - 40,60))
                    reminderButton.backgroundColor = colorFromRGB.colorWithHexString("00d1aa")
                    reminderButton.tintColor = UIColor.whiteColor()
                    reminderButton.addTarget(self, action: "remindButtonTaped", forControlEvents: .TouchUpInside)
                    reminderButton.center = CGPointMake(self.view.bounds.width * 2 + self.view.bounds.width/2,470)
                    reminderButton.setTitle("リマインドする", forState: .Normal)
                    reminderButton.titleLabel?.font = UIFont(name:"HiraKakuProN-W6" ,size:20)
                    reminderButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    reminderButton.layer.masksToBounds = true
                    reminderButton.layer.cornerRadius = 10
                    
                case 736:
                    remindTitleLabel = UILabel(frame:CGRectMake(self.view.bounds.width * 2,0,self.view.bounds.width,44))

                default:
                    print("エラー")
                }

                
                remindTitleLabel.textAlignment = .Center
                remindTitleLabel.text = "リマインダー"
                remindTitleLabel.textColor = UIColor.whiteColor()
                
                subTextLabel.text = "ノートの書き忘れを防止できます"
                subTextLabel.textAlignment = .Center
                subTextLabel.textColor = UIColor.whiteColor()
                
                self.scrollView.addSubview(reminderImageView)
                self.scrollView.addSubview(remindTitleLabel)
                self.scrollView.addSubview(subTextLabel)
                self.scrollView.addSubview(reminderButton)
                
            }
        
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "WalkTrough")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    
    func remindButtonTaped(){
    
        let realm = try!Realm()
        let reminder = Reminder()
        reminder.createDate = NSDate()
        reminder.id = 1
        reminder.repitition = 1
        
        let now = NSDate()
        let calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day]
        let comps = calendar?.components(unit, fromDate: now)
        
        comps?.calendar = calendar
        comps?.hour = 21
        comps?.minute = 00
        
        reminder.Time = comps?.date
        
        try!realm.write({ 
            realm.add(reminder, update: true)
        })
        
        //scrollView.contentOffset = CGPointMake(self.view.bounds.width * 3, 0)
        scrollView.scrollRectToVisible(CGRectMake(self.view.bounds.width * 3.0, 0, self.view.bounds.width, self.view.bounds.height), animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageProgress = Double(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControll.currentPage = Int(round(pageProgress))
        if self.pageControll.currentPage == 5{
            
            startButton.backgroundColor = colorFromRGB.colorWithHexString("4169e1")
            
        }
        
    }

    func startButtontaped(){
        getAllPhotos()
       /* PHPhotoLibrary.requestAuthorization { (info) in
            print("許可くん\(info)")
        }*/
        
        performSegueWithIdentifier("toStart", sender: nil)
        
    }
    
    func getAllPhotos(){
        
        
        print("写真を入れたよ")
        appdelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        appdelegate?.photosAssets = []
        var pho = [PHAsset]()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        asset = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        asset?.enumerateObjectsUsingBlock({(asset,index,stop) -> Void in
            
            //self.appdelegate?.photosAssets.append(asset as! PHAsset)
            pho.append(asset as! PHAsset)
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
