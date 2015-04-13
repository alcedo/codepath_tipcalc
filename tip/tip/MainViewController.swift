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
    var plusAmountLabel: UILabel?
    var finalAmountLabel: UILabel?
    var navBarHeight: CGFloat?
    var userSettings = NSUserDefaults()
    
    // TODO: group all of these into a data struct
    var inputAmount = 0.0
    var tipAmount = 0.0
    var finalAmount = 0.0
    var tipPercentage = 10
    
    // TODO: For view controller, override loadView() to create new UIs and setting up of constraint
    // for UIView() override initWithFrame method to add subviews and creation of constraint
    override func loadView() {
        self.view = UIView()
        // TODO: make this work -> self.setupConstraint()
        // TODO: Google for flow controller, and shift all interaction code to that.
        // place all view creation logic here.
        self.makeInputField()
        self.makeTipPercentageSegmentControl()
        self.makeResultsPane()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tip Calculator"
        self.navBarHeight = self.navigationController?.navigationBar.frame.height
        self.navigationController!.navigationBar.translucent = false
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain,
                target: self, action: "goToSettingsViewController")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back",
            style: UIBarButtonItemStyle.Plain, target: nil, action: nil);
        
        // keyboard notifs
        self.hideKeyboardOnTapOutside()
        self.registerForKeyboardNotifications()
        
        self.registerAppActiveNotification()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardDidShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    // viewWillAppear gets called every time the view appears.
    // Todo: consider shifting all of the below stuff to viewDidLoad()
    override func viewWillAppear(animated: Bool) {
        // focus on the text field to make sure the keyboard shows
        self.inputField?.becomeFirstResponder()
        // Calculation stuffs
        self.maybeResetCacheValue()
        self.updateTipAmountControlUI()
        self.updateTipPercentageValue()
        self.updateInputField()
        self.updateValues()
        
        super.viewWillAppear(animated)
    }
    
    func registerAppActiveNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "onApplicationWillResignActive",
                name: UIApplicationWillResignActiveNotification,
                object: nil)
    }
    
    func maybeResetCacheValue() {
        if let date: AnyObject = self.userSettings.objectForKey("last_app_resign_date") {
            let lastDate = date as NSDate
            let now = NSDate()
            let interval = now.timeIntervalSinceDate(lastDate)
            // if elapsed time is more than 10 mins (60 seconds), reset cache
            if (interval > 600) {
                let id = NSBundle.mainBundle().bundleIdentifier
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(id!)
            }
        }
    }
    
    func updateValues() {
        self.tipAmount = Double(self.tipPercentage) * self.inputAmount / 100
        self.plusAmountLabel!.text = self.tipAmount.description
        self.finalAmount = self.tipAmount + self.inputAmount
        self.finalAmountLabel!.text = self.finalAmount.description
    }
    
    // MARK: Event handlers
    func goToSettingsViewController() {
        let settingsViewController = SettingsViewController()
        settingsViewController.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func tipPercentageChanged(segment: UISegmentedControl) {
        if (segment == self.tipAmountControl!) {
            // update cache
            self.userSettings.setInteger(segment.selectedSegmentIndex, forKey: "default_tip_segment_index")
            self.userSettings.synchronize()
            self.updateTipAmountControlUI()
            self.updateTipPercentageValue()
            self.updateValues()
        }
    }
    
    func onApplicationWillResignActive() {
        self.userSettings.setObject(NSDate(), forKey: "last_app_resign_date")
        self.userSettings.synchronize()
    }
    
    func updateInputField() {
        if let inputAmount: AnyObject = self.userSettings.valueForKey("input_amount") {
            let amt = inputAmount as NSString
            self.inputField!.text = amt
            if (amt.length == 0) {
                self.inputAmount = 0
            }else {
                self.inputAmount = ((amt as NSString).substringFromIndex(1) as NSString).doubleValue
            }
        }
    }
    
    func updateTipAmountControlUI() {
        let segmentIdx = self.userSettings.integerForKey("default_tip_segment_index")
        self.tipAmountControl!.selectedSegmentIndex = segmentIdx
    }
    
    func updateTipPercentageValue() {
        let segmentIdx = self.userSettings.integerForKey("default_tip_segment_index")
        let title = self.tipAmountControl!.titleForSegmentAtIndex(segmentIdx)
        let lastElementIdx = countElements(title!) - 1
        let amt = (title! as NSString).substringToIndex(lastElementIdx)
        self.tipPercentage = amt.toInt()!
    }
    
    // MARK: UI elements
    func makeTipPercentageSegmentControl() {
        let tipControl = UISegmentedControl(items: ["10%", "15%", "20%"])
        self.tipAmountControl = tipControl
        self.view.addSubview(tipControl)
        
        tipControl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.inputField!.snp_bottom)
            make.centerX.equalTo(self.view.snp_centerX)
            make.width.equalTo(300)
            return
        }
        
        tipControl.addTarget(self, action: "tipPercentageChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
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
            inputField.font = UIFont(name: "Arial", size: 45)
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

    func makeResultsPane() {
        let view = UIView()
        let plusLabel = UILabel()
        let plusAmountLabel = UILabel()
        let equalsLabel = UILabel()
        let finalAmountLabel = UILabel()
        self.view.addSubview(view)
        
        
        view.backgroundColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
        view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.tipAmountControl!.snp_bottom).offset(10)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.width.greaterThanOrEqualTo(self.view.bounds.width)
            make.bottom.equalTo(self.view.snp_bottom)
            return
        }
        
        
        view.addSubview(plusLabel)
        plusLabel.text = "+"
        plusLabel.textColor = UIColor.whiteColor()
        plusLabel.font = UIFont(name: "Arial", size: 40)
        plusLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp_top)
            return
        }
        
        
        view.addSubview(plusAmountLabel)
        self.plusAmountLabel = plusAmountLabel
        plusAmountLabel.text = self.tipAmount.description
        plusAmountLabel.font = UIFont(name: "Arial", size: 40)
        plusAmountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view.snp_top)
            make.right.equalTo(self.view.snp_right)
            return
        }
        
        view.addSubview(equalsLabel)
        equalsLabel.text = "="
        equalsLabel.font = UIFont(name: "Arial", size: 40)
        equalsLabel.textColor = UIColor.whiteColor()
        equalsLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(plusAmountLabel).offset(60)
            return
        }
        
        view.addSubview(finalAmountLabel)
        self.finalAmountLabel = finalAmountLabel
        finalAmountLabel.font = UIFont(name: "Arial", size: 40)
        finalAmountLabel.text = self.finalAmount.description
        finalAmountLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(plusAmountLabel).offset(60)
            make.right.equalTo(self.view.snp_right)
            return
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
        self.userSettings.setValue(textField.text, forKey: "input_amount")
        self.updateInputField()
        self.updateValues()
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
//        Uncomment these lines to enable keyboard hiding on tap outside inputfield
//        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        self.view.addGestureRecognizer(tapGesture)
    }
    
//    func dismissKeyboard() {
//        self.inputField!.resignFirstResponder()
//    }
    
    
    
}

