//
//  timeLineTableViewCell.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2015/12/27.
//  Copyright © 2015年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class timeLineTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var titleLabeX: NSLayoutConstraint!
    @IBOutlet weak var bodyLabelX: NSLayoutConstraint!
    
    
    @IBOutlet weak var bodyLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var PhotoWidth: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerX: NSLayoutConstraint!
    @IBOutlet weak var timerLabelWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //行数を最大二桁に限定し、ラベルの高さを計算する。
        let maxFrame = CGRectMake(0, 0, bodyTextLabel.frame.size.width, CGFloat.max)
        let actualFrame = bodyTextLabel.textRectForBounds(maxFrame, limitedToNumberOfLines:2)
        
        
        //計算したサイズを設定
        bodyLabelHeight.constant = actualFrame.size.height
        
        
        
    }

}
