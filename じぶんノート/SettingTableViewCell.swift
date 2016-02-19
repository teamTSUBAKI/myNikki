//
//  SettingTableViewCell.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/02/06.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var TSUBAKILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
