//
//  wantsListViewController.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/19.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift


protocol addWantDelegate{
    
    func addRandomNumber()
    
}


class wantsListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate,addWantDelegate{

    @IBOutlet weak var tableView: UITableView!
    private let tableHeaderViewHeight:CGFloat = 300.0
    
    let screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
    
   
    @IBOutlet weak var headerView: UIView!
    var emptyHeader:UIView!
  
    var addButton:UIButton!
    
    var wantThings:Results<WantItem>?

    var wantThingsRandom:Results<WantItem>?

    
    //シャッフルした後の配列
    var randomNumbers:[Int] = [Int]()
    
    var emptyLabel:UILabel!
    
    var path = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        let realm = try!Realm()
        wantThings = realm.objects(WantItem)
        
        //ランダムな数字の配列を生成
        //やりたいことがあるならば
        if wantThings?.count != 0{
        
            randomNumber()
        
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if paths.count > 0{
            
            path = paths[0]
            
        }

        
        //ヘッダービューを追加
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        let View = UIView(frame:CGRectZero)
        View.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = View
        
        
        
        //データがないとき用のヘッダービューと同じものを生成
        emptyHeader = NSBundle.mainBundle().loadNibNamed("emptyHeaderView", owner: self, options: nil)[0] as! UIView
        emptyHeader.frame = CGRectMake(0, 0, self.view.bounds.width, 300)
        
        self.view.addSubview(emptyHeader)
        
        
        emptyLabel = UILabel()
        emptyLabel.text = "やりたいコトをリストにしましょう！"
        emptyLabel.frame = CGRectMake(0, 400, self.view.bounds.width, 60)
        emptyLabel.textAlignment = .Center
        emptyLabel.textColor = UIColor.grayColor()
        
        self.view.addSubview(emptyLabel)
        
    
        //リストに追加するためのボタンを表示
        addButton = UIButton()
        
        
        switch screenHeight {
        case 480:
            
               addButton.frame = CGRectMake(250, 400, 44, 44)
         
        case 568:
            
               addButton.frame = CGRectMake(250, 470, 44, 44)
            
        case 667:
         
               addButton.frame = CGRectMake(300, 550, 44, 44)
            
        case 736:
            
               addButton.frame = CGRectMake(300, 550, 44, 44)
         
        default:
            
               addButton.frame = CGRectMake(300, 550, 44, 44)
        }
     
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

        
        
        
        print("ナツメグやろう")
        tableView.contentInset = UIEdgeInsets(top: tableHeaderViewHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPointMake(0, -tableHeaderViewHeight)
        
        //上にスクロールした時にヘッダーのサイズを大きくして画像を拡大する。
        updateHeaderView()
        
    }
    

    func addWantItem(){
    
        
        let wantItemAddControllers:wantItemAddViewController = self.storyboard?.instantiateViewControllerWithIdentifier("wantItemAdd") as! wantItemAddViewController
        
        wantItemAddControllers.delegate = self
        
        self.presentViewController(wantItemAddControllers, animated: false, completion: nil)
       
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
        WantsDataIsEmpty()
        print("武蔵野線")
        
        tableView.reloadData()
        
    }
    
    func randomNumber(){
        
        print("やぁ")
    
        //重複しないランダムな数字を入れた配列を作る。
        //まずは順番の配列。
        
        //シャッフルする前の配列
        var beforeSuffule:[Int] = [Int]()
        
        for ind in 0...(wantThings?.count)!-1{
            
            beforeSuffule.append(ind)
            
            
        }
        
        //シャッフルする
        
        randomNumbers = [Int]()
        for _ in 0...(wantThings?.count)!-1{
            
            
            let num = beforeSuffule.removeAtIndex(Int(arc4random()) % beforeSuffule.count)
            
            
            
            randomNumbers.append(num)
            print("ランダムな配列\(randomNumbers)")
        }
    }
    
    func WantsDataIsEmpty(){
    
        //やりたいことが未登録ならば
        if wantThings?.count == 0{
            
            emptyHeader.hidden = false
            emptyLabel.hidden = false
            tableView.hidden = true
            
        }else{
            
            emptyHeader.hidden = true
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
        
        
        cell.wantsNumber.text = "\(indexPath.row + 1)"
        cell.wantsNumber.sizeToFit()
        
        
        
        //ランダムな値でデータを取り出したい
        
        if randomNumbers.count == 0{
            randomNumber()
        }
        
        print("ランダムず\(randomNumbers)")
        let num = randomNumbers[indexPath.row]
        
        //達成済みなら線を引きたい。
        if wantThings![num].done{
            
            let text = NSAttributedString(string: wantThings![num].wantName,attributes: [NSStrikethroughStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,NSStrikethroughColorAttributeName:UIColor.redColor()])
            
            cell.wantItemNameLabel.attributedText = text
            
            
        }else{
        
            cell.wantItemNameLabel.text = wantThings![num].wantName
            
        }
        
        cell.doneMemoLabel.numberOfLines = 0
        cell.doneMemoLabel.text = wantThings![num].doneMemo
        
        
        
        if wantThings![num].wantsDonePhotos.count == 0{
            
            print("写真なし")
            cell.donePhotoheight.constant = 0
        
        }else{
            
            let filename = wantThings![num].wantsDonePhotos[0].fileName
            let filePath = (path as NSString).stringByAppendingPathComponent(filename)
            
            let doneImages:UIImage = UIImage(contentsOfFile:filePath)!
            
            cell.donePhotoImage.image = doneImages
            cell.donePhotoheight.constant = 200
            
        }
        
        cell.layoutIfNeeded()
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let completesViewController:completeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("comp") as! completeViewController
        
        let num = randomNumbers[indexPath.row]
        
        completesViewController.wantItemId = self.wantThings![num].id
        
        
        presentViewController(completesViewController, animated: true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editButton:UITableViewRowAction = UITableViewRowAction(style: .Normal,title: "編集"){(action,index) -> Void in
        
            let editViewController:editItemViewController = self.storyboard?.instantiateViewControllerWithIdentifier("editItem") as! editItemViewController
            
            let cell = tableView.cellForRowAtIndexPath(index)
            editViewController.editItemCatch = cell?.textLabel?.text
            editViewController.editItemIdCatch = self.wantThings![indexPath.row].id
            self.presentViewController(editViewController, animated: false, completion: nil)
            
       
                
            
            tableView.editing = false
        
        }
        
        let deleteButton:UITableViewRowAction = UITableViewRowAction(style: .Normal,title: "削除"){(action,index) -> Void in
        
            let realm = try!Realm()
            
            let num = self.randomNumbers[indexPath.row]
            
            let deleteItem = self.wantThings![num]
            
            try!realm.write({ 
                
                realm.delete(deleteItem)
                
            })
    
            //ランダムな数字の配列の最大値を取り出す
            let numMax = self.randomNumbers.maxElement()
            
            //最大値のインデックスを調べる
            let numMaxIndex = self.randomNumbers.indexOf(numMax!)
            
            self.randomNumbers.removeAtIndex(numMaxIndex!)
            
            
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:indexPath.row,inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
            
            let dispatchTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
                
                tableView.reloadData()
            
            
            })
    

            
            
            
        
            
            /*
            UIView.animateWithDuration(0.5, animations: {
                //ランダムな数字の配列の最大値を取り出す
                let numMax = self.randomNumbers.maxElement()
                
                //最大値のインデックスを調べる
                let numMaxIndex = self.randomNumbers.indexOf(numMax!)
                
                self.randomNumbers.removeAtIndex(numMaxIndex!)
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow:indexPath.row,inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.endUpdates()
                
                
                }, completion: { _ in
                    tableView.reloadData()
            })*/
            
            
          
          
        
            tableView.editing = false
        
        }
        
        editButton.backgroundColor = UIColor.blueColor()
        deleteButton.backgroundColor = UIColor.redColor()
        
        return [deleteButton,editButton]
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
       updateHeaderView()
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let num = randomNumbers[indexPath.row]
        
        let data = wantThings![num]
  
        return wantsListTableViewCell.heightForRow(tableView,data:data)
        
    }
    
    
    func addRandomNumber(){
        
        let realm = try!Realm()
        let wants = realm.objects(WantItem)
        print("呼ばれない？")
        
        //一個目のやりたいことの時は、tableのcellForRowIndexPathでランダムナンバー配列を用意するので、こっちはいらない。
        if wants.count != 1{
        
            print("数")
            randomNumbers.append(wants.count-1)
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
