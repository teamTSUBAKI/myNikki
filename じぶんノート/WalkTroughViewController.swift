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
    let pageNum = 2
    let pageImage:[Int:String] = [0:"4-inch (iPhone 5) - Screenshot 1",1:"4-inch (iPhone 5) - Screenshot 3"]
    var startButton:UIButton!
    var viewContainer:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print("ギットハブテスト")

       // getAllPhotos()
        
        let realm = try!Realm()
        let remind = realm.objects(Reminder)
       
        
        if remind.isEmpty{
            
            let reminder = Reminder()
            reminder.id = 1
            reminder.createDate = NSDate()
            
            let now = NSDate()
            let calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)
            let unit:NSCalendarUnit = [NSCalendarUnit.Year,.Month,.Day]
            let comps = calendar?.components(unit, fromDate: now)
            
            comps?.calendar = calendar
            comps?.hour = 21
            comps?.minute = 00
            
            reminder.Time = comps?.date
            //最初にオンにしてしまう
            reminder.repitition = 1
            
            try!realm.write({ 
                realm.add(reminder, update: true)
            })
        }
        
        
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
           }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "WalkTrough")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageProgress = Double(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControll.currentPage = Int(round(pageProgress))
        if self.pageControll.currentPage == 1{
            
            startButton.backgroundColor = colorFromRGB.colorWithHexString("4169e1")
            
          
        }
        
    }

    func startButtontaped(){
        getAllPhotos()
       /* PHPhotoLibrary.requestAuthorization { (info) in
            print("許可くん\(info)")
        }*/
        
        
       
        
        performSegueWithIdentifier("addReminder", sender: nil)
        
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
