//
//  AddReminderTableViewCell.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/06.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class AddReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var addRemiderLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addRemiderLabel.textAlignment = NSTextAlignment.Center
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
