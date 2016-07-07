//
//  datePickerTableViewCell.swift
//  じぶんノート
//
//  Created by kuroda takumi on 2016/04/11.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit

class datePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
   

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
