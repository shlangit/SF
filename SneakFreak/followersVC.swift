//
//  followersVC.swift
//  SneakFreak
//
//  Created by Reid on 2/20/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

var show = String()
var user = String()

class followersVC: UITableViewController {

    // arrayst to hold data received from servers
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    // array showing who following us or who we follow
    var followArray = [String]()
    
    // default function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title at the top
        self.navigationItem.title = show.uppercaseString
        self.navigationController?.navigationBar.titleTextAttributes? = [NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!]
        
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: #selector(followersVC.back(_:)))
        backBtn.tintColor = .lightGrayColor()
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(followersVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        // load followers if tapped on following
        if show == "followers" {
            loadFollowers()
        }
        // load followings if tap on following
        if show == "following" {
            loadFollowings()
        }
        
    }
    
    // load followers
    func loadFollowers () {
        
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("following", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            // clean up
            if error == nil {
                self.followArray.removeAll(keepCapacity: false)
                
                // find related objects in follow class of parse
                for object in objects!{
                    self.followArray.append(object.valueForKey("follower") as! String)
                }
                
                // find users followed by user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    
                    // clean up
                    if error == nil{
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        // find related objects in user class of parse
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    } else{
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    // load followings
    func loadFollowings() {
        
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: user)
        followQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            // clean up
            if error == nil {
                self.followArray.removeAll(keepCapacity: false)
                
                // find related objects in follow class of parse
                for object in objects!{
                    self.followArray.append(object.valueForKey("following") as! String)
                }
                
                // find users followed by user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followArray)
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    
                    // clean up
                    if error == nil{
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        
                        // find related objects in user class of parse
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.tableView.reloadData()
                        }
                    } else{
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }


    // cell num
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }
    
    

    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell
        
        // STEP 1. connect data from server to objects
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
            
        }
        
        // STEP 2. show if current user is following or not
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        query.whereKey("following", equalTo: cell.usernameLbl.text!)
        query.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            if error == nil {
                if count == 0 {
                    cell.followBtn.setTitle("Follow", forState: UIControlState.Normal)
                    cell.followBtn.backgroundColor = .blackColor()
                } else {
                    cell.followBtn.setTitle("Following", forState: UIControlState.Normal)
                    cell.followBtn.backgroundColor = .lightGrayColor()
                }
            }
        })
        
        // hide follow button if looking at own name
        if cell .usernameLbl.text == PFUser.currentUser()?.username {
            cell.followBtn.hidden = true
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // recall cell to call further cells data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        // if user taps self, else go guest
        if cell.usernameLbl.text! == PFUser.currentUser()!.username! {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestName.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
