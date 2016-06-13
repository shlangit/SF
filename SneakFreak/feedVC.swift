//
//  feedVC.swift
//  Instragram
//
//  Created by Reid on 2/18/16.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class feedVC: UITableViewController,UIGestureRecognizerDelegate {
    
    // UI objects
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [NSDate?]()
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    var forsaleArray = [String]()
    var priceArray = [String]()
    var followArray = [String]()
    var likedUsers = [String]()
    var responseArr = NSMutableArray()
    
    // page size
    var page : Int = 10
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "SNEAKFEED"
        
        self.navigationController?.navigationBar.titleTextAttributes? = [NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!]
        
        // automatic row height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(feedVC.refresh), name: "liked", object: nil)
        
        // indicator's x(horizontal) center
        indicator.center.x = tableView.center.x
        
        // receive notification from uploadVC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(feedVC.uploaded(_:)), name: "uploaded", object: nil)
        
        let logButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "magnify.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(feedVC.searchAction(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = .lightGrayColor()
        self.navigationItem.rightBarButtonItem = logButton
        
        let releaseButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "calendar.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(feedVC.releaseAction(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = .lightGrayColor()
        self.navigationItem.leftBarButtonItem = releaseButton
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(feedVC.removePostFromFeed(_:)), name:"RemoveDeletePostFromFeed", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(feedVC.updateLikeAndDisLikeFeed(_:)), name:"updateLikeAndDisLikeupdateLikeAndDisLikeFeed", object: nil)
        
        // calling function to load posts
        loadPosts()
        
    }
    
    
    // refreshign function after like to update the count
    func refresh() {
        
        dispatch_async(dispatch_get_main_queue(),{
            
            self.tableView.reloadData()
            
        })
    }
    
    
    func removePostFromFeed(notification:NSNotification) {
        
        if (notification.object != nil)
        {
            
            let uuid = notification.object as! String
            
            if uuidArray.contains(uuid)
            {
                let i = uuidArray.indexOf(uuid)! as Int
                
                // STEP 1. Delete cell from tableView
                
                self.usernameArray.removeAtIndex(i)
                self.avaArray.removeAtIndex(i)
                self.dateArray.removeAtIndex(i)
                self.picArray.removeAtIndex(i)
                self.titleArray.removeAtIndex(i)
                self.likedUsers.removeAtIndex(i)
                self.uuidArray.removeAtIndex(i)
                self.forsaleArray.removeAtIndex(i)
                self.priceArray.removeAtIndex(i)
                self.responseArr.removeObjectAtIndex(i)
                
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    func updateLikeAndDisLikeFeed(notification:NSNotification) {
        
        if (notification.object != nil)
        {
            
            let dataArray = (notification.object as! String).componentsSeparatedByString("@")
            
            let uuid = dataArray[0]
            
            let likes = dataArray[1]
            
            if uuidArray.contains(uuid)
            {
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    let i = self.uuidArray.indexOf(uuid)! as Int
                    
                    self.likedUsers[i] = likes
                    
                    self.tableView.reloadData()
                    
                })
            }
        }
        
    }
    
    
    // reloading func with posts  after received notification
    func uploaded(notification:NSNotification) {
        loadPosts()
    }
    @IBAction func searchAction(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("searchSegue", sender: self)
    }
    
    @IBAction func releaseAction(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("releaseSegue", sender: self)
    }
    
    // load posts
    func loadPosts() {
        
        // STEP 1. Find posts realted to people who we are following
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.followArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.followArray.append(object.objectForKey("following") as! String)
                }
                
                // append current user to see own posts in feed
                self.followArray.append(PFUser.currentUser()!.username!)
                
                // STEP 2. Find posts made by people appended to followArray
                let query = PFQuery(className: "posts")
                query.whereKey("username", containedIn: self.followArray)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        self.responseArr = NSMutableArray(array: objects! as NSArray)
                        // clean up
                        self.usernameArray.removeAll(keepCapacity: false)
                        self.avaArray.removeAll(keepCapacity: false)
                        self.dateArray.removeAll(keepCapacity: false)
                        self.picArray.removeAll(keepCapacity: false)
                        self.titleArray.removeAll(keepCapacity: false)
                        self.uuidArray.removeAll(keepCapacity: false)
                        self.likedUsers.removeAll(keepCapacity: false)
                        self.forsaleArray.removeAll(keepCapacity: false)
                        self.priceArray.removeAll(keepCapacity: false)
                        
                        
                        
                        // find related objects
                        for object in objects! {
                            self.usernameArray.append(object.objectForKey("username") as! String)
                            self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            self.dateArray.append(object.createdAt)
                            self.picArray.append(object.objectForKey("pic") as! PFFile)
                            self.titleArray.append(object.objectForKey("title") as! String)
                            self.uuidArray.append(object.objectForKey("uuid") as! String)
                            
                            if (object.objectForKey("liked_user") != nil)
                            {
                                self.likedUsers.append(object.objectForKey("liked_user") as! String)
                            }
                            else
                            {
                                self.likedUsers.append("")
                            }
                            
                            if (object.objectForKey("forSale") != nil)
                            {
                                if (object.valueForKey("forSale") as! NSString).isEqualToString("yes")
                                {
                                    
                                    if (object.valueForKey("price")?.intValue) != 0
                                    {
                                        let priceValue = "$" + (object.valueForKey("price")?.stringValue)!
                                        
                                        
                                        self.priceArray.append(priceValue)
                                    }
                                    else
                                    {
                                        self.priceArray.append("")
                                    }
                                    
                                    
                                    self.forsaleArray.append("yes")
                                }
                                else
                                {
                                    self.priceArray.append("")
                                    self.forsaleArray.append("no")
                                }
                            }
                            else
                            {
                                self.priceArray.append("")
                                self.forsaleArray.append("no")
                            }
                        }
                        
                        // reload tableView & end spinning of refresher
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    
    // scrolled down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    
    // pagination
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= uuidArray.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 15
            
            // STEP 1. Find posts realted to people who we are following
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    // clean up
                    self.followArray.removeAll(keepCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.followArray.append(object.objectForKey("following") as! String)
                    }
                    
                    // append current user to see own posts in feed
                    self.followArray.append(PFUser.currentUser()!.username!)
                    
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            
                            self.responseArr = NSMutableArray(array: objects! as NSArray)
                            
                            // clean up
                            self.usernameArray.removeAll(keepCapacity: false)
                            self.avaArray.removeAll(keepCapacity: false)
                            self.dateArray.removeAll(keepCapacity: false)
                            self.picArray.removeAll(keepCapacity: false)
                            self.titleArray.removeAll(keepCapacity: false)
                            self.uuidArray.removeAll(keepCapacity: false)
                            self.likedUsers.removeAll(keepCapacity: false)
                            self.forsaleArray.removeAll(keepCapacity: false)
                            self.priceArray.removeAll(keepCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.usernameArray.append(object.objectForKey("username") as! String)
                                self.avaArray.append(object.objectForKey("ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
                                self.picArray.append(object.objectForKey("pic") as! PFFile)
                                self.titleArray.append(object.objectForKey("title") as! String)
                                self.uuidArray.append(object.objectForKey("uuid") as! String)
                                
                                if (object.objectForKey("liked_user") != nil)
                                {
                                    self.likedUsers.append(object.objectForKey("liked_user") as! String)
                                }
                                else
                                {
                                    self.likedUsers.append("")
                                }
                                
                                if (object.objectForKey("forSale") != nil)
                                {
                                    if (object.valueForKey("forSale") as! NSString).isEqualToString("yes")
                                    {
                                        
                                        if (object.valueForKey("price")?.intValue) != 0
                                        {
                                            let priceValue = "$" + (object.valueForKey("price")?.stringValue)!
                                            
                                            
                                            self.priceArray.append(priceValue)
                                        }
                                        else
                                        {
                                            self.priceArray.append("")
                                        }
                                        
                                        
                                        self.forsaleArray.append("yes")
                                    }
                                    else
                                    {
                                        self.priceArray.append("")
                                        self.forsaleArray.append("no")
                                    }
                                }
                                else
                                {
                                    self.priceArray.append("")
                                    self.forsaleArray.append("no")
                                }
                                
                            }
                            
                            // reload tableView & stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }
    
    
    // cell numb
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseArr.count
    }
    
    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! postCell
        
        // connect objects with our information from arrays
        cell.usernameBtn.setTitle(responseArr.objectAtIndex(indexPath.row).objectForKey("username") as? String, forState: UIControlState.Normal)
        cell.usernameBtn.sizeToFit()
        cell.uuidLbl.text = responseArr.objectAtIndex(indexPath.row).objectForKey("uuid") as? String
        cell.titleLbl.text = responseArr.objectAtIndex(indexPath.row).objectForKey("title") as? String
        cell.titleLbl.sizeToFit()
        cell.priceLbl.text = priceArray[indexPath.row]
        //cell.saleLbl.text = forsaleArray[indexPath.row]
        
        
        // place profile picture
        responseArr.objectAtIndex(indexPath.row).objectForKey("ava")!.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        // place post picture
        responseArr.objectAtIndex(indexPath.row).objectForKey("pic")!.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(feedVC.likeTap(_:)))
        likeTap.numberOfTapsRequired = 2
        cell.picImg.userInteractionEnabled = true
        cell.picImg.addGestureRecognizer(likeTap)
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        // logic what to show: seconds, minuts, hours, days or weeks
        if difference.second <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second > 0 && difference.minute == 0 {
            cell.dateLbl.text = "\(difference.second)s"
        }
        if difference.minute > 0 && difference.hour == 0 {
            cell.dateLbl.text = "\(difference.minute)m"
        }
        if difference.hour > 0 && difference.day == 0 {
            cell.dateLbl.text = "\(difference.hour)h"
        }
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.dateLbl.text = "\(difference.day)d"
        }
        if difference.weekOfMonth > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth)w"
        }
        //        if responseArr.objectAtIndex(indexPath.row).objectForKey("forSale")! != nil{
        //         cell.saleLbl.backgroundColor = UIColor(patternImage: UIImage(named: "sale.png")!)
        //        }
        if let variableName = responseArr.objectAtIndex(indexPath.row).objectForKey("forSale") as? NSString {
            // If casting, use, eg,
            if variableName .isEqualToString("yes"){
                cell.saleLbl.backgroundColor = UIColor(patternImage: UIImage(named: "sale.png")!)
            }
            else
            {
                cell.saleLbl.backgroundColor = UIColor.clearColor()
            }
        }
        else {
            cell.saleLbl.backgroundColor = UIColor.clearColor()
        }
        
        let postLikedUsers = likedUsers[indexPath.row] as NSString
        
        if postLikedUsers.containsString((PFUser.currentUser()?.objectId)!)
        {
            cell.likeBtn.setTitle("like", forState: .Normal)
            cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
        }
        else
        {
            cell.likeBtn.setTitle("unlike", forState: .Normal)
            cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
        }
        
        if postLikedUsers.length != 0
        {
            cell.likeLbl.text = "\(postLikedUsers.componentsSeparatedByString(",").count)"
        }
        else
        {
            cell.likeLbl.text = ""
        }
        
        cell.likeBtn.addTarget(self, action: #selector(feedVC.likeBtn_click(_:)), forControlEvents: .TouchUpInside)
        
        
        /*
        // manipulate like button depending on did user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
        // if no any likes are found, else found likes
        if count == 0 {
        cell.likeBtn.setTitle("unlike", forState: .Normal)
        cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
        } else {
        cell.likeBtn.setTitle("like", forState: .Normal)
        cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
        }
        }
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
        cell.likeLbl.text = "\(count)"
        }
        */
        
        // asign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        // @mention is tapped
        cell.titleLbl.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            // if tapped on @currentUser go home, else go guest
            if mention.lowercaseString == PFUser.currentUser()?.username {
                let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestName.append(mention.lowercaseString)
                let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        // #hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercaseString)
            let hashvc = self.storyboard?.instantiateViewControllerWithIdentifier("hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        
        cell.titleLbl.urlLinkTapHandler = { label, handle, range in
            
            var makeUrl = handle.lowercaseString as NSString
            
            if makeUrl.containsString("https")
            {
                
            }
            else if makeUrl.containsString("http")
            {
                makeUrl = makeUrl.stringByReplacingOccurrencesOfString("http", withString: "https")
            }
            else
            {
                makeUrl = "https://" + (makeUrl as String)
            }
            
            UIApplication.sharedApplication().openURL(NSURL(string: makeUrl as String)!)
            
        }
        
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username
        {
            let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(feedVC.onTapPrice(_:)))
            cell.priceLbl.userInteractionEnabled = true
            cell.priceLbl.addGestureRecognizer(tap)
            tap.delegate = self
        }
        else
        {
            cell.priceLbl.userInteractionEnabled = false
        }
        
        return cell
    }
    
    // clicked username button
    @IBAction func usernameBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        
        // if user tapped on himself go home, else go guest
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestName.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    // clicked comment button
    @IBAction func commentBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("commentVC") as! commentVC
        comment.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    // clicked more button
    @IBAction func moreBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        
        // call cell to call further cell date
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        
        let username = responseArr.objectAtIndex(i.row).objectForKey("username")
        
        
        let currentUsername = PFUser.currentUser()?.username
        
        if  username!.isEqual(currentUsername) {
            
            
            // call index of button
            let i = sender.layer.valueForKey("index") as! NSIndexPath
            
            let cell = tableView.cellForRowAtIndexPath(i) as! postCell
            
            
            // delete
            let delete = UIAlertAction(title: "Delete", style: .Default) { (UIAlertAction) -> Void in
                
                
                // STEP 1. Delete post from server
                
                let removeObect : PFObject  = self.responseArr.objectAtIndex(i.row) as! PFObject
                
                removeObect.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        
                        
                        // STEP 2. Delete cell from tableView
                        
                        self.usernameArray.removeAtIndex(i.row)
                        self.avaArray.removeAtIndex(i.row)
                        self.dateArray.removeAtIndex(i.row)
                        self.picArray.removeAtIndex(i.row)
                        self.titleArray.removeAtIndex(i.row)
                        self.uuidArray.removeAtIndex(i.row)
                        self.likedUsers.removeAtIndex(i.row)
                        self.forsaleArray.removeAtIndex(i.row)
                        self.priceArray.removeAtIndex(i.row)
                        self.responseArr.removeObjectAtIndex(i.row)
                        
                        
                        self.tableView.reloadData()
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePost", object: cell.uuidLbl.text)
                        NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePostFromSales", object: cell.uuidLbl.text)
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                })
                
            }
            
            /*
            // STEP 3. Delete likes of post from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            likeQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
            for object in objects! {
            object.deleteEventually()
            }
            }
            })
            */
            
            // STEP 4. Clean comments of post from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            commentQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // STEP 5. Clean hashtags related to post
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            hashtagQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // COMPLAIN ACTION
            let complain = UIAlertAction(title: "Report", style: .Default) { (UIAlertAction) -> Void in
                
                // send complain to server
                let complainObj = PFObject(className: "complain")
                complainObj["by"] = PFUser.currentUser()?.username
                complainObj["to"] = cell.uuidLbl.text
                complainObj["owner"] = cell.usernameBtn.titleLabel?.text
                complainObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        self.alert("Complaint Sent", message: "Thank You! We will check it out")
                    } else {
                        self.alert("ERROR", message: error!.localizedDescription)
                    }
                })
            }
            
            // CANCEL ACTION
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            
            // create menu controller
            let menu = UIAlertController(title: "Options", message: nil, preferredStyle: .ActionSheet)
            
            
            let nolongersell = UIAlertAction(title:"No Longer Selling", style: .Default) { (UIAlertAction) -> Void in
                
                
                // find post
                let postQuery = PFQuery(className: "posts")
                postQuery.whereKey("uuid", equalTo: self.uuidArray[i.row])
                postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    
                    if error == nil {
                        
                        for object in objects! {
                            
                            object["forSale"] = "no"
                            object["price"] = 0
                            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                if error == nil {
                                    if success {
                                        
                                        dispatch_async(dispatch_get_main_queue(),{
                                            
                                            self.priceArray[i.row] = ""
                                            self.forsaleArray[i.row] = "no"
                                            
                                            self.tableView.reloadData()
                                            
                                        })
                                        
                                    }
                                    else
                                    {
                                        print(error?.localizedDescription)
                                    }
                                }
                            })
                            
                        }
                        
                    }
                }
                
                
            }
            
            
            let sale = UIAlertAction(title:"Mark For Sale", style: .Default) { (UIAlertAction) -> Void in
                
                self.alertWithInput("Edit Price", message: "What price do you want to sell for?", indexPath: i)
                
            }
            
            // if post belongs to user, he can delete post, else he can't
            if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
                
                
                if (forsaleArray[i.row] as NSString).isEqualToString("yes")
                {
                    menu.addAction(nolongersell)
                }
                else
                {
                    menu.addAction(sale)
                }
                
                
                menu.addAction(delete)
                menu.addAction(cancel)
            } else {
                menu.addAction(complain)
                menu.addAction(cancel)
            }
            
            // show menu
            self.presentViewController(menu, animated: true, completion: nil)
            
            
            
        }
        else {
            
            // DELET ACTION
            let delete = UIAlertAction(title: "Delete", style: .Default) { (UIAlertAction) -> Void in
                
                // STEP 1. Delete post from server
                
                let removeObect : PFObject  = self.responseArr.objectAtIndex(i.row) as! PFObject
                
                removeObect.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        
                        // STEP 2. Delete cell from tableView
                        
                        self.usernameArray.removeAtIndex(i.row)
                        self.avaArray.removeAtIndex(i.row)
                        self.dateArray.removeAtIndex(i.row)
                        self.picArray.removeAtIndex(i.row)
                        self.titleArray.removeAtIndex(i.row)
                        self.uuidArray.removeAtIndex(i.row)
                        self.likedUsers.removeAtIndex(i.row)
                        self.forsaleArray.removeAtIndex(i.row)
                        self.priceArray.removeAtIndex(i.row)
                        self.responseArr.removeObjectAtIndex(i.row)
                        
                        self.tableView.reloadData()
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePost", object: cell.uuidLbl.text)
                        NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePostFromSales", object: cell.uuidLbl.text)
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                })
                
                /*
                // STEP 2. Delete likes of post from server
                let likeQuery = PFQuery(className: "likes")
                likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
                likeQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                for object in objects! {
                object.deleteEventually()
                }
                }
                })
                */
                
                // STEP 3. Delete comments of post from server
                let commentQuery = PFQuery(className: "comments")
                commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
                commentQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        for object in objects! {
                            object.deleteEventually()
                        }
                    }
                })
                
                // STEP 4. Delete hashtags of post from server
                let hashtagQuery = PFQuery(className: "hashtags")
                hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
                hashtagQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        for object in objects! {
                            object.deleteEventually()
                        }
                    }
                })
            }
            
            // COMPLAIN ACTION
            let complain = UIAlertAction(title: "Complain", style: .Default) { (UIAlertAction) -> Void in
                
                // send complain to server
                let complainObj = PFObject(className: "complain")
                complainObj["by"] = PFUser.currentUser()?.username
                complainObj["to"] = cell.uuidLbl.text
                complainObj["owner"] = cell.usernameBtn.titleLabel?.text
                complainObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        self.alert("Complain has been made successfully", message: "Thank You! We will consider your complain")
                    } else {
                        self.alert("ERROR", message: error!.localizedDescription)
                    }
                })
            }
            
            // CANCEL ACTION
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            // create menu controller
            let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .ActionSheet)
            
            
            let nolongersell = UIAlertAction(title:"No Longer Selling", style: .Default) { (UIAlertAction) -> Void in
                
                
                // find post
                let postQuery = PFQuery(className: "posts")
                postQuery.whereKey("uuid", equalTo: self.uuidArray[i.row])
                postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                    
                    if error == nil {
                        
                        for object in objects! {
                            
                            object["forSale"] = "no"
                            object["price"] = 0
                            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                if error == nil {
                                    if success {
                                        
                                        dispatch_async(dispatch_get_main_queue(),{
                                            
                                            self.priceArray[i.row] = ""
                                            self.forsaleArray[i.row] = "no"
                                            self.tableView.reloadData()
                                            
                                        })
                                        
                                    }
                                    else
                                    {
                                        print(error?.localizedDescription)
                                    }
                                }
                            })
                            
                        }
                        
                    }
                }
                
                
            }
            
            
            let sale = UIAlertAction(title:"Mark For Sale", style: .Default) { (UIAlertAction) -> Void in
                
                self.alertWithInput("Edit Price", message: "What price do you want to sell for?", indexPath: i)
                
            }
            
            // if post belongs to user, he can delete post, else he can't
            if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
                
                if (forsaleArray[i.row] as NSString).isEqualToString("yes")
                {
                    menu.addAction(nolongersell)
                }
                else
                {
                    menu.addAction(sale)
                }
                
                
                menu.addAction(delete)
                menu.addAction(cancel)
            } else {
                menu.addAction(complain)
                menu.addAction(cancel)
            }
            
            // show menu
            self.presentViewController(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapPrice(sender: UITapGestureRecognizer)
    {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        
        self.alertWithInput("Edit Price", message: "What price do you want to sell for?", indexPath: indexPath)
    }
    
    func alertWithInput (title: String, message : String, indexPath : NSIndexPath)
    {
        
        var inputTextField: UITextField?
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            //Do some other stuff
            
            var price : NSString = CommonNSObject.removeWhiteSpace(inputTextField!.text!)
            
            if (price.length == 0)
            {
                price = "0"
            }
            
            // find post
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: self.uuidArray[indexPath.row])
            postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object["forSale"] = "yes"
                        object["price"] = price.integerValue
                        object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if error == nil {
                                if success {
                                    
                                    dispatch_async(dispatch_get_main_queue(),{
                                        
                                        self.priceArray[indexPath.row] = "$" + (price as String)
                                        self.forsaleArray[indexPath.row] = "yes"
                                        self.tableView.reloadData()
                                        
                                    })
                                    
                                }
                                else
                                {
                                    print(error?.localizedDescription)
                                }
                            }
                        })
                        
                    }
                    
                }
            }
            
            
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            // you can use this text field
            inputTextField = textField
            
            inputTextField?.text = self.priceArray[indexPath.row].stringByReplacingOccurrencesOfString("$", withString: "")
            
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    // alert action
    func alert (title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // click like button
    @IBAction func likeBtn_click(sender: UIButton) {
        
        let position = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(position)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! postCell
        
        let checkAndUpdateUsers = likedUsers[(indexPath?.row)!]
        
        let currentUser = (PFUser.currentUser()?.objectId)!
        
        let query = PFQuery(className: "posts")
        query.whereKey("uuid", equalTo: uuidArray[(indexPath?.row)!])
        
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                if checkAndUpdateUsers.containsString(currentUser)
                {
                    
                    objects?.last!["liked_user"] = CommonNSObject.onDisLikePost(checkAndUpdateUsers, userObjectId: currentUser)
                    
                    
                }
                else
                {
                    
                    objects?.last!["liked_user"] = CommonNSObject.onLikePost(checkAndUpdateUsers, userObjectId: currentUser)
                    
                    
                }
                
                objects?.last!.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    
                    if success {
                        
                        self.likedUsers[(indexPath?.row)!] = objects?.last!.valueForKey("liked_user") as! String
                        self.tableView.reloadData()
                        
                        self.reloadLikes(self.likedUsers[(indexPath?.row)!], uuid: self.uuidArray[(indexPath?.row)!])
                        
                        if checkAndUpdateUsers.containsString(currentUser)
                        {
                            // Delete notification
                            let newsQuery = PFQuery(className: "news")
                            newsQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                            newsQuery.whereKey("to", equalTo: cell.usernameBtn.titleLabel!.text!)
                            newsQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
                            newsQuery.whereKey("type", equalTo: ["like"])
                            newsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                        }
                        else
                        {
                            
                            // send notification that a link was made
                            if cell.usernameBtn.titleLabel?.text != PFUser.currentUser()?.username {
                                let newsObj = PFObject(className: "news")
                                newsObj["by"] = PFUser.currentUser()?.username
                                newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                                newsObj["to"] = cell.usernameBtn.titleLabel!.text!
                                newsObj["owner"] = cell.usernameBtn.titleLabel!.text!
                                newsObj["uuid"] = cell.uuidLbl.text
                                newsObj["type"] = "like"
                                newsObj["checked"] = "no"
                                newsObj.saveEventually()
                                
                            }
                        }
                        
                    }
                })
                
            } else
            {
                print(error?.localizedDescription)
            }
        })
        
    }
    
    
    // double tap like button
    func likeTap(sender: UITapGestureRecognizer)
    {
        
        let position: CGPoint =  sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(position)!
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! postCell
        
        let checkAndUpdateUsers = likedUsers[(indexPath.row)]
        
        let currentUser = (PFUser.currentUser()?.objectId)!
        
        if !checkAndUpdateUsers.containsString(currentUser)
        {
            
            let query = PFQuery(className: "posts")
            query.whereKey("uuid", equalTo: uuidArray[(indexPath.row)])
            
            query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    objects?.last!["liked_user"] = CommonNSObject.onLikePost(checkAndUpdateUsers, userObjectId: currentUser)
                    
                    objects?.last!.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if success {
                            
                            self.likedUsers[(indexPath.row)] = objects?.last!.valueForKey("liked_user") as! String
                            self.tableView.reloadData()
                            
                            self.reloadLikes(self.likedUsers[(indexPath.row)], uuid: self.uuidArray[(indexPath.row)])
                            
                            
                            // send notification that a link was made
                            if cell.usernameBtn.titleLabel?.text != PFUser.currentUser()?.username {
                                let newsObj = PFObject(className: "news")
                                newsObj["by"] = PFUser.currentUser()?.username
                                newsObj["ava"] = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                                newsObj["to"] = cell.usernameBtn.titleLabel!.text!
                                newsObj["owner"] = cell.usernameBtn.titleLabel!.text!
                                newsObj["uuid"] = cell.uuidLbl.text
                                newsObj["type"] = "like"
                                newsObj["checked"] = "no"
                                newsObj.saveEventually()
                                
                            }
                            
                        }
                    })
                    
                } else
                {
                    print(error?.localizedDescription)
                }
            })
        }
        
    }
    
    func reloadLikes (likeUsers : String ,  uuid: String)
    {
        
        
        let appendData = uuid + "@" + likeUsers
        
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateLikeUnLikeOnPostDetails", object: appendData)
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateLikeUnLikeOnSales", object: appendData)
    }
    
}
