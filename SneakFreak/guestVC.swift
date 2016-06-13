//
//  guestVC.swift
//  SneakFreak
//
//  Created by Reid on 2/22/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

var guestName = [String]()

private let reuseIdentifier = "Cell"

class guestVC: UICollectionViewController {

    // UI Objects
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    // default when VC is open
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.alwaysBounceVertical = true
        // background color
        // self.collectionView?.backgroundColor = .whiteColor()
        
        // name on top
        let title = guestName.last
        
        // name on top
        self.navigationItem.title = title?.uppercaseString
        
        // find users followed by user
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: title!)
        query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            
            // clean up
            if error == nil{
                
                if objects?.count != 0
                {
                    self.navigationItem.title = (objects?.last!.objectForKey("fullname") as! String).uppercaseString

                }
                
                
            } else{
                print(error!.localizedDescription)
            }
        })

        
        // new back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: #selector(guestVC.back(_:)))
        backBtn.tintColor = .lightGrayColor()
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(guestVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(guestVC.refresh), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts func
        loadPosts()
        
    }

    // back function
    func back (sender : UIBarButtonItem) {
    
        // push back
        self.navigationController?.popViewControllerAnimated(true)
        
        // clean guest username or deduct the last guest username from guestname array
        if !guestName.isEmpty {
            guestName.removeLast()
        }
    }
    
    // refresh function
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    
    
    // load posts
    func loadPosts() {
        
        // load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestName.last!)
        query.limit = page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    // hold found info in uuid array
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // load more posts while scrolling
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            self.loadMore()
        }
    }
    
    // pagination while scrolling to get data
    func loadMore(){
        
        // if more objects in posts
        if page <= picArray.count {
            
            // increase page size
            page = page + 12
            
            // load more
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: guestName.last!)
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
                    
                    print("Loaded +\(self.page)")
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
        
        // connect data from array to picImg object from pictureCell class
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }

    // header config
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // define header
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! headerView
        
        // STEP 1. Load data of guest
        let infoQuery = PFQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestName.last!)
        infoQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    let alert = UIAlertController(title: "\(guestName.last!.uppercaseString)", message: "User does not exist!", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                
                // find related to user info
                for object in objects! {
                    header.usernameLbl.text = (object.objectForKey("username") as? String)?.uppercaseString
                    header.cityTxt.text = (object.objectForKey("city") as? String)?.uppercaseString
                  //  header.cityTxt.sizeToFit()
                    header.shoeSizeLbl.text = (object.objectForKey("shoesize") as! String!)
                  //  header.shoeSizeLbl.sizeToFit()
                    header.verifiedLbl.hidden = true
                    
                    let avaFile : PFFile = (object.objectForKey("ava") as? PFFile)!
                    avaFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
                        header.avaImg.image = UIImage(data: data!)
                    })
                }
            } else {
                print(error?.localizedDescription)
            }
            
        }
        
        // STEP 2. Show do current user follow or not
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followQuery.whereKey("following", equalTo: guestName.last!)
        followQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            
            if error == nil {
                if count == 0 {
                    header.button.setTitle("Follow", forState: .Normal)
                    //header.button.backgroundColor = .blackColor()
                } else {
                    header.button.setTitle("Following", forState: UIControlState.Normal)
                    //header.button.backgroundColor = UIColor(red: 94 / 255.5, green: 97 / 255.5, blue: 103 / 255.5, alpha: 1)
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // STEP 3. Count Stats
        // count posts
//        let posts = PFQuery(className: "posts")
//        posts.whereKey("username", equalTo: guestName.last!)
//        posts.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
//            
//            if error == nil {
//                header.posts.text = "\(count)"
//            } else {
//                print(error?.localizedDescription)
//            }
//            
//        }
        
        // count followers
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestName.last!)
        followers.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            
            if error == nil{
                header.followers.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // count followings
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: guestName.last!)
        followings.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            
            if error == nil {
                header.followings.text = "\(count)"
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // STEP 4. Implement Tap Gestures
//        let postsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.postsTap))
//        postsTap.numberOfTapsRequired = 1
//        header.posts.userInteractionEnabled = true
//        header.posts.addGestureRecognizer(postsTap)
//        
        
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.userInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
        
        let followersTitleTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followersTap))
        followersTitleTap.numberOfTapsRequired = 1
        header.followertitle.userInteractionEnabled = true
        header.followertitle.addGestureRecognizer(followersTitleTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingsTap))
        followingsTap.numberOfTapsRequired = 1
        header.followings.userInteractionEnabled = true
        header.followings.addGestureRecognizer(followingsTap)
        
        let followingsTitleTap = UITapGestureRecognizer(target: self, action: #selector(guestVC.followingsTap))
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
        user = guestName.last!
        show = "followers"
        
        // defined followers VC in storybaord
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        // navigate to it
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    func followingsTap(){
        user = guestName.last!
        show = "following"
        
        // define followings vc in storyboard
        let followings = self.storyboard?.instantiateViewControllerWithIdentifier("followersVC") as! followersVC
        
        // navigate to it
        self.navigationController?.pushViewController(followings, animated: true)
        
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
