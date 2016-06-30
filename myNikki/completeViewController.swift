//
//  completeViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/24.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class completeViewController: UIViewController,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var wantDoneButtonView: UIView!
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var continueLabel: UILabel!
    
    @IBOutlet weak var wantItemNameLabel: UILabel!
    @IBOutlet weak var wantDoneMassageLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var photoAddLabel: UILabel!
    @IBOutlet weak var emptyPhotoImage: UIImageView!
    @IBOutlet weak var wantDoneImageView: UIImageView!
    
    @IBOutlet weak var continueButton: UIButton!
    //達成済みか
    var doneOrNotFlag = false
    //継続中か
    var continueOrNotFlag = false
    
    private var wantIds:Int?
    var wantItemId:Int?{
        
        get{
            
            return self.wantIds
            
        }
        set(value){
            
            self.wantIds = value
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar(frame:CGRectMake(0,0,self.view.bounds.width,44))
        toolBar.barStyle = .Default
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self,action: nil)
        
        let doneButtons = UIBarButtonItem(title: "完了",style:.Plain,target: self,action: "keyboardDoneTaped")
        
        toolBar.items = [space,doneButtons]
        
        
        memoTextView.inputAccessoryView = toolBar
        
        
        
        let realm = try!Realm()
        let wantsThing = realm.objects(WantItem).filter("id = \(wantIds!)").first
        
        doneOrNotFlag = (wantsThing?.done)!
        continueOrNotFlag = (wantsThing?.continues)!
        
        if wantsThing?.wantsDonePhotos.count != 0{
            
            //写真を表示
            
            
            
            //ラベルを非表示
            photoAddLabel.hidden = true
            emptyPhotoImage.hidden = true
            
        }else{
            
            photoAddLabel.hidden = false
            emptyPhotoImage.hidden = false
            
        }
        
        
        wantItemNameLabel.text = wantsThing?.wantName
        
        memoTextView.text = wantsThing?.doneMemo
        
        
        //達成済みなら
        if doneOrNotFlag == true{
            
            doneButton.setImage(UIImage(named: "Checked Filled-50 (1)"), forState: .Normal)
            
        }else{
            
            doneButton.setImage(UIImage(named: "Checked Filled-50"), forState: .Normal)
            
        }
        
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 5
        
      
        
        
        

        // Do any additional setup after loading the view.
    }

    
    @IBAction func saveButtonTaped(sender: AnyObject) {
        
        
        let realm = try!Realm()
        let wantItem = realm.objects(WantItem).filter("id = \(wantIds!)").first
        
        try!realm.write({ 
            
            
            wantItem?.done = doneOrNotFlag
            wantItem?.continues = continueOrNotFlag
            wantItem?.editDate = NSDate()
            wantItem?.doneMemo = memoTextView.text
            
        })
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        var path = ""
        
        if paths.count > 0{
            
            path = paths[0]
        }
        
        let fileName = NSUUID().UUIDString + ".jpg"
        let filePath = (path as NSString).stringByAppendingPathComponent(fileName)
        
        
        if wantDoneImageView.image != nil{
        
           let data = UIImageJPEGRepresentation(wantDoneImageView.image!, 0.8)
        
           if ((data?.writeToFile(filePath, atomically: true)) != nil){
            
 
            try!realm.write({
                
                let photos = realm.objects(wantsDonePhoto).sorted("id", ascending: false)
                let photo = wantsDonePhoto()
                
                if photos.count == 0{
                    
                    photo.id = 1
                    
                }else{
                    
                    photo.id = photos[0].id + 1
                    
                }
                
                photo.fileName = fileName
                photo.createdate = NSDate()
                
                wantItem?.wantsDonePhotos.append(photo)
                
               })
       
            
            
            
           }
            
        }
        
      
        
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
  
    @IBAction func wantDoneButton(sender: AnyObject) {
        
        //達成済みなら
        if doneOrNotFlag == true{
            
            wantDoneButtonView.backgroundColor = UIColor.lightGrayColor()
            wantDoneMassageLabel.text = "達成したらチェック！"
            wantDoneMassageLabel.textColor = UIColor.blackColor()
            doneButton.setImage(UIImage(named: "Checked Filled-50"), forState: .Normal)
            doneOrNotFlag = false
            
        }else{
            wantDoneButtonView.backgroundColor = UIColor.orangeColor()
            wantDoneMassageLabel.text = "おめでとう!"
            wantDoneMassageLabel.textColor = UIColor.whiteColor()
            doneButton.setImage(UIImage(named: "Checked Filled-50 (1)"), forState: .Normal)
            doneOrNotFlag = true
            
        }
        
    }

    @IBAction func continueButton(sender: AnyObject) {
        
        
        if continueOrNotFlag{
            
            continueView.backgroundColor = UIColor.lightGrayColor()
            continueLabel.text = "継続中ならこっちをチェック！"
            continueLabel.textColor = UIColor.blackColor()
            continueButton.setImage(UIImage(named: "Checked Filled-50"), forState: .Normal)
            continueOrNotFlag = false
            
        }else{
            
            continueView.backgroundColor = UIColor.orangeColor()
            continueLabel.text = "継続中！"
            continueLabel.textColor = UIColor.whiteColor()
            continueButton.setImage(UIImage(named: "Checked Filled-50 (1)"), forState: .Normal)
            
            continueOrNotFlag = true
            
        }
        
        
    }
    @IBAction func doneImageButtonTaped(sender: AnyObject) {
        
        
        let alert:UIAlertController = UIAlertController(title: "写真を記録！",message: "",preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",style: UIAlertActionStyle.Cancel,handler: {(action:UIAlertAction)->Void in
        
            
        })
        
        let cameraAction:UIAlertAction = UIAlertAction(title: "写真を撮る",style: UIAlertActionStyle.Default,handler: {(action:UIAlertAction)->Void in
            
            self.cameraStart()
        
        })
        
        let albumAction:UIAlertAction = UIAlertAction(title: "ライブラリから選択",style: UIAlertActionStyle.Default,handler: {(action:UIAlertAction)-> Void in
        
        
            self.albumStart()
        
        })
        
        let deletePhoto:UIAlertAction = UIAlertAction(title: "写真を削除",style: .Default,handler: {(action:UIAlertAction)->Void in
        
            self.photoDelete()
        
        })
        
        
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        
        if wantDoneImageView.image != nil{
            
            alert.addAction(deletePhoto)
            
        }
        
        presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    func photoDelete(){
        
        wantDoneImageView.image = nil
        emptyPhotoImage.hidden = false
        
        
    }
    
    func albumStart(){
        
      let library = UIImagePickerController()
      library.delegate = self
      library.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      self.presentViewController(library, animated: true, completion: nil)
        
        
    }
    
    
    func cameraStart(){
    
        let souceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        
        //カメラ使えるか
        if UIImagePickerController.isSourceTypeAvailable(souceType){
            
            let camera = UIImagePickerController()
            camera.sourceType = souceType
            camera.delegate = self
            self.presentViewController(camera, animated: true, completion: nil)
        
            
        }else{
            print("カメラ機能なし")
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let photoImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            wantDoneImageView.image = photoImage
            emptyPhotoImage.hidden = true
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func keyboardDoneTaped(){
    
        memoTextView.resignFirstResponder()
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
