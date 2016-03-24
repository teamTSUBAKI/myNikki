//
//  AlbumViewController.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/21.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    
    
    @IBOutlet weak var viewContainer: UIView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let MonthAlbum:allAlbum = allAlbum(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,2000))
        
        self.viewContainer.addSubview(MonthAlbum)
        // Do any additional setup after loading the view.
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
