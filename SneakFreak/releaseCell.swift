//
//  releaseCell.swift
//  SneakFreak
//
//  Created by Reid on 3/22/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit

class releaseCell: UITableViewCell {

    // UI Objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var infoLbl: UIButton!
    
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // constraints
        picImg.translatesAutoresizingMaskIntoConstraints = false
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-5-[pic(115)]-10-[info(120)]",
            options: [], metrics: nil, views: ["pic":picImg, "info":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[date]-5-|",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-15-[pic(70)]-10-|",
            options: [], metrics: nil, views: ["pic":picImg]))
               
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[info(75)]",
            options: [], metrics: nil, views: ["info":infoLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[date(75)]",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
        // round ava
        picImg.layer.cornerRadius = picImg.frame.size.width / 10
        picImg.clipsToBounds = true
    }

}
