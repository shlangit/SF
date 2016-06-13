//
//  signUpVC.swift
//  SneakFreak
//
//  Created by Reid on 2/18/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class signUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate , UIScrollViewDelegate {

    // profile image
    @IBOutlet weak var avaImg: UIImageView!

    
    // text fields
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var shoeSizeTxt: UITextField!
    @IBOutlet weak var sizeInfo: UILabel!
    @IBOutlet weak var cityTxt: UITextField!
    
    //buttons
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    // scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    // keyboard frame size
    var keyboard = CGRect()
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // check notification if keyboard is shown or not
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signUpVC.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signUpVC.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // declare hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // round corners on image
//         avaImg.layer.cornerRadius = avaImg.frame.size.width / 2
//         avaImg.clipsToBounds = true
        
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        avaImg.userInteractionEnabled = true
        avaImg.addGestureRecognizer(avaTap)
        
        // alignment
        avaImg.frame = CGRectMake(self.view.frame.size.width / 2 - 45, 50, 90, 90)
        usernameTxt.frame = CGRectMake(10, avaImg.frame.origin.y + 115, self.view.frame.size.width - 20, 35)
        emailTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 35)
        passwordTxt.frame = CGRectMake(10, emailTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 35)
        repeatPassword.frame = CGRectMake(10, passwordTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 35)
        fullnameTxt.frame = CGRectMake(10, repeatPassword.frame.origin.y + 70, self.view.frame.size.width - 20, 35)
        cityTxt.frame = CGRectMake(10, fullnameTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 35)
        shoeSizeTxt.frame = CGRectMake(10, cityTxt.frame.origin.y + 40, self.view.frame.size.width - 20, 35)
        sizeInfo.frame = CGRectMake(15, shoeSizeTxt.frame.origin.y + 40, self.view.frame.size.width - 25, 35)
        signUpBtn.frame = CGRectMake(20, sizeInfo.frame.origin.y + 60, self.view.frame.size.width / 3, 35)
        cancelBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 3 - 20, signUpBtn.frame.origin.y, self.view.frame.size.width / 3, 35)
        
        // cancelBtn.layer.cornerRadius = cancelBtn.frame.size.width / 20
        // signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        normalScroll()
        
    }
    
    // call picker to select image
    func loadImg(recognizer:UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // connect image to our image view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // hide keyboard if tapped
    func hideKeyboardTap(recognizer:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // show keyboard func
    func showKeyboard(notification:NSNotification) {
        
        // define keyboard size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        self.scrollView.contentSize.height = self.signUpBtn.frame.size.height+self.signUpBtn.frame.origin.y+self.keyboard.size.height+20
    }

    // hide keyboard func
    func hideKeyboard(notification:NSNotification) {
        
        self.normalScroll()
    }
    
    func normalScroll ()
    {
        self.scrollView.contentSize.height = self.signUpBtn.frame.size.height+self.signUpBtn.frame.origin.y+20
    }
    
    // clicked sign up
    @IBAction func signUpBtn_click(sender: AnyObject) {
        print("sign up pressed")
        
        //dismiss keyboard
        self.view.endEditing(true)
        
        // if fields are empty alert message appears
        if (usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPassword.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty || shoeSizeTxt.text!.isEmpty || cityTxt.text!.isEmpty) {
            
            let alert = UIAlertController(title: "Whoops!", message: "Please fill out all of the fields", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // if passwords do not match
        if (passwordTxt.text != repeatPassword.text) {
            let alert = UIAlertController(title: "Oh No!", message: "Your passwords do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // send data to parse
        let user = PFUser()
        user.username = usernameTxt.text?.lowercaseString
        user.email = emailTxt.text?.lowercaseString
        user.password = passwordTxt.text
        user["fullname"] = fullnameTxt.text?.lowercaseString
        user["shoesize"] = shoeSizeTxt.text
        user["city"] = cityTxt.text
        user["verified"] = false
        
        // assigned in edit profile
        user["tel"] = ""
        user["gender"] = ""
        
        //convert image for sending to server
        let avaData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        let avaFile = PFFile(name: "ava.jpg", data: avaData!)
        user["ava"] = avaFile
        
        // save data in server
        user.signUpInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success{
               print("Registered")
                
                self.byDefaultFollowSneakteam(user.username!)
                
                //remember logged user  
                NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // call login function from AppDelegate.swift class - means open app to main
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                // show alert message
                let alert = UIAlertController(title: "Whoops", message: "Username or Email may already be taken, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // clicked cancel
    @IBAction func cancelBtn_click(sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
            let nextTextField = scrollView.viewWithTag(textField.tag+1) as! UITextField
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func byDefaultFollowSneakteam(username : String)
    {
        let object = PFObject(className: "follow")
        object["follower"] = username
        object["following"] = "sneakteam"
        object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
            if success{

            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
}
