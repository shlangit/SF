//
//  headerView.swift
//  SneakFreak
//
//  Created by Reid on 2/19/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class headerView: UICollectionReusableView {
    
    
    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var headbg: UILabel!
   // @IBOutlet weak var headbg: UILabel!
    
    @IBOutlet weak var fullnameLbl: UILabel!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var cityTxt: UILabel!
    @IBOutlet weak var shoeSizeLbl: UILabel!
    @IBOutlet weak var verifiedLbl: UIImageView!
    @IBOutlet weak var sztitle: UILabel!
    
   // @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var followings: UILabel!

    //@IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var followertitle: UILabel!
    @IBOutlet weak var followingtitle: UILabel!
    
//    @IBOutlet weak var setButton: UIButton!

    @IBOutlet weak var button: UIButton!
    
    // default func
    override func awakeFromNib() {
        super.awakeFromNib()
    
    // OG Alignment
//        let width = UIScreen.mainScreen().bounds.width
//        avaImg.frame = CGRectMake(width / 2.8, 15, width / 3.5, width / 3.5)
//        
//        //posts.frame = CGRectMake(5, avaImg.frame.origin.y + 170, 50, 30)
//        followers.frame = CGRectMake(15, avaImg.frame.origin.y + 175, 50, 30)
//        followings.frame = CGRectMake(width / 3.5, avaImg.frame.origin.y + 175, 50, 30)
//        shoeSizeLbl.frame = CGRectMake(width / 2, avaImg.frame.origin.y + 175, 60, 30)
//
//        //postTitle.center = CGPointMake(posts.center.x, posts.center.y + 20)
//        followertitle.center = CGPointMake(followers.center.x, followers.center.y + 20)
//        followingtitle.center = CGPointMake(followings.center.x, followings.center.y + 20)
//        sztitle.center = CGPointMake(shoeSizeLbl.center.x, shoeSizeLbl.center.y + 20)
//
//        button.frame = CGRectMake(width - 105, followertitle.center.y - 20, 85, 22)
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor(red: 0 / 255.5, green: 0 / 255.5, blue: 0 / 255.5, alpha: 1).CGColor
//        button.layer.cornerRadius = button.frame.size.width / 7
//        
//        usernameLbl.frame = CGRectMake(avaImg.frame.origin.x, avaImg.frame.origin.y + avaImg.frame.size.height + 5, avaImg.frame.width, 30)
//        cityTxt.frame = CGRectMake(0, usernameLbl.frame.origin.y + 20, width, 30)
//        
//        // round ava
//        avaImg.layer.cornerRadius = avaImg.frame.size.width / 7
//        avaImg.clipsToBounds = true

        
    // allignment 
        let width = UIScreen.mainScreen().bounds.width
        
        avaImg.frame = CGRectMake(0, 0, width, 238)
        
        headbg.frame = CGRectMake(0, avaImg.frame.height - 75, width, 75)
        
        usernameLbl.frame = CGRectMake(10, avaImg.frame.height - 70, 110, 30)
        usernameLbl.adjustsFontSizeToFitWidth = true
        
        //      verifiedLbl.frame = CGRectMake(usernameLbl.center.x , avaImg.frame.height + 22, 15, 15)
        cityTxt.frame = CGRectMake(width - 175, avaImg.frame.height - 73, 160, 30)
    
//        followers.frame = CGRectMake(width - 197, avaImg.frame.height - 70, 20, 25)
//        followertitle.frame = CGRectMake(followers.frame.origin.x + followers.frame.width + 5, avaImg.frame.height - 70, 70, 25)
        //      followertitle.center = CGPointMake(followers.center.x, followers.center.y + 15)
        
//        followings.frame = CGRectMake(followertitle.frame.origin.x + followertitle.frame.width + 5, avaImg.frame.height - 70, 20, 25)
//        followingtitle.frame = CGRectMake(followings.frame.origin.x + followings.frame.width + 5, avaImg.frame.height - 70, 70, 25)
        //      followingstitle.center = CGPointMake(followers.center.x, followers.center.y + 15)
        
//        shoeSizeLbl.frame = CGRectMake(10, avaImg.frame.height - 22, 20, 22)
        
        //      posts.frame = CGRectMake(width / 3, button.frame.origin.y - 40, width / 3, 20)
        //      postTitle.center = CGPointMake(posts.center.x, posts.center.y + 20)
        
        button.frame = CGRectMake(width - 100, avaImg.frame.height - 35, 90, 25)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 255 / 255.5, green: 255 / 255.5, blue: 255 / 255.5, alpha: 1).CGColor
        button.layer.cornerRadius = button.frame.size.width / 8

        
        // round prof image
        // avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
        avaImg.clipsToBounds = true
        
        followers.frame = CGRectMake(15, avaImg.frame.height - 45, 50, 30)
        followings.frame = CGRectMake(width / 3.8, avaImg.frame.height - 45, 50, 30)
        shoeSizeLbl.frame = CGRectMake(width / 2.2, avaImg.frame.height - 45, 60, 30)
        //
        //        //postTitle.center = CGPointMake(posts.center.x, posts.center.y + 20)
        followertitle.center = CGPointMake(followers.center.x, followers.center.y + 15)
        followingtitle.center = CGPointMake(followings.center.x, followings.center.y + 15)
        sztitle.center = CGPointMake(shoeSizeLbl.center.x, shoeSizeLbl.center.y + 15)
        
//
    }
    
    // setup to show if user is verified
    
    
    // follow button clicked
    @IBAction func followBtn_clicked(sender: AnyObject) {
        
        
        let title = button.titleForState(.Normal)
        
        // to follow
        if title == "Follow"{
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.currentUser()?.username
            object["following"] = guestName.last!
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success{
                    self.button.setTitle("Following", forState: UIControlState.Normal)
                    //self.button.backgroundColor = UIColor(red: 94 / 255.5, green: 97 / 255.5, blue: 103 / 255.5, alpha: 1)
                    
                    // send follow notificaiton
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.currentUser()?.username
                    newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                    newsObj["to"] = guestName.last
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                } else {
                    print(error?.localizedDescription)
                }
            })
        } else{
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("following", equalTo: guestName.last!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success{
                                self.button.setTitle("Follow", forState: UIControlState.Normal)
                                //self.button.backgroundColor = .blackColor()
                                
                                // Delete follow notification
                                let newsQuery = PFQuery(className: "news")
                                newsQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                                newsQuery.whereKey("to", equalTo: guestName.last!)
                                newsQuery.whereKey("type", equalTo: ["follow"])
                                newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    }
                                })

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
