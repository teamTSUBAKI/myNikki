//
//  SettingReminderTableViewCell.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/09.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class SettingReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var remindLabel: UILabel!
    @IBOutlet weak var remindTimelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
