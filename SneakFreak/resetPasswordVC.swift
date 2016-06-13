//
//  resetPasswordVC.swift
//  SneakFreak
//
//  Created by Reid on 2/18/16.
//  Copyright © 2016 Shlangit. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController , UIScrollViewDelegate , UITextFieldDelegate {

    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var scrollReset: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alignment
        label.frame = CGRectMake(10, 80, self.view.frame.size.width - 20, 95)
        emailTxt.frame = CGRectMake(10, label.frame.origin.y + 130, self.view.frame.size.width - 20, 40)
        resetBtn.frame = CGRectMake(20, emailTxt.frame.origin.y + 50, self.view.frame.size.width / 3, 40)
        cancelBtn.frame = CGRectMake(self.view.frame.size.width - self.view.frame.size.width / 3 - 20, resetBtn.frame.origin.y, self.view.frame.size.width / 3, 40)
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(resetPasswordVC.hideKeyboard(_:)))
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
        
        self.scrollReset.contentSize.height = resetBtn.frame.origin.y+resetBtn.frame.size.height+keyboard.size.height+20
    }
    
    // func to hide keyboard
    func keyboardWillHide(notification: NSNotification) {
        
        normalScroll()
    }
    
    func normalScroll ()
    {
        self.scrollReset.contentSize.height = resetBtn.frame.origin.y+resetBtn.frame.size.height+20
    }
    
    // clicked reset button
    @IBAction func resetBtn_click(sender: AnyObject) {
        
        //hide keyboard
        self.view.endEditing(true)
        
        if emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "Whoops", message: "Email is empty", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        PFUser.requestPasswordResetForEmailInBackground(emailTxt.text!) { (success:Bool, error:NSError?) -> Void in
            if success {
                
                // show alert action
                let alert = UIAlertController(title: "Got it", message: "Email has been sent to reset", preferredStyle: UIAlertControllerStyle.Alert)
                
                // if pressed ok call self.dismiss function
                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                alert.addAction(ok)
                self.presentViewController(alert, animated: true, completion: nil)
            } else{
                print(error?.localizedDescription)
            }
        }
        
    }

    // clicked cancel button
    @IBAction func cancelBtn_click(sender: AnyObject) {
        
        // hide keyboard when pressed cancel
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    

}
