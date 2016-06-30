//
//  File.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/25.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import Foundation
import RealmSwift

class Note:Object{
    
    dynamic var id = 0
    dynamic var createDate:NSDate?
    dynamic var editDate:NSDate?
    dynamic var noteText = ""
    dynamic var modelName = ""
    dynamic var timerTime = 0
    
    override class func primaryKey() -> String{
        return "id"
        
    }
    
    let photos = List<Photos>()
    
}


class Photos:Object{
    dynamic var id = 0
    dynamic var createDate:NSDate?
    dynamic var filename = ""
    
     var note:[Note]{
        return linkingObjects(Note.self, forProperty:"photos")
    }
    
}

class WantItem: Object {
    dynamic var id = 0
    dynamic var createDate:NSDate?
    dynamic var editDate:NSDate?
    dynamic var listNumber = 0
    dynamic var wantName = ""
    //達成したかどうか？
    dynamic var done = false
    //継続中かどうか
    dynamic var continues = false
    //達成日
    dynamic var doneDate = ""
    //達成メモ
    dynamic var doneMemo = ""
    
    //将来実装する用
    //達成してないwantsにつけられるメモ機能
    dynamic var wantsMemo = ""
    //期限
    dynamic var timeLimit:NSDate?
    
    override class func primaryKey() -> String{
        return "id"
    }
    
    let wantsDonePhotos = List<wantsDonePhoto>()
}

class wantsDonePhoto:Object{
    dynamic var id = 0
    dynamic var createdate:NSDate?
    dynamic var editDate:NSDate?
    dynamic var fileName = ""
    
    override class func primaryKey() -> String{
        
        return "id"
        
    }
    
    var wantItem:[WantItem]{
        
        return linkingObjects(WantItem.self,forProperty:"wantsDonePhotos")
    }
    
    
}


class Reminder:Object{
    dynamic var id = 0
    dynamic var createDate:NSDate?
    dynamic var editDate:NSDate?
    //タイムは仮にintにしておく
    dynamic var Time:NSDate?
    //0はオフ、1はオン。
    dynamic var repitition = 0

    override class func primaryKey() -> String{
        return "id"
    }
    
    
}