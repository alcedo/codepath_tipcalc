//
//  ViewController.swift
//  tip
//
//  Created by Victor Liew on 4/8/15.
//  Copyright (c) 2015 Victor Liew. All rights reserved.
//

import UIKit
import Snap

class MainViewController: UIViewController, UITextFieldDelegate {
    
    // list of UI elements
    var inputField: UITextField?
    var tipAmountControl: UISegmentedControl?
    var navBarHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tip Calculator"
        self.navBarHeight = self.navigationController?.navigationBar.frame.height
        self.navigationController!.navigationBar.translucent = false
        self.makeInputField()
        self.makeTipPercentageSegmentControl()
        self.hideKeyboardOnTapOutside()
        self.registerForKeyboardNotifications()
    }
    
    // viewWillAppear gets called every time the view appears.
    override func viewWillAppear(animated: Bool) {
        self.inputField?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardDidShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillHideNotification,
            object: nil)
    }

    // MARK: UI elements
    func makeTipPercentageSegmentControl() {
        let tipControl = UISegmentedControl(items: ["10%", "15%", "20%"])
        self.tipAmountControl = tipControl
        self.view.addSubview(tipControl)
        
        tipControl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.inputField!.snp_bottom)
            make.centerX.equalTo(self.view.snp_centerX)
            return
        }
    }
    
    func makeInputField() {
        
        // http://mycodetips.com/ios/create-uitextfield-programmatically-ios-856.html
        self.inputField = UITextField()
        if let inputField = self.inputField {
            self.view.addSubview(inputField)
            inputField.tag = 0  // used to identify our input field when its used in an delegate
            inputField.delegate = self
            inputField.keyboardType = UIKeyboardType.DecimalPad
            inputField.textAlignment = NSTextAlignment.Right
            inputField.font = UIFont(name: "Arial", size: 30)
            inputField.snp_makeConstraints{ (make) -> Void in
                make.width.greaterThanOrEqualTo(self.view.bounds.width)
                make.height.equalTo(100)
                
                // anchor inputfield to something
                make.top.equalTo(self.view.snp_top)
                make.left.equalTo(self.view.snp_left)
                make.right.equalTo(self.view.snp_right)
                
                return
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // shouldChangeCharactersInRange gets called BEFORE text field actually changes its text.
    // use stringByReplacingCharactersInRange to get the latest update
    // Another way is to use notifications: 
    // http://stackoverflow.com/questions/388237/getting-the-value-of-a-uitextfield-as-keystrokes-are-entered
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currencySign = "$"

        // The NSString implementation of stringByReplacingCharactersInRange accepts an old-style NSRange,
        // so we convert STring to NSString first.
        // see: http://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index
        
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if (first(newString) != "$") {
            newString = "$" + newString
            
        }else if (first(newString) == "$" && countElements(newString) == 1) {
            // remove "$" sign if its the only char remaining
            newString = ""
        }
        textField.text = newString
        // Prevent changes. we would update the textfield manually
        return false
    }
    
    // MARK: Keyboard related items
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWasShown:",
            name: UIKeyboardDidShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }

    
    func keyboardWasShown(notification: NSNotification) {
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
    }
    
    func hideKeyboardOnTapOutside() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard() {
        self.inputField!.resignFirstResponder()
    }
    
    
    
}

