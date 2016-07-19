//
//  PhotoDetailViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/07.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift


class PhotoDetailViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    
 
    var path:String?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //var image = UIImage()
    //var photoId = 0
    
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        imageView.image = appDelegate.detailPhoto
        
        let photoDeleteButton = UIBarButtonItem(title: "削除", style: .Plain, target: self, action: "PhotoDeleteButtonTaped")
        self.navigationItem.rightBarButtonItem = photoDeleteButton
        
        let cancelButton = UIBarButtonItem(image: UIImage(named: "Delete Filled-50"), landscapeImagePhone:UIImage(named:"Delete Filled-50") , style: .Plain, target: self, action: "cancelButtonTaped")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()

        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count > 0{
            
            path = paths[0]
            
        }
        
        //self.tabBarController!.tabBar.hidden = true
        //self.tabBarController?.view.subviews[2].hidden = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "PhotoDetail")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
        
        imageSize()
        
    }
    
    func imageSize(){
    
        switch screenHeight{
            
        case 480:
            
            
            if imageView.image?.size.width <= imageView.image?.size.height{
                
        
                imageViewHeight.constant = screenHeight
                
            }else{
                
                imageViewHeight.constant =  230
       
            }
            
        case 568:
            
            
            //仮説:横位置の写真と縦位置の写真でサイズを変えてみる。
            if imageView.image?.size.width <= imageView.image?.size.height{
                
            
                 imageViewHeight.constant = screenHeight
                
            }else{
                
                  imageViewHeight.constant = 200
            
            }
            
            
            
            
        case 667:
            
            
            
            //仮説:横位置の写真と縦位置の写真でサイズを変えてみる。
            if imageView.image?.size.width < imageView.image?.size.height{
                
                imageViewHeight.constant = screenHeight
 
                
            }else if imageView.image?.size.width == imageView.image?.size.height{
                //スクエアならば

                imageViewHeight.constant = UIScreen.mainScreen().bounds.width
                
            }else{
                
                print("家主")
                imageViewHeight.constant = 270
 
                
            }
            
            
            
            
        case 736:
            
            
            
            if imageView.image?.size.width < imageView.image?.size.height{
          
                imageViewHeight.constant = screenHeight
                
            }else if imageView.image?.size.width == imageView.image?.size.height{
                
                
                imageViewHeight.constant = UIScreen.mainScreen().bounds.width
 
                
                
            }else{
                

                imageViewHeight.constant = 270
                
            }
            
        default:
            print("エラー")
            
            
        }

    
    
    }
    
    
    
    
    func PhotoDeleteButtonTaped(){
        
        //ここで必要なのは写真のid
        let realm = try!Realm()
        print("削除される写真のID\(appDelegate.detailPhotoId)")
        let deletePhoto = realm.objects(Photos).filter("id = \(appDelegate.detailPhotoId)")
        
        let filepath = (path! as NSString).stringByAppendingPathComponent(deletePhoto[0].filename)
        
        

        do{
        try NSFileManager.defaultManager().removeItemAtPath(filepath)
        }catch{
            print("エラー")
            
        }
        
        try!realm.write({ () -> Void in
            
            realm.delete(deletePhoto)
            
        })
        
        NSNotificationCenter.defaultCenter().postNotificationName("deletePhoto", object: nil)
        
        print("どーん")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
       
    
    func cancelButtonTaped(){
    
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        scrollView.contentInset.top = (scrollView.bounds.size.height - imageView.bounds.size.height)/2.0
        scrollView.contentInset.bottom = (scrollView.bounds.size.height - imageView.bounds.size.height)/2.0
        
        scrollView.setZoomScale(1, animated: false)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.1, animations: {
        
            self.imageView.alpha = 1
        
        })
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
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
