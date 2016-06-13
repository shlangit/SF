//
//  postVC.swift
//  SneakFreak
//
//  Created by Reid on 2/26/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()

class postVC: UITableViewController,UIGestureRecognizerDelegate {
    
    // arrays to hold server data
    var avaArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [NSDate?]()
    var picArray = [PFFile]()
    var uuidArray = String()
    var titleArray = [String]()
    var forsaleArray = [String]()
    var price = String()
    var likedUsers = String()
    var isAlreadyMarkAsSale = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PHOTO"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postVC.updateLikeAndDisLike(_:)), name:"UpdateLikeUnLikeOnPostDetails", object: nil)
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: #selector(postVC.back(_:)))
        backBtn.tintColor = UIColor.lightGrayColor()
        self.navigationItem.leftBarButtonItem = backBtn
        
        //swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(postVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postVC.refresh), name: "liked", object: nil)
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // find post
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                // clean up
                self.avaArray.removeAll(keepCapacity: false)
                self.usernameArray.removeAll(keepCapacity: false)
                self.dateArray.removeAll(keepCapacity: false)
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray = ""
                self.likedUsers = ""
                self.titleArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    
                    print((object.valueForKey("ava") as! PFFile).url)
                    
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.avaArray.append(object.valueForKey("ava") as! PFFile)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                    self.uuidArray = (object.valueForKey("uuid") as! String)
                    
                    if (object.objectForKey("liked_user") != nil)
                    {
                        self.likedUsers = object.objectForKey("liked_user") as! String
                    }
                    else
                    {
                        self.likedUsers = ""
                    }
                    
                    self.titleArray.append(object.valueForKey("title") as! String)
                    
                    if (object.objectForKey("forSale") != nil)
                    {
                        if (object.valueForKey("forSale") as! NSString).isEqualToString("yes")
                        {
                            
                            if (object.valueForKey("price")?.intValue) != 0
                            {
                                self.price = (object.valueForKey("price")?.stringValue)!
                            }
                            else
                            {
                                self.price = ""
                            }
                            
                            
                            self.isAlreadyMarkAsSale = true
                            self.forsaleArray.append("yes")
                        }
                        else
                        {
                            self.isAlreadyMarkAsSale = false
                            self.forsaleArray.append("no")
                        }
                    }
                    else
                    {
                        self.isAlreadyMarkAsSale = false
                        self.forsaleArray.append("no")
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    // refresh function
    func refresh() {
        self.tableView.reloadData()
    }
    
    func updateLikeAndDisLike(notification:NSNotification) {
        
        if (notification.object != nil)
        {
            
            let dataArray = (notification.object as! String).componentsSeparatedByString("@")
            
            let uuid = dataArray[0]
            
            let likes = dataArray[1]
            
            if self.uuidArray.containsString(uuid)
            {
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.likedUsers = likes
                    
                    self.tableView.reloadData()
                    
                })
                
            }
        }
        
    }
    
    // number of cells
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! postCell
        
        
        // connect objects with info from arrays
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], forState: UIControlState.Normal)
        cell.usernameBtn.sizeToFit()
        cell.uuidLbl.text = uuidArray
        cell.titleLbl.text = titleArray[indexPath.row]
        cell.titleLbl.sizeToFit()
        
        // place profile picture
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data: NSData?, error:NSError?) -> Void in
            cell.avaImg.image = UIImage(data: data!)
        }
        
        // place post picture
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(postVC.likeTap(_:)))
        likeTap.numberOfTapsRequired = 2
        cell.picImg.userInteractionEnabled = true
        cell.picImg.addGestureRecognizer(likeTap)
        
        // calculate post date
        let from = dateArray[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        // logic to show time
        if difference.second <= 0 {
            cell.dateLbl.text = ("now")
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
        
        let postLikedUsers = self.likedUsers as NSString
        
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
        
        cell.likeBtn.addTarget(self, action: #selector(postVC.likeBtn_click(_:)), forControlEvents: .TouchUpInside)
        
        /*
        // manipulate like button if liked or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
        // if no likes are found
        if count == 0 {
        cell.likeBtn.setTitle("unlike", forState: .Normal)
        cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), forState: .Normal)
        
        } else {
        cell.likeBtn.setTitle("like", forState: .Normal)
        cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), forState: .Normal)
        }
        }
        
        
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
        
        cell.likeLbl.text = "\(count)"
        }
        */
        
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
        
        if self.isAlreadyMarkAsSale
        {
            
            if (self.price as NSString).length != 0
            {
                cell.priceLbl.text = "$" + self.price
            }
            else
            {
                cell.priceLbl.text = ""
            }
            
            
            cell.saleLbl.hidden = false
            cell.saleLbl.backgroundColor = UIColor(patternImage: UIImage(named: "sale.png")!)
            
            let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postVC.onTapPrice(_:)))
            cell.priceLbl.userInteractionEnabled = true
            cell.priceLbl.addGestureRecognizer(tap)
            tap.delegate = self
        }
        else
        {
            cell.priceLbl.userInteractionEnabled = false
            cell.priceLbl.text = ""
            cell.priceLbl.hidden = true
            cell.saleLbl.backgroundColor = UIColor.clearColor()
            
        }
        
        return cell
    }
    
    // clicked username button
    @IBAction func usernameBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        // if user taps own name, else guest
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
        
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        // send related data to global variables on comment VC
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("commentVC") as! commentVC
        comment.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(comment, animated: true)
        
    }
    
    // clicked more button
    @IBAction func moreBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        let cell = tableView.cellForRowAtIndexPath(i) as! postCell
        
        // MARK FOR SALE
        
        let sale = UIAlertAction(title:"Mark For Sale", style: .Default) { (UIAlertAction) -> Void in
            
            
            self.alertWithInput("Let's Sell Your Shoe!", message: "What price do you want for it?", productPrice: "")
            
        }
        
        let nolongersell = UIAlertAction(title:"No Longer Selling", style: .Default) { (UIAlertAction) -> Void in
            
            
            // find post
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: postuuid.last!)
            postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object["forSale"] = "no"
                        object["price"] = 0
                        object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if error == nil {
                                if success {
                                    
                                    dispatch_async(dispatch_get_main_queue(),{
                                        
                                        // send notification to rootview controller to update shown posts
                                        NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                                        
                                        self.price = ""
                                        
                                        self.isAlreadyMarkAsSale = false
                                        
                                        self.tableView.reloadData()
                                        
                                    })
                                    
                                } else {
                                    print(error?.localizedDescription)
                                }
                            }
                        })
                        
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            
        }
        
        // delete
        let delete = UIAlertAction(title: "Delete", style: .Default) { (UIAlertAction) -> Void in
            
            // STEP 1. Delete cell from tableView
            self.usernameArray.removeAtIndex(i.row)
            self.avaArray.removeAtIndex(i.row)
            self.dateArray.removeAtIndex(i.row)
            self.picArray.removeAtIndex(i.row)
            self.titleArray.removeAtIndex(i.row)
            self.uuidArray = ""
            self.likedUsers = ""
            self.forsaleArray.removeAtIndex(i.row)
            // STEP 2. Delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
            postQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success {
                                // send notification to rootview controller to update shown posts
                                
                                NSNotificationCenter.defaultCenter().postNotificationName("RemoveDeletePost", object: cell.uuidLbl.text)
                                
                                // push back
                                self.navigationController?.popViewControllerAnimated(true)
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
        
        
        // if post belongs to user, he can delete post, else he can't
        if cell.usernameBtn.titleLabel?.text == PFUser.currentUser()?.username {
            
            if self.isAlreadyMarkAsSale
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
    
    @IBAction func onTapPrice(sender: UITapGestureRecognizer)
    {
        self.alertWithInput("Edit Price", message: "What price do you want to sell for?", productPrice:self.price)
    }
    
    // alert action
    func alert (title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertWithInput (title: String, message : String, productPrice : String)
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
            
            var price : NSString = self.removeWhiteSpace(inputTextField!.text!)
            
            if (price.length == 0)
            {
                price = "0"
            }
            
            // find post
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: postuuid.last!)
            postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object["forSale"] = "yes"
                        object["price"] = price.integerValue
                        object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if error == nil {
                                if success {
                                    
                                    dispatch_async(dispatch_get_main_queue(),{
                                        
                                        if !self.isAlreadyMarkAsSale
                                        {
                                            self.navigationController?.popViewControllerAnimated(true)
                                        }
                                        
                                        // send notification to rootview controller to update shown posts
                                        NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                                        
                                        self.price = price as String
                                        
                                        self.isAlreadyMarkAsSale = true
                                        
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
                    
                    self.tableView.reloadData()
                }
            }
            
            
        }
        actionSheetController.addAction(nextAction)
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            // you can use this text field
            inputTextField = textField
            
            if self.isAlreadyMarkAsSale
            {
                inputTextField?.text = self.price
            }
            
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func removeWhiteSpace (str : String) -> String
    {
        
        var refineStr : String
        
        refineStr = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        refineStr = refineStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return refineStr
    }
    
    // swipe back
    func back(sender: UIBarButtonItem) {
        
        // back button
        self.navigationController?.popViewControllerAnimated(true)
        
        // clean post uuid from last
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
    
    // click like button
    @IBAction func likeBtn_click(sender: UIButton) {
        
        let position = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(position)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath!) as! postCell
        
        let currentUser = (PFUser.currentUser()?.objectId)!
        
        // STEP 2. Request last (page size 15) comments
        let query = PFQuery(className: "posts")
        query.whereKey("uuid", equalTo: self.uuidArray)
        
        
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                if self.likedUsers.containsString(currentUser)
                {
                    
                    objects?.last!["liked_user"] = CommonNSObject.onDisLikePost(self.likedUsers, userObjectId: currentUser)
                    
                    
                }
                else
                {
                    
                    objects?.last!["liked_user"] = CommonNSObject.onLikePost(self.likedUsers, userObjectId: currentUser)
                    
                    
                }
                
                objects?.last!.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    
                    if success {
                        
                        self.likedUsers = objects?.last!.valueForKey("liked_user") as! String
                        self.tableView.reloadData()
                        
                        self.reloadLikes(self.likedUsers, uuid: self.uuidArray)
                        
                        if self.likedUsers.containsString(currentUser)
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
        
        let currentUser = (PFUser.currentUser()?.objectId)!
        
        if !self.likedUsers.containsString(currentUser)
        {
            
            let query = PFQuery(className: "posts")
            query.whereKey("uuid", equalTo: self.uuidArray)
            
            query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    objects?.last!["liked_user"] = CommonNSObject.onLikePost(self.likedUsers, userObjectId: currentUser)
                    
                    objects?.last!.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if success {
                            
                            self.likedUsers = objects?.last!.valueForKey("liked_user") as! String
                            self.tableView.reloadData()
                            
                            self.reloadLikes(self.likedUsers, uuid: self.uuidArray)
                            
                            
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateLikeAndDisLikeupdateLikeAndDisLikeFeed", object: appendData)
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateLikeUnLikeOnSales", object: appendData)
        
    }
    
}
