//
//  completeViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/24.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class completeViewController: UIViewController,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UITextViewDelegate{

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
    @IBOutlet weak var emptyPhotoView: UIView!
    
    @IBOutlet weak var placeHolderLabel: UILabel!
    var wantsThing:WantItem?
    
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var imagelabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    //達成済みか
    var doneOrNotFlag = false
    //継続中か
    var continueOrNotFlag = false
    
    var path = ""
    
    private var wantIds:Int?
    var wantItemId:Int?{
        
        get{
            
            return self.wantIds
            
        }
        set(value){
            
            self.wantIds = value
            
        }
    }
    
    
    
    var photoAddOrChangeFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        memoLabel.textColor = colorFromRGB.colorWithHexString("0fb5c4")
        imagelabel.textColor = colorFromRGB.colorWithHexString("0fb5c4")
        
        
        memoTextView.delegate = self
        
        let toolBar = UIToolbar(frame:CGRectMake(0,0,self.view.bounds.width,44))
        toolBar.barStyle = .Default
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: self,action: nil)
        
        let doneButtons = UIBarButtonItem(title: "完了",style:.Plain,target: self,action: "keyboardDoneTaped")
        
        toolBar.items = [space,doneButtons]
        
        
        memoTextView.inputAccessoryView = toolBar
        
        
        
        let realm = try!Realm()
        wantsThing = realm.objects(WantItem).filter("id = \(wantIds!)").first
        
        doneOrNotFlag = (wantsThing?.done)!
        continueOrNotFlag = (wantsThing?.continues)!
       
        //写真が登録されているならば
        if wantsThing?.wantsDonePhotos.count != 0{
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            if paths.count > 0{
                
                path = paths[0]
                
            }
            
            //写真を表示
            let filename = wantsThing?.wantsDonePhotos[0].fileName
            
            let filePath = (path as NSString).stringByAppendingPathComponent(filename!)
            
            let image = UIImage(contentsOfFile:filePath)
            
            wantDoneImageView.image = image
            
            
            //ラベルを非表示
            photoAddLabel.hidden = true
            emptyPhotoImage.hidden = true
            
        }else{
            
            emptyPhotoView.backgroundColor = colorFromRGB.colorWithHexString("F6FBF6")
            photoAddLabel.hidden = false
            emptyPhotoImage.hidden = false
            
        }
        
        
        
        
        wantItemNameLabel.text = wantsThing?.wantName
        
        if wantsThing?.doneMemo != ""{
        
            memoTextView.text = wantsThing?.doneMemo
            placeHolderLabel.hidden = true
        
        }else{
            
            placeHolderLabel.hidden = false
            
        }
     
        
        
        //達成済みなら
        if doneOrNotFlag == true{
            
            wantDoneMassageLabel.text = "実現！"
            wantDoneMassageLabel.textColor = UIColor.whiteColor()
            doneButton.setImage(UIImage(named: "Checked Filled-50 (1)"), forState: .Normal)
            wantDoneButtonView.backgroundColor = colorFromRGB.colorWithHexString("ffd700")
            
        }else{
            
            doneButton.setImage(UIImage(named: "Checked Filled-50"), forState: .Normal)
            wantDoneButtonView.backgroundColor = colorFromRGB.colorWithHexString("F6FBF6")
            
        }
        
        //継続中なら
        if continueOrNotFlag{
            continueView.backgroundColor = UIColor.orangeColor()
            continueLabel.text = "継続中！"
            continueLabel.textColor = UIColor.whiteColor()
            continueButton.setImage(UIImage(named: "Checked Filled-50 (1)"), forState: .Normal)
            

        
            
        }else{
            
            continueView.backgroundColor = colorFromRGB.colorWithHexString("F6FBF6")
            continueLabel.text = "継続中ならこっちをチェック！"
            continueLabel.textColor = UIColor.blackColor()
            continueButton.setImage(UIImage(named: "Checked Filled-50"), forState: .Normal)
            
        }
        
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 5
        saveButton.backgroundColor = colorFromRGB.colorWithHexString("0fb5c4")
        
      
        
        
        

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
        
        //写真があって、かつその写真が今回登録、変更されたならば
        if wantDoneImageView.image != nil && photoAddOrChangeFlag == true{
        
         
            //初めての写真登録ならば
            if wantsThing?.wantsDonePhotos.count == 0{
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
            
            }else{
               //すでに写真が登録されていて、変更された場合
                let deletePhoto = wantsThing?.wantsDonePhotos[0]
                let deletePhotoName = deletePhoto!.fileName
                let deleteFilePath = (path as NSString).stringByAppendingPathComponent(deletePhotoName)
                
                do{
                    try NSFileManager.defaultManager().removeItemAtPath(deleteFilePath)
                }catch{
                    print("エラー")
                    
                }
                
                try!realm.write({ 
                    
                    realm.delete(deletePhoto!)
                    
                })
                
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
                        
                        photo.createdate = NSDate()
                        photo.fileName = fileName
                        
                        wantItem!.wantsDonePhotos.append(photo)
                        
                    })
                    
                    
                }
                
                
            }
            
        }else{
            
            //写真がない状態ならば
            if wantDoneImageView.image == nil{
            let deletePhoto:wantsDonePhoto?
                
                if wantsThing?.wantsDonePhotos.count != 0{
                
                deletePhoto = wantsThing?.wantsDonePhotos[0]
                
                let deletePhotoName = deletePhoto?.fileName
                let deletePhotoPath = (path as NSString).stringByAppendingPathComponent(deletePhotoName!)
                    
                    do{
                        
                        try NSFileManager.defaultManager().removeItemAtPath(deletePhotoPath)
                        
                    }catch{
                        
                        print("エラー")
                    }
                
                     try!realm.write({
                    
                        realm.delete(deletePhoto!)
                       
                      })
                
                }
            }
            
            
        }
        
      
        
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
  
    @IBAction func wantDoneButton(sender: AnyObject) {
        
        //達成済みなら
        if doneOrNotFlag == true{
            
            wantDoneButtonView.backgroundColor = colorFromRGB.colorWithHexString("F6FBF6")
            wantDoneMassageLabel.text = "達成したらチェック！"
            wantDoneMassageLabel.textColor = UIColor.blackColor()
            doneButton.setImage(UIImage(named: "Checked Filled-50"), forState: .Normal)
            doneOrNotFlag = false
            
        }else{
            wantDoneButtonView.backgroundColor = colorFromRGB.colorWithHexString("ffd700")
           
            

            wantDoneMassageLabel.text = "実現！"
            wantDoneMassageLabel.textColor = UIColor.whiteColor()
            doneButton.setImage(UIImage(named: "Checked Filled-50 (1)"), forState: .Normal)
            doneOrNotFlag = true
            
        }
        
    }

    @IBAction func continueButton(sender: AnyObject) {
        
        
        if continueOrNotFlag{
            
            continueView.backgroundColor = colorFromRGB.colorWithHexString("F6FBF6")
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
        emptyPhotoView.backgroundColor = colorFromRGB.colorWithHexString("F6FBF6")
        emptyPhotoImage.hidden = false
        photoAddLabel.hidden = false
        
   
        
      
        
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
            photoAddOrChangeFlag = true
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func keyboardDoneTaped(){
    
        memoTextView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        placeHolderLabel.hidden = true
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if memoTextView.text == ""{
        
        
            placeHolderLabel.hidden = false
        
        }
        
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
