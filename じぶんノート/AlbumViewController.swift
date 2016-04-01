//
//  AlbumViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/21.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController,toNoteDetailDelegate {
    
    
    var appDelegate:AppDelegate!
    var MonthAlbum:allAlbum!
    
    @IBOutlet weak var viewContainer: UIView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        MonthAlbum = allAlbum(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,2000))
        
        MonthAlbum.currentMonthAlbum.delegate = self
        MonthAlbum.nextMonthAlbum.delegate = self
        MonthAlbum.prevMonthAlbum.delegate = self
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.grayColor()]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "savePhoto", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: "deletePhoto", object: nil)
        
        self.viewContainer.addSubview(MonthAlbum)
        // Do any additional setup after loading the view.
    }

    func photoSelected(select: Photos) {
        
        appDelegate.noteFlag = false
        appDelegate.albumFlag = true
        performSegueWithIdentifier("Note", sender: select)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Note"{
            
            let vc = segue.destinationViewController as! NoteDetailViewController
            let photo = sender as! Photos
            vc.notes = photo.note[0]
            vc.photoNamaes = photo.filename
            vc.photoIds = photo.id
            
            }
    }
    
    func reload(){
        
        let subViews:[UIView] = self.viewContainer.subviews
        for view in subViews{
            
            if view.isKindOfClass(allAlbum){
                view.removeFromSuperview()
            }
            
        }
        
        MonthAlbum = allAlbum(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,2000))
        MonthAlbum.currentMonthAlbum.delegate = self
        MonthAlbum.nextMonthAlbum.delegate = self
        MonthAlbum.prevMonthAlbum.delegate = self
        
        self.viewContainer.addSubview(MonthAlbum)
    }
    
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
