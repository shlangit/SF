//  homeVC.swift
//  SneakFreak

//  Name rights go to Francesca Mangrealla

//  Created by Reid on 2/19/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class homeVC: UICollectionViewController {
    
    // refresher variable
    var refresher : UIRefreshControl!
    
    // size of page on initial load
    var page : Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
        
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()

        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        self.navigationController?.navigationBar.titleTextAttributes? = [NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!]
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationItem.leftBarButtonItem?.tintColor = UIColor.lightGrayColor()
        
        // UINavigationBar.appearance().barTintColor = UIColor(red: 10/255, green: 30/255, blue: 200/255, alpha: 1)
        // background color
        
//        collectionView?.backgroundColor = .whiteColor()

        // title at the top
        self.navigationItem.title = PFUser.currentUser()?.valueForKey("fullname")?.uppercaseString

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(homeVC.removePost(_:)), name:"RemoveDeletePost", object: nil)

        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(homeVC.refresh as (homeVC) -> () -> ()), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
      
      // receive notification from editVC
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(homeVC.reload(_:)), name: "reload", object: nil)
        
        // receive notification from uploadVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(homeVC.refresh(_:)), name: "refreshProfileData", object: nil)
        
      // load posts func
        loadPosts()
        
    }
    
    // refresh pull func
    func refresh(){
        
        // reload data info
        collectionView?.reloadData()
        
        // stop refresh animating
        refresher.endRefreshing()
    }
    
    // reloading func after received notification
    func reload(notification:NSNotification) {
        collectionView?.reloadData()
    }
    
    func refresh(notification:NSNotification) {
        loadPosts()
    }
    
    func removePost(notification:NSNotification) {
        
        if (notification.object != nil)
        {
            
            let uuid = notification.object as! String
            
            if uuidArray.contains(uuid)
            {
                let index = uuidArray.indexOf(uuid)
                
                uuidArray.removeAtIndex(index!)
                picArray.removeAtIndex(index!)
                
                NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePostFromSales", object: uuid)
                NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePostFromFeed", object: uuid)
                
            }
        }
        
        collectionView?.reloadData()
    }
    
    
    // load posts func
    func loadPosts() {
        
        // request infomration from server
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                // find objects related to our request
                for object in objects! {
                    
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }

    // load more posts while scrolling
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            self.loadMore()
        }
    }
    
    func loadMore(){
        
        // if more objects in posts
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    //clean up
                    self.uuidArray.removeAll(keepCapacity: false)
                    self.picArray.removeAll(keepCapacity: false)
                    
                    // find relate objects
                    for object in objects! {
                        self.uuidArray.append(object.valueForKey("uuid") as! String)
                        self.picArray.append(object.valueForKey("pic") as! PFFile)
                    }
                    
                    self.collectionView?.reloadData()
                    
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    // cell numbers
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell size
    func collectionView(collectionVeiw: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3.03, height: self.view.frame.size.width / 3.03)
        return size
    }
    
    // cell configuration
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! pictureCell
        
        // get picture from the picArray
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.picImg.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    // header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView

        // STEP 1. Get user data
        // get users data with connections to columns of PFUser Class
        
        header.usernameLbl.text = (PFUser.currentUser()!.objectForKey("username") as? String)?.uppercaseString
        //header.usernameLbl.textAlignment = .Center
        header.cityTxt.text = (PFUser.currentUser()?.objectForKey("city") as? String)?.uppercaseString
       //header.cityTxt.textAlignment = .Center;
       // header.cityTxt.sizeToFit()
// TO SHOW SHOE SIZE ADD LABEL AND CONNECT BACK TO STORYBOARD
        header.shoeSizeLbl.text = (PFUser.currentUser()?.objectForKey("shoesize") as! String!)
//        header.shoeSizeLbl.sizeToFit()
        header.button.setTitle("Edit Info", forState: UIControlState.Normal)
        
        header.verifiedLbl.hidden = true
        
//      header.button.backgroundColor = UIColor.blackColor()
//      header.button.layer.borderWidth = 0.5
//      header.button.layer.borderColor = UIColor.blackColor().CGColor
        
        let avaQuery = PFUser.currentUser()?.objectForKey("ava") as! PFFile
        avaQuery.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            header.avaImg.image = UIImage (data: data!)
        }
        
        // STEP 2. Count Statistics
        // count total posts
//        let posts = PFQuery(className: "posts")
//        posts.whereKey("username", equalTo: PFUser.currentUser()!.username!)
//        posts.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
//            if error == nil{
//                header.posts.text = "\(count)"
//            }
//        })
        
        // count total followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.currentUser()!.username!)
        followers.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.followers.text = "\(count)"
            }
        }
        
        // count total following
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followings.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if error == nil {
                header.followings.text = "\(count)"
            }
        }
        
        let query = PFQuery(className: "user")
        query.whereKey("verified", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (object:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                if query == true{
                    header.verifiedLbl.hidden = false
                }
            }
        }
        
        // STEP 3. Implement tap gestures
        // tap posts
//        let postsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.postsTap))
//        postsTap.numberOfTapsRequired = 1
//        header.posts.userInteractionEnabled = true
//        header.posts.addGestureRecognizer(postsTap)
//
        // tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followersTitleTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followersTap))
        followersTitleTap.numberOfTapsRequired = 1
        header.followertitle.userInteractionEnabled = true
        header.followertitle.addGestureRecognizer(followersTitleTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.userInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        let followingsTitleTap = UITapGestureRecognizer(target: self, action: #selector(homeVC.followingsTap))
        followingsTitleTap.numberOfTapsRequired = 1
        header.followingtitle.userInteractionEnabled = true
        header.followingtitle.addGestureRecognizer(followingsTitleTap)
        
        
        return header
    }
    
    // tapped posts label
    func postsTap() {
        if !picArray.isEmpty {
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    // tapped followers label
    func followersTap() {
        
        user = PFUser.currentUser()!.username!
        show = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    func followingsTap() {
        
        user = PFUser.currentUser()!.username!
        show = "following"
        
        // make references to followersVC
        let following = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        // present
        self.navigationController?.pushViewController(following, animated: true)
    }

    // clicked logout
    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            
            if error == nil {
                // remove logged in user from App memory
                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let signIn = self.storyboard?.instantiateViewControllerWithIdentifier("signInVC") as! signInVC
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = signIn
            }
        }
    }
    
    // go post
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // send post uuid to "postuuid variable"
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
        
    }
    

}
