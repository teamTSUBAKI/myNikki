//
//  wantsListViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/19.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class wantsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    private let tableHeaderViewHeight:CGFloat = 300.0
    
   
    @IBOutlet weak var headerView: UIView!
    var emptyHeader:UIView!
  
    var addButton:UIButton!
    
    var wantThings:Results<WantItem>?{
       
        do{
            
            let realm = try!Realm()
            return realm.objects(WantItem)
            
        }catch{
            
            print("エラー")
        }
        
        return nil
        
    }
    
    var emptyLabel:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ヘッダービューを追加
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        
        //データがないとき用のヘッダービューと同じものを生成
         emptyHeader = NSBundle.mainBundle().loadNibNamed("emptyHeaderView", owner: self, options: nil)[0] as! UIView
        emptyHeader.frame = CGRectMake(0, 0, self.view.bounds.width, 300)
        
        self.view.addSubview(emptyHeader)
        
        
        emptyLabel = UILabel()
        emptyLabel.text = "やっちゃえ、日産！！"
        emptyLabel.frame = CGRectMake(0, 300, 300, 60)
        emptyLabel.textAlignment = .Center
        
        self.view.addSubview(emptyLabel)
        
    
        //リストに追加するためのボタンを表示
        addButton = UIButton()
        addButton.frame = CGRectMake(300, 550, 44, 44)
        addButton.backgroundColor = UIColor.orangeColor()
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 20
        addButton.alpha = 0.8
        addButton.setTitle("+", forState: .Normal)
        addButton.titleLabel?.font = UIFont.systemFontOfSize(32)
        addButton.addTarget(self, action: Selector("addWantItem"), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(addButton)
        
        //ナビゲーションを透明にしたい
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
 
        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()

        
        
        
       // tableView.contentInset = UIEdgeInsets(top: tableHeaderViewHeight,left: 0,bottom: 0,right: 0)
        //tableView.contentOffset = CGPoint(x: 0,y: -tableHeaderViewHeight)
        
        
  
        tableView.reloadData()
        
        //上にスクロールした時にヘッダーのサイズを大きくして画像を拡大する。
        updateHeaderView()
        
    }
    

    func addWantItem(){
    
        
        let wantItemAddControllers:wantItemAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("wantItemAdd") as! wantItemAddViewController
        
        self.presentViewController(wantItemAddControllers, animated: false, completion: nil)
       
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHidden:", name: UIKeyboardWillHideNotification, object: nil)
        
        
        print("やりたい\(wantThings)")

        tableView.reloadData()
        
        WantsDataIsEmpty()

        
    }
    
    func WantsDataIsEmpty(){
    
        //やりたいことが未登録ならば
        if wantThings?.count == 0{
            
            print("雨明日")
            
            
            
            
            emptyHeader.hidden = false
            emptyLabel.hidden = false
            tableView.hidden = true
            
        }else{
            
            print("覚めず")
            
            emptyHeader.hidden = true
            emptyLabel.hidden = true
            tableView.hidden = false
            
        }
        
    }

    
    func keyboardWillBeShown(notification:NSNotification){
        
        if let userInfo = notification.userInfo{
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue(),animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue{
                
                restoreScrollViewSize()
                
                
                
                //キーボードの座標をtableViewのスクロールビューの座標に合わせる作業
                let convertedKeyboardFrame = tableView.convertRect(keyboardFrame, fromView: nil)
                
      
                
                let height = tableView.contentSize.height - tableView.contentOffset.y - self.view.bounds.height + convertedKeyboardFrame.height
                
                print("はいと\(height)")
                print("キーボ\(convertedKeyboardFrame.height)")
                
                
                updateScrollViewSize(height,duration:animationDuration)
                
            }
            
            
        }
        
    }
    
    func updateScrollViewSize(moveSize:CGFloat,duration:NSTimeInterval){
        
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsetsMake(0, 0, moveSize, 0)
        tableView.contentInset = contentInsets
        tableView.contentOffset = CGPointMake(0, tableView.contentOffset.y + moveSize)
        
        UIView.commitAnimations()
        
    }
    
    func restoreScrollViewSize(){
        
        tableView.contentInset = UIEdgeInsetsZero
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero
        
    }
    
    func restoreScrollViewSizeForKeyboardHidden(){
        
        tableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func keyboardWillHidden(notification:NSNotification){
    
        restoreScrollViewSizeForKeyboardHidden()
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
        
        return (wantThings?.count)!
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:wantsListTableViewCell = tableView.dequeueReusableCellWithIdentifier("wantCell", forIndexPath: indexPath) as! wantsListTableViewCell
        
        cell.textLabel?.text = wantThings![indexPath.row].wantName
        
        return cell
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        updateHeaderView()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
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
