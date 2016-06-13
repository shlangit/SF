//
//  pictureCell.swift
//  SneakFreak
//
//  Created by Reid on 2/19/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit

class pictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    
    // default func
    override func awakeFromNib() {
        
        let width = UIScreen.mainScreen().bounds.width
        
        picImg.frame = CGRectMake(0, 0, width / 3.03, width / 3.03 )
        
    }
}
