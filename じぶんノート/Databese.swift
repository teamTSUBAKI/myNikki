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