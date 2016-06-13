//
//  followersCell.swift
//  SneakFreak
//
//  Created by Reid on 2/20/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class followersCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    // default function
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let width = UIScreen.mainScreen().bounds.width
        
        avaImg.frame = CGRectMake(10, 10, width / 6.3, width / 6.3)
        usernameLbl.frame = CGRectMake(avaImg.frame.size.width + 25, 25, width / 3.2, 25)
        followBtn.frame = CGRectMake(width - width / 3.5 - 10, 25, width / 3.5, 30)
        //followBtn.layer.cornerRadius = followBtn.frame.size.width / 20
        
        // round image
        avaImg.layer.cornerRadius = avaImg.frame.size.width / 9
        avaImg.clipsToBounds = true
    }
    
    // tapped follow/unfollow
    @IBAction func followBtn_click(sender: AnyObject) {
        
        let title = followBtn.titleForState(.Normal)
        
        // to follow
        if title == "Follow"{
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.currentUser()?.username
            object["following"] = usernameLbl.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success{
                    self.followBtn.setTitle("Following", forState: UIControlState.Normal)
                    self.followBtn.backgroundColor = .lightGrayColor()
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else{
           
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("following", equalTo: usernameLbl.text!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success{
                                self.followBtn.setTitle("Follow", forState: UIControlState.Normal)
                                self.followBtn.backgroundColor = .blackColor()
                            } else {
                                print(error?.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })

        }
    }


    

}
