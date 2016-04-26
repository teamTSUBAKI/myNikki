//
//  TabBarController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/10.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import Photos


class TabBarController: UITabBarController,UIActionSheetDelegate{

    var centerButton:UIButton?
    
    var asset:PHFetchResult?
    
    var appdelegate:AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey("firstLunch"){
            print("呼ぶ")
            self.selectedIndex = 0
            userDefaults.setBool(false, forKey: "firstLunch")
            
        }
        
        
        self.navigationController?.navigationBarHidden = true

      
        
        createRaisedCenterButton()
        // Do any additional setup after loading the view.
    }
    
    func getAllPhotos(){
        
        
        print("絶対零度")
        appdelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        appdelegate?.photosAssets = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        asset = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        asset?.enumerateObjectsUsingBlock({(asset,index,stop) -> Void in
        
            self.appdelegate?.photosAssets.append(asset as! PHAsset)
            
        })
        
        
    }

    func createRaisedCenterButton(){
        //センターボタンのイメージ画像
        let centerButtonImage = UIImage(named:"Compact Camera-52")
        //let centerHighLightButtonImage = UIImage(named:"Plus Filled-50")
        
        // ボタン生成
        centerButton = UIButton()
        centerButton!.frame = CGRectMake(0, 0, 60,40)
        centerButton?.backgroundColor = UIColor(red: 0, green: 0.7098, blue: 0.8667, alpha: 1.0)
        centerButton?.layer.cornerRadius = 5
        centerButton?.layer.masksToBounds = true
        centerButton!.tag = 1
        centerButton!.setImage(centerButtonImage, forState: .Normal)
        //centerButton!.setBackgroundImage(centerHighLightButtonImage, forState: .Highlighted)
        
        centerButton!.center = self.tabBar.center
        
        let centersButton = UIButton(frame: CGRectMake(0,0,80,50))
        centersButton.backgroundColor = UIColor.clearColor()
        centersButton.addTarget(self, action:"centerButtonTaped", forControlEvents: .TouchUpInside)
        centersButton.center = self.tabBar.center
        
        self.view.addSubview(centerButton!)
        self.view.addSubview(centersButton)
        
    }
    
    func centerButtonTaped(){
        
        //ユーザーのphotosの写真を取得
        self.getAllPhotos()
        
        let alert:UIAlertController = UIAlertController(title:"your choices!", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler:{(action:UIAlertAction)->Void in
        print("キャンセル")
        })
        
        let cameraAction:UIAlertAction = UIAlertAction(title: "カメラで撮影する", style:UIAlertActionStyle.Default, handler: {(action:UIAlertAction)->Void in
        
            let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            
            switch status{
            case AVAuthorizationStatus.Authorized:
                //許可されている場合
                let CameraViewControllers = self.storyboard?.instantiateViewControllerWithIdentifier("Camera")
                //タブバーから立ち上げたカメラということを伝える
                self.appdelegate?.tabBarCamera = true
                self.presentViewController(CameraViewControllers!, animated: true, completion:{()->Void in
                    
                    let vc:UINavigationController = self.viewControllers![0] as! UINavigationController
                    self.selectedViewController = vc
                    vc.popToRootViewControllerAnimated(false)
                    vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: nil)
                    
                })
                

            case AVAuthorizationStatus.Denied:
                //カメラの使用が禁止されている場合
                break;
            case AVAuthorizationStatus.NotDetermined:
                //まだ確認されていない場合、許可を求めるダイアログを表示
                print("やぁ")
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                    
                    if granted{
                        //許可された場合
                        let CameraViewControllers = self.storyboard?.instantiateViewControllerWithIdentifier("Camera")
                        //タブバーから立ち上げたカメラということを伝える
                        self.appdelegate?.tabBarCamera = true
                        self.presentViewController(CameraViewControllers!, animated: true, completion:{()->Void in
                            
                            let vc:UINavigationController = self.viewControllers![0] as! UINavigationController
                            self.selectedViewController = vc
                            vc.popToRootViewControllerAnimated(false)
                            vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: nil)
                            
                            })

                    
                    }else{
                        
                        print("不許可")
                        
                    }
                    
                })
               
            default:
                break
                
            }
            
            
            
            
        })
        let PhotosAction:UIAlertAction = UIAlertAction(title: "アルバムから選択する", style:UIAlertActionStyle.Default, handler: {(action:UIAlertAction)-> Void in
        
           let PhotoAlbumControllers = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("photos") as! PhotosAlbumViewController
            
            //  PhotoAlbumControllers.delegate = timeLineView
            let navigation = UINavigationController()
            navigation.viewControllers = [PhotoAlbumControllers]
            
         
            
            self.presentViewController(navigation, animated: false, completion:{()->Void in
            
             
                let vc:UINavigationController = self.viewControllers![0] as! UINavigationController
                self.selectedViewController = vc
                vc.popToRootViewControllerAnimated(false)
            
                //vc.pushViewController(noteDetail, animated: true)
                vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: nil)
            
            })
            
     })
        
        let noteAction:UIAlertAction = UIAlertAction(title: "ノートを書く", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction)->Void in
        
           let textViewControllers = self.storyboard?.instantiateViewControllerWithIdentifier("TextView")as! TextViewController
           let navigation = UINavigationController()
           navigation.viewControllers = [textViewControllers]
            self.presentViewController(navigation, animated: false, completion: {()->Void in
                
                let vc:UINavigationController = self.viewControllers![0] as! UINavigationController
                self.selectedViewController = vc
                vc.popViewControllerAnimated(false)
                vc.viewControllers[0].performSegueWithIdentifier("toNoteDetail", sender: nil)
        
            
            })
            
           
            
        })
        
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(PhotosAction)
        alert.addAction(noteAction)
        
        presentViewController(alert, animated: true, completion: nil)
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
