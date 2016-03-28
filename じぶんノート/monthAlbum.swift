//
//  monthAlbum.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/21.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit
import RealmSwift

class monthAlbum: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{

    var myCollectionView:UICollectionView!
    var noPhotoLabel:UILabel!

    var Notes:Results<(Note)>!
    var photoes:[String]!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect,year:Int,month:Int) {
        super.init(frame: frame)
        
        self.PhotoSet(year,month: month)
    }
    
    func PhotoSet(year:Int,month:Int){
        //realmから写真データを引っ張ってきたい。
    
        print("写真セット")
        let realm = try!Realm()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        //月の１日目
        print("\(year)月\(month)日")
        let startTarget:NSDate = (calendar?.dateWithEra(1, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0))!
        
        let lastDay = self.getLastDay(year,month: month)
        
        let lastTarget = calendar?.dateWithEra(1, year: year, month: month, day: lastDay!, hour: 23, minute:59  , second: 59, nanosecond: 59)
        
        let predicate = NSPredicate(format: "createDate BETWEEN {%@,%@}", startTarget,lastTarget!)
        
        Notes = realm.objects(Note).filter(predicate).sorted("id", ascending: false)
        photoes = []
        
        print("ノート数\(Notes.count)")
        
        if myCollectionView != nil{
            myCollectionView.removeFromSuperview()
        }
        
   
        if Notes.count > 0{
        for ind in 1...Notes.count {
            
               let Photo = Notes[ind-1].photos
                print(Photo)
            
               for photo in Photo{
                print(photo.filename)
                photoes.append(photo.filename)
            
               }
        
        
            }
        }
        
        
        //コレクションビューのレイアウトを生成
        let layout = UICollectionViewFlowLayout()
        
        //セルの一つ一つの大きさ
        layout.itemSize = CGSizeMake(frame.size.width / 2-5,frame.size.width / 2-4)
        
        //セルのマージン
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        //セクションごとのヘッダーサイズ
        layout.headerReferenceSize = CGSizeMake(100, 0)
        
        //コレクションビューの高さは、写真数/2*セルの高さでいけるかな
        let collectionHeight = CGFloat(photoes.count) * (frame.size.width / 2 - 4)
        print("コレクションビューの高さ\(collectionHeight)")
        myCollectionView = UICollectionView(frame: CGRectMake(0, 40, frame.size.width, 550), collectionViewLayout: layout)
        myCollectionView.backgroundColor = UIColor.clearColor()
        
        //セルのクラスを登録
        myCollectionView.registerClass(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: "myCell")
        
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        
    
        
        self.addSubview(myCollectionView)
       
        
        
    
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("呼ばれましたーーーー")
        
        var res = 0
        switch (section){
        case 0:
            res = photoes.count
            break
        default:
            res = 0
            break
        }
        
        print(res)
        return res
        
    }
    
   
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:AlbumCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! AlbumCollectionViewCell
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var path = ""
        if paths.count > 0{
            
            path = paths[0]
        }
        
        let filePath = (path as NSString).stringByAppendingPathComponent(photoes[indexPath.row])
        
        let image = UIImage(contentsOfFile: filePath)
        print("used\(image!)")
        cell.PhotoView.image = image
    
        return cell
        
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
