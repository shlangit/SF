//
//  uploadVC.swift
//  Instragram
//
//  Created by Reid on 2/18/16.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse


class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable publish btn
        publishBtn.enabled = false
        publishBtn.backgroundColor = .lightGrayColor()

        self.navigationItem.title = "New Post".uppercaseString
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.titleTextAttributes? = [NSFontAttributeName: UIFont(name: "AlternateGothicEF-NoTwo", size: 22)!]

        let navbarFont = UIFont(name: "AlternateGothicEF-NoTwo", size: 22) ?? UIFont.systemFontOfSize(22)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont, NSForegroundColorAttributeName:UIColor.blackColor()]
        
        
        // hide remove button
        removeBtn.hidden = true
        
        // standart UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        // hide kyeboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
    
    }
    
    // preload func
    override func viewWillAppear(animated: Bool) {
        // call alignment function
        alignment()
    }
    
    
    // hide kyeboard function
    func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    
    // func to cal pickerViewController
    func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    // hold selected image in picImg object and dissmiss PickerController()
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // enable publish btn
        publishBtn.enabled = true
        publishBtn.backgroundColor = UIColor.blackColor()
        
        // unhide remove button
        removeBtn.hidden = false
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.userInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    
    // zooming in / out function
    func zoomImg() {
        
        // define frame of zoomed image
        let zoomed = CGRectMake(0, self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, self.view.frame.size.width, self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomed = CGRectMake(15, 15, self.view.frame.size.width / 4.5, self.view.frame.size.width / 4.5)
        
        // if picture is unzoomed, zoom it
        if picImg.frame == unzoomed {
            
            // with animation
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .blackColor()
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
            
            // to unzoom
        } else {
            
            // with animation
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = unzoomed
                
                // unhide objects from background
                self.view.backgroundColor = .whiteColor()
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
        
    }
    
    
    // alignment
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRectMake(15, 15, width / 4.5, width / 4.5)
        titleTxt.frame = CGRectMake(picImg.frame.size.width + 25, picImg.frame.origin.y, width / 1.488, picImg.frame.size.height)
        titleTxt.layer.borderWidth = 1
        titleTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
        publishBtn.frame = CGRectMake(0, height / 1.12, width, width / 6.5)
        removeBtn.frame = CGRectMake(picImg.frame.origin.x, picImg.frame.origin.y + picImg.frame.size.height, picImg.frame.size.width, 20)
    }
    
    
    // clicked publish button
    @IBAction func publishBtn_clicked(sender: AnyObject) {
        
        // dissmiss keyboard
        self.view.endEditing(true)
        
        // send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.currentUser()!.username
        object["ava"] = PFUser.currentUser()!.valueForKey("ava") as! PFFile
        
        
        let uuid = NSUUID().UUIDString
        object["uuid"] = "\(PFUser.currentUser()!.username!) \(uuid)"
        
        if titleTxt.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = titleTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        // send pic to server after converting to FILE and comprassion
        let imageData = UIImageJPEGRepresentation(picImg.image!, 0.5)
        let imageFile = PFFile(name: "post.jpg", data: imageData!)
        object["pic"] = imageFile
        
        
        // send #hashtag to server
        let words:[String] = titleTxt.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // define taged word
        for var word in words {
            
            // save #hastag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                word = word.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.currentUser()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.currentUser()?.username
                hashtagObj["hashtag"] = word.lowercaseString
                hashtagObj["comment"] = titleTxt.text
                hashtagObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        
        // finally save information
        object.saveInBackgroundWithBlock ({ (success:Bool, error:NSError?) -> Void in
            if error == nil {
                
                // send notification wiht name "uploaded"
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                
                NSNotificationCenter.defaultCenter().postNotificationName("refreshProfileData", object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.tabBarController!.selectedIndex = 0
                
                // reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
            }
        })
        
    }
    
    
    // clicked remove button
    @IBAction func removeBtn_clicked(sender: AnyObject) {
        self.viewDidLoad()
    }
    
}