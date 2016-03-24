//
//  CameraViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/11.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController,UIGestureRecognizerDelegate{

    
    
    var asset:PHFetchResult?
    
    var appDelegate:AppDelegate?
    
    var input:AVCaptureDeviceInput?
    var output:AVCaptureStillImageOutput?
    var session:AVCaptureSession?
    var preview:UIView?
    var CAMERA_FRONT:Bool = false
    
    var image:UIImage?
    
    var focusLayer:CALayer?
    var focusLayerSize:CGFloat = 50.0
    
    var adjustingExposure:Bool = false
    
    
    //閉じるボタン
    var closeButton:UIButton?
    //次へボタン
    var nextButton:UIButton?
    
    
    //保存ボタン
    var saveButton:UIButton?
    
    var takePhotoButton:UIBarButtonItem?
    
    //撮り直しボタン
    var retakeButton:UIButton?
    
    //前後カメラ切り替えボタン
    var changeCameraButton:UIButton?
    
    var takePhotoOverlay:UIImageView?
    
    var navigationBar:UINavigationBar?
    var toolBar:UIToolbar?
    
    
    deinit{
        AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo).removeObserver(self, forKeyPath: "adjustingExposure")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("やす")
        let tapGestureRecognizer:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: "taped:")
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)

        //AppDelegateを使うためにインスタンス化
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        appDelegate?.cameraViewFlag = true
        
        //背景を白に。なんで白にする必要があるんだろう？
        self.view.backgroundColor = UIColor.whiteColor()

        
        //ナビゲーションバー
        navigationBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width,44+20))
        navigationBar?.barStyle = .BlackTranslucent
        navigationBar?.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(navigationBar!)
        
      
        //閉じるボタン
        closeButton = UIButton()
        closeButton!.frame = CGRectMake(0, 0, 44, 44)
        closeButton!.setImage(UIImage(named:"Delete Filled-50"), forState:.Normal)
        closeButton?.addTarget(self, action:"closeButtonTaped", forControlEvents: .TouchUpInside)
        
        
        let barCloseButton = UIBarButtonItem(customView: closeButton!)
        
        
        
        //次へボタン
        nextButton = UIButton()
        nextButton!.frame = CGRectMake(0, 0, 44, 44)
        nextButton!.setTitle("次へ", forState: .Normal)
        nextButton!.addTarget(self, action: "nextButtonTaped", forControlEvents: .TouchUpInside)
        let barNextButton = UIBarButtonItem(customView: nextButton!)
        
        let naviItem:UINavigationItem = UINavigationItem(title: "Camera")
        
        //アルバム経由でないなら、閉じるボタンを表示。
        if appDelegate?.albumFlag != true{
        naviItem.leftBarButtonItems = [barCloseButton]
        }
        naviItem.rightBarButtonItems = [barNextButton]
        navigationBar!.setItems([naviItem], animated: false)
        
        //スペーズ
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        //撮影ボタン
        takePhotoButton = UIBarButtonItem(image: UIImage(named: "Compact Camera-52"),style: .Plain, target: self, action: "takePhoto:")
        
     
        
        //ツールバーを作成
        toolBar = UIToolbar(frame: CGRectMake(0,self.view.frame.size.height-80,self.view.frame.size.width,80))
        toolBar?.barStyle = .BlackTranslucent
        toolBar?.backgroundColor = UIColor.grayColor()
        toolBar?.tintColor = UIColor.whiteColor()
        toolBar!.items = [spacer,takePhotoButton!,spacer]
        
        self.view.addSubview(toolBar!)
        
        //撮影準備
        self.setupAVCapture()
        
        //フォーカスの準備
        self.focusInit()
       
        //撮影時のプレビュー。用意だけしておいて非表示にしている感じかな。
        takePhotoOverlay = UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        takePhotoOverlay!.contentMode = UIViewContentMode.ScaleAspectFill
        takePhotoOverlay!.alpha = 0.0
         self.view.addSubview(takePhotoOverlay!)
        
        //前後カメラ切替ボタン
        changeCameraButton = UIButton()
        changeCameraButton!.setImage(UIImage(named:"Synchronize-50"), forState: .Normal)
        changeCameraButton!.frame = CGRectMake(5, self.view.bounds.size.height-128, 44, 44)
        changeCameraButton!.addTarget(self, action:"changeButtonTaped", forControlEvents: .TouchUpInside)
        self.view.addSubview(changeCameraButton!)
        
      
        //保存ボタン
        saveButton = UIButton()
        saveButton!.setTitle("保存", forState: .Normal)
        saveButton!.frame = CGRectMake(self.view.bounds.size.width-110, self.view.bounds.size.height-100, 90, 44)
        saveButton?.layer.cornerRadius = 10
        saveButton?.layer.masksToBounds = true
        saveButton!.addTarget(self, action: "saveButtonTaped", forControlEvents: .TouchUpInside)
        saveButton!.backgroundColor = UIColor.blackColor()
        saveButton!.hidden = true
        self.view.addSubview(saveButton!)
        
        //取り直しボタン
        retakeButton = UIButton()
        retakeButton!.setTitle("撮り直し", forState: .Normal)
        retakeButton!.frame = CGRectMake(30, self.view.bounds.size.height-100, 90, 44)
        retakeButton?.layer.masksToBounds = true
        retakeButton?.layer.cornerRadius = 10
        retakeButton!.addTarget(self, action: "retakeButtonTaped", forControlEvents: .TouchUpInside)
        retakeButton!.backgroundColor = UIColor.blackColor()
        retakeButton!.hidden = true
        self.view.addSubview(retakeButton!)
    
        //Photosから全ての写真を取得
        self.getPhotosInfo()
       
    
        
       // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Camera")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject:AnyObject])
    }
    
    
    override func viewDidDisappear(animated: Bool) {
       
        
        for outpute in (self.session?.outputs)!{
            self.session?.removeOutput(outpute as! AVCaptureOutput)
        }
        
        for inpute in (session?.inputs)!{
            session?.removeInput(inpute as! AVCaptureInput)
        }
        
        //メモリの解放
        session?.stopRunning()

        
        
    
    
    }
    
    
    
    //Photosから全ての写真を取得
    func getPhotosInfo(){
    
       //photosAssetsを初期化
        appDelegate!.photosAssets = []
        //写真取得のオプション
        let options = PHFetchOptions()
        options.sortDescriptors = [
        NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        //全ての画像を取得
        asset = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        asset?.enumerateObjectsUsingBlock({ (asset, index, stop) -> Void in
                  self.appDelegate!.photosAssets.append(asset as! PHAsset)
        })
      
        
    }
    
   
    //カメラを準備
    func setupAVCapture(){
        
        //入力と出力からキャプチャーセッションを作成
        session = AVCaptureSession()
        
        var camera:AVCaptureDevice?
        for captureDevice:AnyObject in AVCaptureDevice.devices(){
            //背面カメラを取得
            if captureDevice.position == AVCaptureDevicePosition.Back{
                camera = captureDevice as? AVCaptureDevice
                
            }
        }
        
        do{
            try camera?.lockForConfiguration()
            
            //フォーカスモードの指定
            if ((camera?.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus)) != nil){
                //必要に応じてフォーカスモードになる
                camera?.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            }else if camera!.isFocusModeSupported(AVCaptureFocusMode.AutoFocus){
                //フォーカスがシーンの中心から外れてもフォーカスを維持
                camera?.focusMode = AVCaptureFocusMode.AutoFocus
            }
            
            if ((camera?.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure)) != nil){
                //必要に応じて露出を自動調整
                camera!.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            }else if camera!.isExposureModeSupported(AVCaptureExposureMode.AutoExpose){
                //露出変更（露出固定ではない）
                camera?.exposureMode = AVCaptureExposureMode.AutoExpose
                
            }
            camera?.unlockForConfiguration()
            
            
        }catch let error as NSError{
            print(error)
        }
        
        catch{
            print("Error")
        }
        
        //デバイスが露出の設定を変更しているかどうかはadjustingExposureプロパティでわかる
        camera?.addObserver(self, forKeyPath: "adjustingExposure", options: .New, context: nil)
        
            //カメラからの入力データ
            do{
                input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
            }catch let error as NSError{
                print(error)
                
            }
        
            catch{
                print("エラー")
        }
            
            if ((session?.canAddInput(input)) != nil){
                session?.addInput(input)
            }
            
            //静止画のインスタンスを生成
            output = AVCaptureStillImageOutput()
            //出力をセッションに追加
            if((session?.canAddOutput(output)) != nil){
                session?.addOutput(output)
                
            }
            //セッションからプレビューを表示
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = CGRectMake(0, navigationBar!.frame.origin.y+navigationBar!.frame.size.height, self.view.bounds.size.width,self.view.bounds.height-toolBar!.frame.size.height-(navigationBar!.frame.origin.y+navigationBar!.frame.size.height))
            
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            
            session?.startRunning()
            
            }
    
    //フォーカスの準備
    func focusInit(){
        self.focusLayer = CALayer()
        self.focusLayer?.borderColor = UIColor.whiteColor().CGColor
        self.focusLayer?.borderWidth = 1.0
        self.focusLayer?.frame = CGRectMake(self.view.center.x, self.view.center.y, focusLayerSize, focusLayerSize)
        
        self.focusLayer?.hidden = true
        
        self.view.layer.addSublayer(focusLayer!)
        
    }
    
    //前後切替ボタンが押されたら
    func changeButtonTaped(){
     CAMERA_FRONT = !CAMERA_FRONT
        var position:AVCaptureDevicePosition! = AVCaptureDevicePosition.Back
        if (CAMERA_FRONT){
            position = AVCaptureDevicePosition.Front
            }
        
        //セッションからinputの取り出し
        session!.removeInput(input)
        var camera:AVCaptureDevice?
        //デバイスを取得
        for captureDevice:AnyObject in AVCaptureDevice.devices(){
            if captureDevice.position == position{
                camera = captureDevice as? AVCaptureDevice
            }
        }
    
        
        do{
                input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
            }catch let error as NSError{
                print(error)
            }
        
        catch{
            print("error")
        }
            if ((session?.canAddInput(input)) != nil){
                session?.addInput(input)
            }
            
        
    }
    
    //写真を撮るボタンを押されたら
    func takePhoto(sender:AnyObject){
        AudioServicesPlaySystemSound(1108)
        if let connection:AVCaptureConnection? = output?.connectionWithMediaType(AVMediaTypeVideo){
            //ビデオ出力から画像を非同期で取得
            output?.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: {(imageDataBuffer,error) -> Void in
            //取得画像のimageDataBufferをjpegに変換
                let imagedata:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                //jpegからUIImageを生成
                 self.image = UIImage(data: imagedata)!
                
                self.onCompleteTakePhotos(self.image)
           
                
            })
            
        }
        
        
    }
    //画像撮影完了時
    func onCompleteTakePhotos(photoImage:UIImage?){
    
        //保存画像オーバーレイ
       takePhotoOverlay!.image = photoImage
       closeButton?.hidden = true
       nextButton?.hidden = true
       changeCameraButton?.hidden = true
       takePhotoButton!.enabled = false
        
        saveButton!.hidden = false
        retakeButton!.hidden = false
       
        UIView.animateWithDuration(0.2, animations:{
        
            self.takePhotoOverlay!.alpha = 1.0
            
        })
        
        
    }
    
    //取り直しボタン
    func retakeButtonTaped(){
    
        self.takePhotoOverlay!.alpha = 0.0
        self.takePhotoOverlay!.image = nil
        
        closeButton!.hidden = false
        nextButton!.hidden = false
        changeCameraButton!.hidden = false
        takePhotoButton!.enabled = true
        
        saveButton!.hidden = true
        retakeButton!.hidden = true
        
    }
    
    //保存ボタン
    func saveButtonTaped(){
        self.takePhotoOverlay!.alpha = 0.0
        self.takePhotoOverlay!.image = nil
        
        closeButton!.hidden = false
        nextButton!.hidden = false
        changeCameraButton!.hidden = false
        takePhotoButton!.enabled = true
        
        saveButton!.hidden = true
        retakeButton!.hidden = true

        //写真を保存する。保存できた時に、func image()を呼ぶ
        UIImageWriteToSavedPhotosAlbum(self.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
    }
    
    //写真が保存できたタイミングで呼ばれる
    func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:UnsafePointer<Void>){
        //今、保存した写真を取得
        self.getLastPhotosInfo()
        
        //保存したことを通知
        NSNotificationCenter.defaultCenter().postNotificationName("saved", object: nil)
           }

    
    func getLastPhotosInfo(){
    
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: options){
            if let asset:PHAsset = fetchResult.firstObject as? PHAsset{
                //撮影したばかりの写真を配列に入れる。
                appDelegate?.photosAssets.insert(asset, atIndex: 0)
        
                }
        }
    }
    
    //次に進むボタン
    func nextButtonTaped(){

        //アルバムからの画面遷移ならば、
        if appDelegate?.albumFlag == true{
        
                self.dismissViewControllerAnimated(true, completion: nil)
                appDelegate?.albumFlag = false
                appDelegate?.returnCamera = true
            
        
        }else{
            
             let PhotosAlbumView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("photos")
            let navigation = UINavigationController()
            navigation.viewControllers = [PhotosAlbumView]
            appDelegate!.textOrCameraFlag = true
            appDelegate?.returnCamera = false
            self.presentViewController(navigation, animated: false, completion: nil)
            
            
        }
        
     
    

        
    }
    
    
    func closeButtonTaped(){
        
        appDelegate?.tabBarCamera = false
        appDelegate?.cameraViewFlag = false
        appDelegate?.noPhotoButtonTaped = false
        appDelegate?.addPhotoFlag = false
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
       
        if keyPath == "adjustingExposure"{
     
            if !self.adjustingExposure{
                return
                
            }
            
    
            
            if change![NSKeyValueChangeNewKey]as! Bool == false{
                //falseの時、露出が変更中ではないので、露出を固定
                
                self.adjustingExposure = false
                let camera:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                
                do{
                    try camera.lockForConfiguration()
                    camera.exposureMode = AVCaptureExposureMode.Locked
                    camera.unlockForConfiguration()
                    
                }catch let error as NSError{
                    print(error)
                }
                
                catch{
                    print("error")
                }
            }
            
        }
        
    }
    
    func taped(sender:UITapGestureRecognizer){
        let point:CGPoint = sender.locationInView(sender.view)
        self.setFocusPoint(point)
        
    }
    
    func setFocusPoint(point:CGPoint){
        self.focusLayer?.frame = CGRectMake(point.x - focusLayerSize/2.0, point.y - focusLayerSize/2.0, focusLayerSize, focusLayerSize)
        self.focusLayer?.hidden = false
        
        let pointOfInterst:CGPoint = CGPointMake(point.y/self.view.bounds.size.height, 1.0 - point.x / self.view.bounds.size.width)
        let camera:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do{
            try camera.lockForConfiguration()
            
            if(camera.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) && camera.focusPointOfInterestSupported){
                
                camera.focusPointOfInterest = pointOfInterst
                
                camera.focusMode = AVCaptureFocusMode.AutoFocus
            }
            
            if (camera.exposurePointOfInterestSupported && camera.isExposureModeSupported(AVCaptureExposureMode.AutoExpose)){
                
                adjustingExposure = true
                //露出を指定。ここでは露出が変更中だと露出の変更ができないのでAoutにし、KVOでロックする
                camera.exposurePointOfInterest = pointOfInterst
                camera.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                
            }
            
            camera.unlockForConfiguration()
            
        }catch let error as NSError{
            print(error)
        }catch{
            print("error")
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
