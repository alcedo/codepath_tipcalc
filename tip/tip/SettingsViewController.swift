//
//  SettingsViewController.swift
//  tip
//
//  Created by Victor Liew on 4/12/15.
//  Copyright (c) 2015 Victor Liew. All rights reserved.
//

import UIKit
import Snap

class SettingsViewController: UIViewController {
    var userSettings = NSUserDefaults()
    var tipAmountControl: UISegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Set Default Tip Percentage"
        
        // Initialize the view with the current default tip percentage
        var defaultTipSegmentIdx = self.userSettings.integerForKey("default_tip_segment_index")
        self.tipAmountControl = UISegmentedControl(items: ["10%", "15%", "20%"])
        if let tipControl = self.tipAmountControl {
            self.view.addSubview(tipControl)
            tipControl.selectedSegmentIndex = defaultTipSegmentIdx
            tipControl.addTarget(self, action: "tipPercentageChanged:",
                forControlEvents: UIControlEvents.ValueChanged)
            
            tipControl.snp_makeConstraints{ (make) -> Void in
                make.top.equalTo(self.view.snp_top).with.offset(10)
                return
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tipPercentageChanged(segment: UISegmentedControl) {
        if let segment = self.tipAmountControl {
            self.updateDefaultTip()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.updateDefaultTip()
        super.viewWillDisappear(animated)
    }
    
    func updateDefaultTip() {
        self.userSettings.setInteger(self.tipAmountControl!.selectedSegmentIndex,
            forKey: "default_tip_segment_index")
        self.userSettings.synchronize()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
