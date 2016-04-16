//
//  monthAlbum.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/21.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

protocol toNoteDetailDelegate{
    
    func photoSelected(select:Photos)
    
}

class monthAlbum: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{

    var myCollectionView:UICollectionView!
    
    var screenHeight = Double(UIScreen.mainScreen().bounds.size.height)
    
    var noPhotoLabel:UILabel!
    var noPhotoImage:UIImageView!
    
    
    
    var Notes:Results<(Note)>!
    
    var delegate:toNoteDetailDelegate! = nil
    
    var sectionHeding:NSString!
    var sections:NSMutableArray = []
    var collectionViewCells:[NSString:[NSMutableArray]]?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect,year:Int,month:Int) {
        super.init(frame: frame)
        
        noPhotoImage = UIImageView(frame: CGRectMake(0, 0, 100, 100))
        noPhotoImage.image = UIImage(named: "Sleeping in Bed-104")
        noPhotoImage.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - 100)
        self.addSubview(noPhotoImage)
        
        noPhotoLabel = UILabel(frame: CGRectMake(0,0,frame.size.width,30))
        noPhotoLabel.text = "写真がありません"
        noPhotoLabel.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 )
        noPhotoLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(noPhotoLabel)
        
        self.PhotoSet(year,month: month)
    }
    
    func PhotoSet(year:Int,month:Int){
        //realmから写真データを引っ張ってきたい。
    
      
        let realm = try!Realm()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.timeZone = NSTimeZone(abbreviation: "GMT")!
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "MM/dd"
        
        //月の１日目
       
        let startTarget:NSDate = (calendar?.dateWithEra(1, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0))!
        
        let lastDay = self.getLastDay(year,month: month)
        
        let lastTarget = calendar?.dateWithEra(1, year: year, month: month, day: lastDay!, hour: 23, minute:59  , second: 59, nanosecond: 59)
        
        let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}", startTarget,lastTarget!)
        
        Notes = realm.objects(Note).filter(predicate).sorted("id", ascending: false)
        sections = []
        let PhotoBox:NSMutableArray = []
        
     
        
        if myCollectionView != nil{
            myCollectionView.removeFromSuperview()
        }
        
        
        let unit:NSCalendarUnit = [NSCalendarUnit.Year,NSCalendarUnit.Month,NSCalendarUnit.Day]
        var day:Int!
        var month:Int!
        var preDay = -1
        
        collectionViewCells = [:]
        var collectionViewCellsForSection:NSMutableArray = []
   
        //ノートから写真を取り出して、日付毎に分けていく
        for note in Notes{
            
            if note.createDate != nil{
            
                let comps = calendar?.components(unit, fromDate: note.createDate!)
                
                day = comps?.day
                month = comps?.month
                
                if (day != preDay && note.photos.count > 0){
                    
                    sectionHeding = "\(month)月\(day)日"
                    
                    //sctionsと言う配列に日付を入れる
                    sections.addObject(sectionHeding)
                    
                    //初期化
                    collectionViewCellsForSection = []
                    collectionViewCells!["\(sectionHeding)"] = [collectionViewCellsForSection]
                    
                    preDay = day
                    
                }
                
            
                
                    for photo in note.photos{
                
                    collectionViewCellsForSection.addObject(photo)
                    PhotoBox.addObject(photo)
                        
                    }
                
            }
            
        }
        
       
  
        
        //コレクションビューのレイアウトを生成
        let layout = UICollectionViewFlowLayout()
        
        switch screenHeight{
        case 736:
            //セルの一つ一つの大きさ
            layout.itemSize = CGSizeMake(frame.size.width / 2 - 0.8,frame.size.width / 2-4)
            
            //セルのマージン
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
            layout.minimumInteritemSpacing = 0.4
            layout.minimumLineSpacing = 1.0

        
        default:
        //セルの一つ一つの大きさ
        layout.itemSize = CGSizeMake(frame.size.width / 2 - 0.4,frame.size.width / 2-4)
        
        //セルのマージン
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0.2
        layout.minimumLineSpacing = 1.0
        }
        
        //セクションごとのヘッダーサイズ
        layout.headerReferenceSize = CGSizeMake(100, 30)
        
    
        switch screenHeight{
        case 480:
        
            myCollectionView = UICollectionView(frame: CGRectMake(0, 30, frame.size.width, 330), collectionViewLayout: layout)
        
        case 568:
            
            myCollectionView = UICollectionView(frame: CGRectMake(0, 30, frame.size.width, 420), collectionViewLayout: layout)
        
        case 667:
        
            myCollectionView = UICollectionView(frame: CGRectMake(0, 30, frame.size.width, 520), collectionViewLayout: layout)
        
        case 736:
        
            myCollectionView = UICollectionView(frame: CGRectMake(0, 30, frame.size.width, 590), collectionViewLayout: layout)
        
        default:
           print("エラー")
            
        
        }
        
        myCollectionView.backgroundColor = UIColor.clearColor()
        
        //セルのクラスを登録
        myCollectionView.registerClass(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: "myCell")
        myCollectionView.registerClass(AlbumCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "section")
        
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        
        //今月、写真があるかどうか？
        
        
        if PhotoBox.count > 0{
        
            noPhotoImage.hidden = true
            noPhotoLabel.hidden = true
            self.addSubview(myCollectionView)
        
        }else{
            
            noPhotoLabel.hidden = false
            noPhotoImage.hidden = false
            
       
        }
        
        
    
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        let key:NSString = sections[section] as! NSString
      
        
     
        return collectionViewCells![key]![0].count
        
    }
    
   
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:AlbumCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! AlbumCollectionViewCell
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var path = ""
        if paths.count > 0{
            
            path = paths[0]
        }
        
        let key:NSString = sections[indexPath.section] as! NSString
        let photo:Photos = collectionViewCells![key]![0][indexPath.row] as! Photos
        
        let filePath = (path as NSString).stringByAppendingPathComponent(photo.filename)
        
       let image = UIImage(contentsOfFile: filePath)
        
        cell.PhotoView.image = nil
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
            
            let resize = CGSizeMake(self.frame.size.width / 2 - 0.4,self.frame.size.width / 2-4)
            UIGraphicsBeginImageContextWithOptions(resize, false, 2.0)
            image!.drawInRect(CGRectMake(0, 0, self.frame.size.width / 2 - 0.4, self.frame.size.width / 2-4))
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            dispatch_async(dispatch_get_main_queue(), {
                
            
                cell.PhotoView.image = resizeImage
                
            
            })
            
            
        })

          return cell
      
    
       
        
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return sections.count
        
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
    
        
        if kind == UICollectionElementKindSectionHeader{
   
            let headerView:AlbumCollectionReusableView = myCollectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section", forIndexPath: indexPath) as! AlbumCollectionReusableView
        
            if headerView.subviews.count == 0{
                headerView.addSubview(UILabel(frame: CGRectMake(0,0,frame.size.width,30)))
            }
        
        let dateLabel:UILabel = headerView.subviews[0] as! UILabel
        dateLabel.frame = CGRectMake(0, 3, frame.size.width, 30)
        
        dateLabel.textAlignment = NSTextAlignment.Center
        dateLabel.text = sections[indexPath.section] as? String
        dateLabel.textColor = UIColor.grayColor()
        dateLabel.font = UIFont(name: "HiraKakuProN-W3", size: 18)
            
              return headerView
        
        }
        
        return UICollectionReusableView()
      
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let key = sections[indexPath.section] as! NSString
        let photo:Photos = collectionViewCells![key]![0][indexPath.row] as! Photos
       
        self.delegate.photoSelected(photo)
        
    }
    
    
    func getLastDay(var year:Int,var month:Int) -> Int?{
        
        let dateForMatter = NSDateFormatter()
        dateForMatter.dateFormat = "yyyy/MM/dd"
        
        if month == 12{
            month = 0
            year++
            
        }
        
        let targetDate:NSDate? = dateForMatter.dateFromString(String(format: "%04d/%02d/1", year,month + 1))!
        
        if targetDate != nil{
            
            let orgDate = NSDate(timeInterval:(24 * 60 * 60) * (-1) , sinceDate: targetDate!)
            let str = dateForMatter.stringFromDate(orgDate)
            
            return Int((str as! NSString).lastPathComponent)!
        }
        return nil
    }
    
 
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
