//
//  wantsListViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/19.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift




class wantsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate{
    

    @IBOutlet weak var tableView: UITableView!
    private let tableHeaderViewHeight:CGFloat = 120.0
    
    let screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
    
   
    @IBOutlet weak var headerView: UIView!
    
  
    var addButton:UIButton!
    
    var wantThings:Results<WantItem>?
    var wantList:Results<WantItemList>?
    
    var doneThings:Results<WantItem>?

    var wantThingsRandom:Results<WantItem>?

    
    
    @IBOutlet weak var wantsNumberLabel: UILabel!
    @IBOutlet weak var graphViewWidth: NSLayoutConstraint!
    @IBOutlet weak var DoneNumberLabel: UILabel!
    @IBOutlet weak var notDoneNumberLabel: UILabel!
    
    @IBOutlet weak var graphBaseView: UIView!
    @IBOutlet weak var graphView: UIView!
 
    
    var emptyLabel:UILabel!
    var emptyArrowImage:UIImageView!
    
    var path = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .None
        
        graphViewWidth.constant = 0
        
        
        //グラフの色
        graphView.backgroundColor = colorFromRGB.colorWithHexString("ffd700")
        
        let realm = try!Realm()
        
        wantList = realm.objects(WantItemList).filter("defaultList = true")
        
        if wantList?.count == 0{
            
            let wantsList = WantItemList()
            wantsList.id = 1
            wantsList.listName = "人生でやりたいことリスト"
            wantsList.createDate = NSDate()
            wantsList.editDate = NSDate()
            wantsList.defaultList = true
            
            try!realm.write({ 
                
                realm.add(wantsList)
            })
            
        }
        
        wantThings = realm.objects(WantItem).sorted("id", ascending: true)
        
        doneThings = wantThings?.filter("done = true")
        
        showWantsItemNumber()
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if paths.count > 0{
            
            path = paths[0]
            
        }

        let View = UIView(frame:CGRectZero)
        View.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = View
        
        emptyLabel = UILabel()
        emptyLabel.text = "やりたいコトをリストにしましょう！"
       
        emptyLabel.textAlignment = .Center
        emptyLabel.textColor = UIColor.grayColor()
        
        
        emptyArrowImage = UIImageView()
        emptyArrowImage.image = UIImage(named: "diagonal-arrow")
      
        
    
        //リストに追加するためのボタンを表示
        addButton = UIButton()
        
        
        switch screenHeight {
        case 480:
            
               emptyArrowImage.frame = CGRectMake(200,320, 40, 40)
               addButton.frame = CGRectMake(250, 360, 60, 60)
               emptyLabel.frame = CGRectMake(0, 200, self.view.bounds.width, 60)
         
        case 568:
            
               emptyArrowImage.frame = CGRectMake(210,400, 40, 40)
               addButton.frame = CGRectMake(250, 440, 60, 60)
               emptyLabel.frame = CGRectMake(0, 250, self.view.bounds.width, 60)
            
        case 667:
         
               addButton.frame = CGRectMake(300, 550, 60, 60)
               emptyLabel.frame = CGRectMake(0, 400, self.view.bounds.width, 60)
            
        case 736:
            
               addButton.frame = CGRectMake(300, 550, 44, 44)
               emptyLabel.frame = CGRectMake(0, 400, self.view.bounds.width, 60)
         
        default:
            
               addButton.frame = CGRectMake(300, 550, 44, 44)
               emptyLabel.frame = CGRectMake(0, 400, self.view.bounds.width, 60)
        }
     
        addButton.backgroundColor = colorFromRGB.colorWithHexString("0fb5c4")
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 30
        addButton.alpha = 0.8
        addButton.setImage(UIImage(named: "Plus Math-64"), forState: .Normal)
        addButton.addTarget(self, action: Selector("addWantItem"), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(emptyLabel)
        self.view.addSubview(emptyArrowImage)
        self.view.addSubview(addButton)
        
        
        self.navigationController?.navigationBar.barTintColor = colorFromRGB.colorWithHexString("0fb5c4")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        }
    
    
    func showWantsItemNumber(){
    
 
        
        if wantThings?.count != 0{
        
            wantsNumberLabel.text = "\((wantThings?.count)!)"
            DoneNumberLabel.text = "\((doneThings?.count)!)"
            notDoneNumberLabel.text = "\((wantThings?.count)! - (doneThings?.count)!)"
        
        }else{
            
            wantsNumberLabel.text = "0"
            DoneNumberLabel.text = "0"
            notDoneNumberLabel.text = "0"
            
        }
        
    }
    
    func showGraph(){
    
        
        if wantThings?.count != 0{
       
            print("できたこと\((doneThings?.count)!)")
            print("やりたいこと\((wantThings?.count)!)")
            
            let donePercent:Double = Double((doneThings?.count)!) / Double((wantThings?.count)!)
            print("パーセント\(donePercent)")
            
            let graphBaseLength = graphBaseView.bounds.size.width
              print("ベースの幅\(graphBaseLength)")
            let graphLengh = graphBaseLength * CGFloat(donePercent)
            
            graphViewWidth.constant = graphLengh
            
            print("レングス\(graphLengh)")
            
            print("呼ば")
        
        }else{
            
            graphViewWidth.constant = 0
        }
        
    }
    

    func addWantItem(){
    
        
        let wantItemAddControllers:wantItemAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("wantItemAdd") as! wantItemAddViewController
        
        
        self.presentViewController(wantItemAddControllers, animated: false, completion: nil)
       
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showWantsItemNumber()
        showGraph()
        
        if wantList?.count == 0{
            
            self.navigationItem.title = "人生でやりたいことリスト"
            
        }else{
            
            self.navigationItem.title = wantList![0].listName
            
        }
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
        WantsDataIsEmpty()
        print("武蔵野線")
        
        tableView.reloadData()
        
    }
    
    
    func WantsDataIsEmpty(){
    
        //やりたいことが未登録ならば
        if wantThings?.count == 0{
            
            emptyArrowImage.hidden = false
            emptyLabel.hidden = false
            tableView.hidden = true
            
        }else{
            
            emptyArrowImage.hidden = true
            emptyLabel.hidden = true
            tableView.hidden = false
            
        }
        
    }

    
    func updateHeaderView(){
        print("アップです")
        
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
    
  
 
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:wantsListTableViewCell = tableView.dequeueReusableCellWithIdentifier("wantCell", forIndexPath: indexPath) as! wantsListTableViewCell
        
        if (indexPath.row + 1).description.characters.count == 1{
            
                cell.wantsNumber.text = "00" + "\(indexPath.row + 1)"
          cell.wantsNumber.sizeToFit()
        }else if (indexPath.row + 1).description.characters.count == 2{
        
                cell.wantsNumber.text = "0" + "\(indexPath.row + 1)"
              cell.wantsNumber.sizeToFit()
        }else if (indexPath.row + 1).description.characters.count == 3{
            
                cell.wantsNumber.text = "\(indexPath.row + 1)"
              cell.wantsNumber.sizeToFit()
        }
    
        //継続中ならラベルを表示する。
        if wantThings![indexPath.row].continues{
            
            cell.continueLabel.textColor = UIColor.whiteColor()
            cell.continueLabel.backgroundColor = UIColor.orangeColor()
            cell.continueLabel.layer.cornerRadius = 5
            cell.continueLabel.layer.masksToBounds = true
            cell.continueLabel.hidden = false
            
        }else{
            
            cell.continueLabel.hidden = true
            
        }
        
        
        
      
        
        cell.doneMemoLabel.textColor = colorFromRGB.colorWithHexString("6495ed")
        
        //達成済みなら線を引きたい。
        if wantThings![indexPath.row].done{
            
            let text = NSAttributedString(string: wantThings![indexPath.row].wantName,attributes: [NSStrikethroughStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,NSStrikethroughColorAttributeName:UIColor.blackColor()])
            
            cell.wantItemNameLabel.attributedText = text
            
            
        }else{
        
            cell.wantItemNameLabel.text = wantThings![indexPath.row].wantName
            
        }
        
        cell.wantItemNameLabel.sizeToFit()
        
        cell.doneMemoLabel.numberOfLines = 0
        cell.doneMemoLabel.text = wantThings![indexPath.row].doneMemo
        
        
        
        if wantThings![indexPath.row].wantsDonePhotos.count == 0{
            
            print("写真なし")
            cell.donePhotoheight.constant = 0
        
        }else{
            
            let filename = wantThings![indexPath.row].wantsDonePhotos[0].fileName
            let filePath = (path as NSString).stringByAppendingPathComponent(filename)
            
            let doneImages:UIImage = UIImage(contentsOfFile:filePath)!
            
            cell.donePhotoImage.image = doneImages
            cell.donePhotoheight.constant = 190
            
        }
        
        cell.layoutIfNeeded()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let completesViewController:completeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("comp") as! completeViewController
        
        
        
        completesViewController.wantItemId = self.wantThings![indexPath.row].id
        
        
        presentViewController(completesViewController, animated: true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editButton:UITableViewRowAction = UITableViewRowAction(style: .Normal,title: "編集"){(action,index) -> Void in
        
            let editViewController:editItemViewController = self.storyboard?.instantiateViewControllerWithIdentifier("editItem") as! editItemViewController
            
            let cell = tableView.cellForRowAtIndexPath(index) as! wantsListTableViewCell
            editViewController.editItemCatch = cell.wantItemNameLabel.text
            editViewController.editItemIdCatch = self.wantThings![indexPath.row].id
            self.presentViewController(editViewController, animated: false, completion: nil)
            
       
                
            
            tableView.editing = false
        
        }
        
        let deleteButton:UITableViewRowAction = UITableViewRowAction(style: .Normal,title: "削除"){(action,index) -> Void in
        
            let realm = try!Realm()
            
            let deleteItem = self.wantThings![indexPath.row]
            
            //写真があるデータならば
            if deleteItem.wantsDonePhotos.count != 0{
                
                let deletePhotoName = deleteItem.wantsDonePhotos[0].fileName
                let deletePhotoPath = (self.path as NSString).stringByAppendingPathComponent(deletePhotoName)
                
                do{
                    
                    try NSFileManager.defaultManager().removeItemAtPath(deletePhotoPath)
                    
                }catch{
                    print("エラー")
                }
                
            }

            
            try!realm.write({ 
                
                realm.delete(deleteItem)
                
            })
            
            
            
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:indexPath.row,inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
    
            //削除のアニメーションを残しつつ、reloadしてリストを更新する。
            let dispatchTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,Int64(0.1 * Double(NSEC_PER_SEC)))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
                
                tableView.reloadData()
                self.showWantsItemNumber()
            
            })
    
            tableView.editing = false
        
        }
        
        editButton.backgroundColor = UIColor.blueColor()
        deleteButton.backgroundColor = UIColor.redColor()
        
        return [deleteButton,editButton]
    }
    
    

    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let data = wantThings![indexPath.row]
  
        return wantsListTableViewCell.heightForRow(tableView,data:data)
        
    }
    
    

    @IBAction func settingButtonTaped(sender: AnyObject) {
        
        let wantListsettingViewController:wantsListSettingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("wantListSetting") as! wantsListSettingViewController
        
        let navigation = UINavigationController()
        navigation.viewControllers = [wantListsettingViewController]
        
        let realm = try!Realm()
        let wantLists = realm.objects(WantItemList).filter("defaultList = true")
        
        let wantListIds = wantLists[0].id
        
        wantListsettingViewController.wantListId = wantListIds
        
        self.presentViewController(navigation, animated: true, completion: nil)
        
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
