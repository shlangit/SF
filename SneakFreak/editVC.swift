//
//  editVC.swift
//  SneakFreak
//
//  Created by Reid on 2/23/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class editVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate , UIScrollViewDelegate , UITextFieldDelegate {
          
          // UI Objects
          @IBOutlet weak var scrollEdit: UIScrollView!
          
          @IBOutlet weak var avaImg: UIImageView!
          @IBOutlet weak var fullnameTxt: UITextField!
          @IBOutlet weak var usernameTxt: UITextField!
          @IBOutlet weak var cityTxt: UITextField!
          
          @IBOutlet weak var shoeSizeTxt: UITextField!
          @IBOutlet weak var sizeInfo: UILabel!
          
          @IBOutlet weak var titleLbl: UILabel!
          @IBOutlet weak var emailTxt: UITextField!
          @IBOutlet weak var telephoneTxt: UITextField!
          @IBOutlet weak var genderTxt: UITextField!
          
          
          
          // picker view and picker data
          var genderPicker : UIPickerView!
          let genders = ["Male","Female"]
          
          var cityPicker : UIPickerView!
          //    let cities = ["Albuquerque, NM","Anaheim, CA","Anchorage, AK","Arlington, TX","Atlanta, GA","Aurora, CO","Austin, TX","Bakersfield, CA","Baltimore, MD","Baton Rouge, LA","Boise, ID","Boston, MA","Boston, WA","Buffalo, NY","Chandler, AZ","Charlotte, NC","Chesapeake, VA","Chicago, IL","Chula Vista, CA","Cincinnati, OH","Cleveland, OH","Colorado Springs, CO","Columbus, OH","Corpus Christi, TX","Dallas, TX","Denver, CO","Detroit, MI","Durham, NC","El Paso, TX","Fort Wayne, IN","Fort Worth, TX","Fremont, CA","Fresno, CA","Garland, TX","Gilbert, AZ","Glendale, AZ","Greensboro, NC","Henderson, NV","Hialeah, FL","Honolulu, HI","Houston, TX","Indianapolis, IN","Irvine, CA","Irving, TX","Jacksonville, FL","Jersey City, NJ","Kansas City, MO","Laredo, TX","Las Vagas, NV","Lexington, KY","Lincoln, NE","Long Beach, CA","Los Angeles, CA","Louisville, KY","Lubbock, TX","Madison, WI","Memphis, TN","Mesa, AZ","Miami, FL","Milwaukee, WI","Nashville, TN","New York, NY","Newark, NJ","Norfolk, VA","North Las Vegas, NV","Oakland, CA","Oklahoma, OK","Omaha, KS","Omaha, LA","Omaha, MN","Omaha, NE","Orlando, FL","Philadelphia, PA","Phoenix, AZ","Pittsburgh, PA","Plano, TX","Portland, OR","Raleigh, NC","Reno, NV","Riverside, CA","Sacramento, CA","Saint Paul, MN","San Antonio, TX","San Bernardino, CA","San Diego, CA","San Francisco, CA","San Jose, CA","Santa Ana, CA","Scottsdale, AZ","St. Louis, MO","St. Petersburg, FL","Stockton, CA","Tampa, FL","Toledo, OH","Tucson, AZ","Tulsa, OK","Virginia Beach, VA","Washington, DC","Winston–Salem, NC"]
          // value to hold keyboard frame size value
          var keyboard = CGRect()
          
          // default func to load when app opens
          override func viewDidLoad() {
                    super.viewDidLoad()
                    
                    normalScroll()
                    
                    // call picker
                    genderPicker = UIPickerView()
                    genderPicker.dataSource = self
                    genderPicker.delegate = self
                    genderPicker.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    genderPicker.showsSelectionIndicator = true
                    genderTxt.inputView = genderPicker
                    
                    //        cityPicker = UIPickerView()
                    //        cityPicker.dataSource = self
                    //        cityPicker.delegate = self
                    //        cityPicker.backgroundColor = UIColor.groupTableViewBackgroundColor()
                    //        cityPicker.showsSelectionIndicator = true
                    //        cityTxt.inputView = cityPicker
                    
                    // check if keyboard showing
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
                    
                    let hideTap = UITapGestureRecognizer(target: self, action: #selector(editVC.hideKeyboard))
                    hideTap.numberOfTapsRequired = 1
                    self.view.userInteractionEnabled = true
                    self.view.addGestureRecognizer(hideTap)
                    
                    // pic choose
                    let avaTap = UITapGestureRecognizer(target: self, action: #selector(editVC.loadImg(_:)))
                    avaTap.numberOfTapsRequired = 1
                    avaImg.userInteractionEnabled = true
                    avaImg.addGestureRecognizer(avaTap)
                    
                    // call alignment function
                    alignment()
                    
                    // call information function
                    information()
          }
          
          // keyboard
          func hideKeyboard(){
                    self.view.endEditing(true)
          }
          
          // func when keyboard is showing
          func keyboardWillShow(notification: NSNotification ) {
                    
                    // define keyboard frame size
                    keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
                    
                    self.scrollEdit.contentSize.height = self.genderTxt.frame.origin.y+self.genderTxt.frame.size.height+self.keyboard.height+80
          }
          
          // func to hide keyboard
          func keyboardWillHide(notification: NSNotification) {
                    
                   normalScroll()
          }
          
          func normalScroll ()
          {
                    self.scrollEdit.contentSize.height = self.genderTxt.frame.origin.y+self.genderTxt.frame.size.height+100
          }
          
          // func to call UIImage Picker
          func loadImg( recognizer : UITapGestureRecognizer) {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .PhotoLibrary
                    picker.allowsEditing = true
                    presentViewController(picker, animated: true, completion: nil)
          }
          
          // method to finalze action with UIImagePickerController
          func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
                    avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
                    self.dismissViewControllerAnimated(true, completion: nil)
          }
          
          // alignment function
          func alignment(){
                    let paddingView = UIView(frame:CGRectMake(15,15,15,15))
                    let width = self.view.frame.size.width
                    let height = self.view.frame.size.height
                    
                    scrollEdit.frame = CGRectMake(0, 0, width, height)
                    
                    avaImg.frame = CGRectMake(width / 2.5, 15, 75, 75)
                    avaImg.layer.cornerRadius = avaImg.frame.size.width / 9
                    avaImg.clipsToBounds = true
                    
                    fullnameTxt.frame = CGRectMake(10, avaImg.frame.origin.y + avaImg.frame.origin.x - 30, width - 20, 35)
                    usernameTxt.frame = CGRectMake(10, fullnameTxt.frame.origin.y + 45, width - 20, 35)
                    cityTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 45, width - 20, 35)
                    shoeSizeTxt.frame = CGRectMake(10, cityTxt.frame.origin.y + 45, width - 20, 35)
                    sizeInfo.frame = CGRectMake(15, shoeSizeTxt.frame.origin.y + 40, width - 25, 35)
                    
                    titleLbl.frame = CGRectMake(0, sizeInfo.frame.origin.y + 50, width, 40)
                    
                    emailTxt.frame = CGRectMake(10, sizeInfo.frame.origin.y + 105, width - 20, 35)
                    telephoneTxt.frame = CGRectMake(10, emailTxt.frame.origin.y + 45, width - 20, 35)
                    genderTxt.frame = CGRectMake(10, telephoneTxt.frame.origin.y + 45, width - 20, 35)
                    
                    fullnameTxt.layer.borderWidth = 1
                    fullnameTxt.leftView = paddingView
                    // fullnameTxt.leftViewMode = UITextFieldViewMode.Always
                    fullnameTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
                    
                    usernameTxt.layer.borderWidth = 1
                    usernameTxt.leftView = paddingView
                    usernameTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
                    
                    cityTxt.layer.borderWidth = 1
                    cityTxt.leftView = paddingView
                    cityTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
                    
                    shoeSizeTxt.layer.borderWidth = 1
                    shoeSizeTxt.leftView = paddingView
                    shoeSizeTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
                    
                    emailTxt.layer.borderWidth = 1
                    emailTxt.leftView = paddingView
                    emailTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
                    
                    telephoneTxt.layer.borderWidth = 1
                    telephoneTxt.leftView = paddingView
                    telephoneTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
                    
                    genderTxt.layer.borderWidth = 1
                    genderTxt.leftViewMode = UITextFieldViewMode.Always
                    genderTxt.layer.borderColor = UIColor(red: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).CGColor
          }
          
          func information() {
                    
                    let ava = PFUser.currentUser()?.objectForKey("ava") as! PFFile
                    ava.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
                              self.avaImg.image = UIImage(data: data!)
                    }
                    
                    usernameTxt.text = PFUser.currentUser()?.username
                    fullnameTxt.text = PFUser.currentUser()?.objectForKey("fullname") as? String
                    cityTxt.text = PFUser.currentUser()?.objectForKey("city") as? String
                    shoeSizeTxt.text = PFUser.currentUser()?.objectForKey("shoesize") as? String
                    emailTxt.text = PFUser.currentUser()?.email
                    telephoneTxt.text = PFUser.currentUser()?.objectForKey("telephone") as? String
                    genderTxt.text = PFUser.currentUser()?.objectForKey("gender") as? String
                    
          }
          // restrictions for email text field
          func validateEmail(email : String) -> Bool {
                    let regex = "[A-Z0-9a-z._%+-]{4}@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
                    let range = email.rangeOfString(regex, options: .RegularExpressionSearch)
                    let result = range != nil ? true : false
                    return result
          }
          
          func validateShoe(shoesize: String) -> Bool {
                    let regex = "[0-9]"
                    let range = shoesize.rangeOfString(regex, options: .RegularExpressionSearch)
                    let result = range != nil ? true : false
                    return result
          }
          
          func validateCity(city: String) -> Bool {
                    let regex = "[A-Za-z]+\\, [A-Za-z]"
                    let range = city.rangeOfString(regex, options: .RegularExpressionSearch)
                    let result = range != nil ? true : false
                    return result
          }
          
          func alert (error: String, message : String){
                    let alert = UIAlertController(title: error, message: message, preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "Got It", style: .Cancel, handler: nil)
                    alert.addAction(ok)
                    self.presentViewController(alert, animated: true, completion: nil)
          }
          
          // clicked save button
          @IBAction func save_clicked(sender: AnyObject) {
                    
                    // checking field data for correct formatting
                    if !validateEmail (emailTxt.text!) {
                              alert("Incorrect Email", message: "Please provide a correct email address")
                              return
                    }
                    
                    if !validateShoe(shoeSizeTxt.text!) {
                              alert("Incorrect Shoe Size", message: "Please provide a shoe size as a number")
                              return
                    }
                    
                    if !validateCity(cityTxt.text!) {
                              alert("Incorrect City", message: "Please update your city as City, State. (ex: Chicago, IL)")
                              return
                    }
                    
                    // save user info
                    let user = PFUser.currentUser()!
                    user.username = usernameTxt.text?.lowercaseString
                    user.email = emailTxt.text?.lowercaseString
                    user["fullname"] = fullnameTxt.text?.lowercaseString
                    user["city"] = cityTxt.text
                    user["shoesize"] = shoeSizeTxt.text
                    
                    // if telephone text is empty, else send data
                    if telephoneTxt.text!.isEmpty {
                              user["tel"] = ""
                    } else {
                              user["tel"] = telephoneTxt.text
                    }
                    
                    // if gender text is empty, otherwise send data
                    if genderTxt.text!.isEmpty {
                              user["gender"] = ""
                    } else {
                              user["gender"] = genderTxt.text
                    }
                    
                    let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
                    let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                    user["ava"] = avaFile
                    
                    // send data to server
                    user.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                              if success {
                                        // hide keyboard
                                        self.view.endEditing(true)
                                        
                                        self.updateProfileOnNews(avaFile!)
                                        self.updateProfileOnPosts(avaFile!)
                                        self.updateProfileOnComments(avaFile!)
                                        
                                        
                                        // send notification to homeVC to be reloaded
                                        NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
                              } else {
                                        print(error!.localizedDescription)
                              }
                    }
          }
          
          func updateProfileOnPosts (avaFile : PFFile)
          {
                    
                    let followQuery = PFQuery(className: "posts")
                    followQuery.whereKey("username", equalTo: PFUser.currentUser()!.username!)
                    
                    followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                              if error == nil {
                                        
                                        
                                        // find related objects
                                        for object in objects!
                                        {
                                                  object.setObject(avaFile, forKey: "ava")
                                                  
                                                
                                        }
                                        
                                        
                                        PFObject.saveAllInBackground(objects)
                                        
                              }
                              else
                              {
                              
                              }
                    })
          }
          
          func updateProfileOnComments (avaFile : PFFile)
          {
                    
                    let followQuery = PFQuery(className: "comments")
                    followQuery.whereKey("username", equalTo: PFUser.currentUser()!.username!)
                    
                    followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                              if error == nil {
                                        
                                        
                                        // find related objects
                                        for object in objects!
                                        {
                                                  object.setObject(avaFile, forKey: "ava")
                                                  
                                        }
                                        
                                        
                                        PFObject.saveAllInBackground(objects)
                                        
                              }
                              else
                              {
                                        
                              }
                              
                              //dissmiss editVC
                              self.dismissViewControllerAnimated(true, completion: nil)
                    })
          }
          
          func updateProfileOnNews (avaFile : PFFile)
          {
                    
                    let followQuery = PFQuery(className: "news")
                    followQuery.whereKey("by", equalTo: PFUser.currentUser()!.username!)
                    
                    followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                              if error == nil {
                                        
                                        
                                        // find related objects
                                        for object in objects!
                                        {
                                                  object.setObject(avaFile, forKey: "ava")
                                                  
                                        }
                                        
                                        
                                        PFObject.saveAllInBackground(objects)
                                        
                              }
                              else
                              {
                                        
                              }
                    })
          }

          
          // clicked cancel button
          @IBAction func cancel_clicked(sender: AnyObject) {
                    self.view.endEditing(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
          }
          
          // picker view methods
          // picker component number
          func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
                    return 1
          }
          
          // picker text number of items to select
          func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                    return genders.count
          }
          
          // picker text config
          func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                    return genders[row]
          }
          
          // picker selected
          func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                    genderTxt.text = genders[row]
                    self.view.endEditing(true)
          }
          
          func textFieldDidBeginEditing(textField: UITextField) {
                    
          }
          
          func textFieldShouldReturn(textField: UITextField) -> Bool {
                    
                    if textField.tag == 7
                    {
                              textField.resignFirstResponder()
                    }
                    else
                    {
                              let nextTextField = scrollEdit.viewWithTag(textField.tag+1) as! UITextField
                              nextTextField.becomeFirstResponder()
                    }
                    
                    return true
          }
          
}
