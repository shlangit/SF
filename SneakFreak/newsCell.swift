//
//  newsCell.swift
//  SneakFreak
//
//  Created by Reid on 3/6/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {

    // UI Objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(40)]-10-[username]",
            options: [], metrics: nil, views: ["ava":avaImg, "username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(40)]-10-[info]-7-[date]",
            options: [], metrics: nil, views: ["ava":avaImg, "info":infoLbl, "date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(40)]-10-|",
            options: [], metrics: nil, views: ["ava":avaImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-5-[username(30)]",
            options: [], metrics: nil, views: ["username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-25-[info(30)]",
            options: [], metrics: nil, views: ["info":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-25-[date(30)]",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 9
        avaImg.clipsToBounds = true
    }

    
}
