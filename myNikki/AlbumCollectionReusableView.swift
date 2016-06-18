//
//  AlbumCollectionReusableView.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/28.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class AlbumCollectionReusableView: UICollectionReusableView {
 
    
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         let dateLabel:UILabel = UILabel(frame: CGRectMake(0,0,frame.size.width,20))
         self.addSubview(dateLabel)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
