//
//  usersVC.swift
//  SneakFreak
//
//  Created by Reid on 3/6/16.
//  Name rights go to Francesca Mangrealla
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class usersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // declare search bar
    var searchBar = UISearchBar()
    
    // tableview arrays to hold info from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    // collection view arrays to hold data
    var collectionView : UICollectionView!
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page : Int = 24
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement search bar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.blackColor()
        searchBar.frame.size.width = self.view.frame.size.width - self.view.frame.size.width / 7.5
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
       // self.tabBarController?.tabBar.frame = CGRectMake(45, self.view.frame.size.height+100, ((self.tabBarController?.tabBar.frame.width)!) - 35, (self.tabBarController?.tabBar.frame.height)!)
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: #selector(usersVC.backAction(_:)))
        backBtn.tintColor = .lightGrayColor()
        self.navigationItem.leftBarButtonItem = backBtn

        
//        let button   = UIButton(type: UIButtonType.System) as UIButton
//        button.frame = CGRectMake(0, self.view.frame.size.height-((self.tabBarController?.tabBar.frame.height)!+64), self.view.frame.size.width, (self.tabBarController?.tabBar.frame.height)!)
//        button.backgroundColor = UIColor.whiteColor()
//        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        button.setTitle("Back To Your SneakFeed", forState: UIControlState.Normal)
//        
        self.navigationController?.navigationBar.titleTextAttributes? = [NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!]
//        button.addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        self.view.addSubview(button)
        
        // call functions
       // loadUsers()
        
        // call collection view
        collectionViewLaunch()
//        self.view.bringSubviewToFront(button)
    }
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        
        //self.performSegueWithIdentifier("searchSegue", sender: self)
        self.navigationController?.popViewControllerAnimated(true)
    }

// TABLE VIEW CODE
    
    // load users code
    func loadUsers() {
        
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 15
        usersQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.valueForKey("username") as! String)
                    self.avaArray.append(object.valueForKey("ava") as! PFFile)
                    
                }
                
                self.tableView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
// SEARCHBAR CODE
    
    // search updated
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // find by username
        let usernameQuery = PFQuery(className: "_User")
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // if no objects are found according to entered text in username column, find by full name
                if objects!.isEmpty {
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepCapacity: false)
                            self.avaArray.removeAll(keepCapacity: false)
                            
                            for object in objects! {
                                self.usernameArray.append(object.objectForKey("username") as! String)
                                self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    })
                    
                    // find shoe size
                    let shoeszQuery = PFUser.query()
                    shoeszQuery?.whereKey("shoesize", matchesRegex: "(?i)" + self.searchBar.text!)
                    shoeszQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepCapacity: false)
                            self.avaArray.removeAll(keepCapacity: false)
                            
                            for object in objects! {
                                self.usernameArray.append(object.objectForKey("username") as! String)
                                self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    })
                    
                    // find by city
                    let cityQuery = PFUser.query()
                    cityQuery?.whereKey("city", matchesRegex: "(?i)" + self.searchBar.text!)
                    cityQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepCapacity: false)
                            self.avaArray.removeAll(keepCapacity: false)
                            
                            for object in objects! {
                                self.usernameArray.append(object.objectForKey("username") as! String)
                                self.avaArray.append(object.objectForKey("ava") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    })
                    
                    

                }
                
                // continue username search
                self.usernameArray.removeAll(keepCapacity: false)
                self.avaArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.usernameArray.append(object.objectForKey("username") as! String)
                    self.avaArray.append(object.objectForKey("ava") as! PFFile)
                }
                
                // reload data
                self.tableView.reloadData()
                
            }
        }
        
        return true
    }
    
    //  search bar tapped
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        // hide collection view
        collectionView.hidden = true
        
        // show cancel button
        searchBar.showsCancelButton = true
    }
    
    // cancel clicked
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // dismiss keyboard
        self.searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // show collection view when search is ended, or tapping cancel
        collectionView.hidden = false
        
        // reset text box
        searchBar.text = ""
        
        // reset shown users
        loadUsers()
    }
    
    
    
    // cell number
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    // cell height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! followersCell

        // hide follow button
        cell.followBtn.hidden = true
        
        // connect cell's objects with received info from server
        cell.usernameLbl.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            
            if error == nil {
                cell.avaImg.image = UIImage(data: data!)
            }
        }
        
        return cell
    }

    // selected tableView cell - selected a user to go to
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // calling cell again to call cell data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! followersCell
        
        // if user is current user, go to home, else to guest vc
        if cell.usernameLbl.text! == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
            
        } else {
            guestName.append(cell.usernameLbl.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    
// COLLECTION VIEW CODE
    func collectionViewLaunch(){
        
        // layout of collection view
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // item size
        layout.itemSize = CGSizeMake(self.view.frame.size.width / 3.04, self.view.frame.size.width / 3.04)
        
        // direction of scroll
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        // define frame
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
        // declare collection view
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .whiteColor()
        self.view.addSubview(collectionView)
        
        // define cell for collection view
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // call function to load posts
        loadPosts()
    }
    
    
    // cell line spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    // cell inter spacing
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    // cell numb
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell config
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // define cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        // create picture imageView to show loaded pictures
        let picImg = UIImageView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        cell.addSubview(picImg)
        
        // get loaded image from array
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                picImg.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    // cell selected
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // take relevant uuid of post to load in postvc
        postuuid.append(uuidArray[indexPath.row])
        
        // present postvc programmatically
        let post = self.storyboard?.instantiateViewControllerWithIdentifier("postVC") as! postVC
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    // load posts
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.limit = page
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                // clean up
                self.picArray.removeAll(keepCapacity: false)
                self.uuidArray.removeAll(keepCapacity: false)
                
                // found objects that are related
                for object in objects! {
                    self.picArray.append(object.objectForKey("pic") as! PFFile)
                    self.uuidArray.append(object.objectForKey("uuid") as! String)
                }
                
                // reload data
                self.collectionView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // pagination
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        // scroll down for paging
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    
    // pagination
    func loadMore(){
        
        if page <= picArray.count {
            page = page + 15
            
            // load additional posts
            let query = PFQuery(className: "posts")
            query.limit = page
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    // clean up
                    self.picArray.removeAll(keepCapacity: false)
                    self.uuidArray.removeAll(keepCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.objectForKey("pic") as! PFFile)
                        self.uuidArray.append(object.objectForKey("uuid") as! String)
                        
                        // reload data
                        self.collectionView.reloadData()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
}
