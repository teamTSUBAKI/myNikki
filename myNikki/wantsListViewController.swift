//
//  wantsListViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/19.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class wantsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    private let tableHeaderViewHeight:CGFloat = 300.0
    private let headerCutAway:CGFloat = 50.0
   
    @IBOutlet weak var headerView: UIView!
    
    private var headerMaskLayer:CAShapeLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: tableHeaderViewHeight,left: 0,bottom: 0,right: 0)
        tableView.contentOffset = CGPoint(x: 0,y: -tableHeaderViewHeight)
        
        updateHeaderView()
        
    }
    
    func updateHeaderView(){
        
        var headerRect = CGRect(x: 0,y: -tableHeaderViewHeight,width:tableView.bounds.width,height:tableHeaderViewHeight)
        
        if tableView.contentOffset.y < -tableHeaderViewHeight{
            
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
            
        }
        
        headerView.frame = headerRect
    }
  
    
 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
   
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:wantsListTableViewCell = tableView.dequeueReusableCellWithIdentifier("wantCell", forIndexPath: indexPath) as! wantsListTableViewCell
        
        return cell
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        updateHeaderView()
        
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
