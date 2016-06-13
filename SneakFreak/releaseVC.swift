//
//  releaseVC.swift
//  SneakFreak
//
//  Created by Reid on 3/22/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//


import UIKit
import Parse


class releaseVC: UITableViewController {
    
    // arrays to hold data from server
    var infoArray = [String]()
    var picArray = [PFFile]()
    var dateArray = [NSDate]()
    
    
    // defualt func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic tableView height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
        // title at the top
        self.navigationItem.title = "UPCOMING RELEASES"
        self.navigationController?.navigationBar.titleTextAttributes? = [NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!]
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(image: UIImage(named: "back.png"), style: .Plain, target: self, action: #selector(releaseVC.backAction(_:)))
        backBtn.tintColor = .lightGrayColor()
        self.navigationItem.leftBarButtonItem = backBtn
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(releaseVC.backAction(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        // find post
        let postQuery = PFQuery(className: "releases")
        postQuery.orderByAscending("releaseDate")
        postQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                // clean up
                self.picArray.removeAll(keepCapacity: false)
                self.infoArray.removeAll(keepCapacity: false)
                self.dateArray.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.infoArray.append(object.valueForKey("title") as! String)
                    self.picArray.append(object.valueForKey("pic") as! PFFile)
                    self.dateArray.append(object.valueForKey("releaseDate") as! NSDate)
                }
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    // refresh function
    func refresh() {
        self.tableView.reloadData()
    }
    
    
    @IBAction func backAction(sender: UIBarButtonItem) {
        
        //self.performSegueWithIdentifier("searchSegue", sender: self)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // cell numb
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    
    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! releaseCell
        
        
        // connect objects with info from arrays
        cell.infoLbl.setTitle(infoArray[indexPath.row], forState: UIControlState.Normal)
        cell.infoLbl.sizeToFit()
        
        var shortDate: String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.stringFromDate(dateArray[indexPath.row])
        }
        
        cell.dateLbl.text = shortDate
        
        cell.dateLbl.sizeToFit()
        
        // place profile picture
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data: NSData?, error:NSError?) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        // place picture
        picArray[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.picImg.image = UIImage(data: data!)
        }
        
        cell.infoLbl.layer.setValue(indexPath, forKey: "index")
        cell.dateLbl.layer.setValue(indexPath, forKey: "index")
        
        
        return cell
    }

}






