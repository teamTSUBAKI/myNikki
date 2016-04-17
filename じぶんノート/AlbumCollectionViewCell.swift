//
//  AlbumCollectionViewCell.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/03/22.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    var PhotoView:UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")

        }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("イメージビュー\(frame.width)")
        PhotoView = UIImageView(frame: CGRectMake(0,0,frame.width,frame.height))
        PhotoView.contentMode = UIViewContentMode.ScaleAspectFill
        PhotoView.clipsToBounds = true
        self.contentView.addSubview(PhotoView)
        
        
    }
    
}
