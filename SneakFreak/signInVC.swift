//
//  signInVC.swift
//  SneakFreak
//
//  Created by Reid on 2/18/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class signInVC: UIViewController, UITextFieldDelegate , UIScrollViewDelegate {

    // textfield
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelTwo: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var scrollSignIn: UIScrollView!
    // buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        label.frame = CGRectMake(5, 100, self.view.frame.size.width - 10, 95)
        labelTwo.frame = CGRectMake(10, label.frame.origin.y + 68, self.view.frame.size.width - 10, 58)
        usernameTxt.frame = CGRectMake(10, labelTwo.frame.origin.y + 90, self.view.frame.size.width - 20, 35)
        passwordTxt.frame = CGRectMake(10, usernameTxt.frame.origin.y + 50, self.view.frame.size.width - 20, 35)
        forgotBtn.frame = CGRectMake(10, passwordTxt.frame.origin.y + 45, self.view.frame.size.width - 20, 30)
        signInBtn.frame = CGRectMake(20, forgotBtn.frame.origin.y + 60, self.view.frame.size.width / 3, 35)
        signUpBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 3 - 20, signInBtn.frame.origin.y, self.view.frame.size.width / 3, 35)
      //  signInBtn.layer.cornerRadius = signInBtn.frame.size.width / 20
      //  signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(signInVC.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // check if keyboard showing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signInVC.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(signInVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        normalScroll()
        
    }
    
    // hide keyboard func
    func hideKeyboard(recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // func when keyboard is showing
    func keyboardWillShow(notification: NSNotification ) {
        
        // define keyboard frame size
       let  keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        self.scrollSignIn.contentSize.height = signInBtn.frame.origin.y+signInBtn.frame.size.height+keyboard.size.height+20
    }
    
    // func to hide keyboard
    func keyboardWillHide(notification: NSNotification) {
        
        normalScroll()
    }
    
    func normalScroll ()
    {
        self.scrollSignIn.contentSize.height = signInBtn.frame.origin.y+signInBtn.frame.size.height+20
    }
    
    // sign in button clicked
    @IBAction func signInBtn_click(sender: AnyObject) {
        print("sign in clicked")
        
        // hide keyboard
        self.view.endEditing(true)
        
        // if fields are empty
        if (usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty) {
            
            // show alert message
            let alert = UIAlertController(title: "Whoops", message: "Please fill out both fields", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // login function
        PFUser.logInWithUsernameInBackground(usernameTxt.text!, password: passwordTxt.text!) { (user:PFUser?, error:NSError?) -> Void in
            if error == nil {
                NSUserDefaults.standardUserDefaults().setObject(user!.username, forKey: "username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.login()
            } else {
                // show alert message
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag == 2
        {
            textField.resignFirstResponder()
        }
        else
        {
            let nextTextField = scrollSignIn.viewWithTag(textField.tag+1) as! UITextField
            nextTextField.becomeFirstResponder()
        }
        
        return true
    }
    

}
