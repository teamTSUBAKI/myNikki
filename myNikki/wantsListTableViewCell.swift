//
//  wantsListTableViewCell.swift
//  myNikki
//
//  Created by kuroda takumi on 2016/06/20.
//  Copyright © 2016年 BiyousiNote.inc. All rights reserved.
//

import UIKit



class wantsListTableViewCell: UITableViewCell {

    @IBOutlet weak var wantsNumber: UILabel!
    @IBOutlet weak var wantItemNameLabel: UILabel!
    @IBOutlet weak var doneMemoLabel: UILabel!
    
    @IBOutlet weak var donePhotoImage: UIImageView!
    @IBOutlet weak var donePhotoheight: NSLayoutConstraint!
    
    @IBOutlet weak var continueLabel: UILabel!
    
    private var _data:WantItem?
    var data:WantItem?{
        
        get{
            
            return _data
        }
        
        set(data){
            
            _data = data
            
            if let data = data {
                
                self.wantItemNameLabel.text = data.wantName
                self.doneMemoLabel.text = data.doneMemo
                
                if data.wantsDonePhotos.count == 0{
                    
                    self.donePhotoheight.constant = 0
                    
                }else{
                    
                    self.donePhotoheight.constant = 200
                }
                
                self.layoutIfNeeded()
                
            }
        }
    }
    
  
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //高さを動的に変えるときの横幅
      
        
        self.wantItemNameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.wantItemNameLabel.bounds)
        self.doneMemoLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.doneMemoLabel.bounds)
    }
    
    
    class func heightForRow(tableView:UITableView,data:WantItem?)-> CGFloat{
        
        struct Sizing{
            
            static var cell:wantsListTableViewCell?
        }
        
        if Sizing.cell == nil{
            
            Sizing.cell = tableView.dequeueReusableCellWithIdentifier("wantCell") as? wantsListTableViewCell
            
        }
        
        if let cell = Sizing.cell{
            
            //セルの横幅
            cell.frame.size.width = CGRectGetWidth(tableView.bounds)
            cell.data = data
            
            let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            print("高い\(size.height)")
            return size.height + 20
        }
        
        return 0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
