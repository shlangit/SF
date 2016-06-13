//
//  postCell.swift
//  SneakFreak
//
//  Created by Reid on 2/26/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class postCell: UITableViewCell {

    // header objects
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var saleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    // main picture
    @IBOutlet weak var picImg: UIImageView!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    // buttons
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var titleLbl: KILabel!
    
    // labels
    @IBOutlet weak var uuidLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // clear like button title color
        likeBtn.setTitleColor(UIColor.clearColor(), forState: .Normal)
        
        let width = UIScreen.mainScreen().bounds.width
        
        // allow constraints
        avaImg.translatesAutoresizingMaskIntoConstraints = false
        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
        dateLbl.translatesAutoresizingMaskIntoConstraints = false
        
        picImg.translatesAutoresizingMaskIntoConstraints = false
        
        likeBtn.translatesAutoresizingMaskIntoConstraints = false
        commentBtn.translatesAutoresizingMaskIntoConstraints = false
        moreBtn.translatesAutoresizingMaskIntoConstraints = false
        
        likeLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        uuidLbl.translatesAutoresizingMaskIntoConstraints = false
        
        saleLbl.translatesAutoresizingMaskIntoConstraints = false
        priceLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let pictureWidth = width
        
        // constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-10-[ava(30)]-10-[pic(\(pictureWidth))]-10-[like(20)]",
            options: [], metrics: nil, views: ["ava":avaImg, "pic":picImg, "like":likeBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-6-[username]",
            options: [], metrics: nil, views: ["username":usernameBtn]))
    
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-10-[comment(20)]",
            options: [], metrics: nil, views: ["pic":picImg, "comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-15-[date]",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[like]-8-[title]-|",
            options: [], metrics: nil, views: ["like":likeBtn, "title":titleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-10-[more(20)]",
            options: [], metrics: nil, views: ["pic":picImg, "more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-10-[price]",
            options: [], metrics: nil, views: ["pic":picImg, "price":priceLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(\(pictureWidth))-[sale(50)]",
            options: [], metrics: nil, views: ["sale":saleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[sale(50)]-5-|",
            options: [], metrics: nil, views: ["sale":saleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-11-[likes]",
            options: [], metrics: nil, views: ["pic":picImg, "likes":likeLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[ava(30)]-10-[username]",
            options: [], metrics: nil, views: ["ava":avaImg, "username":usernameBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[pic]|",
            options: [], metrics: nil, views: ["pic":picImg]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[like(20)]-10-[likes(15)]-20-[comment(20)]",
            options: [], metrics: nil, views: ["like":likeBtn, "likes":likeLbl, "comment":commentBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[price]-25-[more(20)]-15-|",
            options: [], metrics: nil, views: ["price":priceLbl, "more":moreBtn]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[title]-15-|",
            options: [], metrics: nil, views: ["title":titleLbl]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[date]-10-|",
            options: [], metrics: nil, views: ["date":dateLbl]))
        
        // round ava
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 9
        avaImg.clipsToBounds = true
        
    }
    
    
    
    
}
