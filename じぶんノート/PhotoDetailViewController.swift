//
//  PhotoDetailViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/01/07.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyDropbox

class PhotoDetailViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var path:String?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //var image = UIImage()
    //var photoId = 0
    
    
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
        
    }
    
    func PhotoDeleteButtonTaped(){
        
        //ここで必要なのは写真のid
        let realm = try!Realm()
        print("削除される写真のID\(appDelegate.detailPhotoId)")
        let deletePhoto = realm.objects(Photos).filter("id = \(appDelegate.detailPhotoId)")
        
        let filepath = (path! as NSString).stringByAppendingPathComponent(deletePhoto[0].filename)
        
        if let client = Dropbox.authorizedClient{
            
            client.files.delete(path: "/\(deletePhoto[0].filename)").response({ (response, error) -> Void in
                
                if let metadata = response{
                    
                    print("delete file name:\(metadata)")
                    
                }else{
                    
                    print(error)
                }
                
            })
            
        }
        
        //ここでrealmデータをドロップボックスにアップロード
        uploadRealmToDrpbox()
        
        print(deletePhoto)
        
        do{
        try?NSFileManager.defaultManager().removeItemAtPath(filepath)
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
    
    func uploadRealmToDrpbox(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if paths.count > 0{
            path = paths[0]
        }
        
        let documentURL = NSURL(fileURLWithPath: path!)
        let fileURL = documentURL.URLByAppendingPathComponent("default.realm")
        
        if let client = Dropbox.authorizedClient{
            client.files.upload(path: "/default.realm", mode: Files.WriteMode.Overwrite, autorename: true, clientModified: NSDate(), mute: false, body: fileURL).response({ (response, error) -> Void in
                
                if let metadata = response{
                    print("uploaded file \(metadata)")
                }else{
                    print(error!)
                }
                
                
            })
            
        }

        
        
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
