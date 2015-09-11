//
//  ViewController.swift
//  Example
//
//  Created by Kristoffer Arlefur on 2015-09-10.
//  Copyright (c) 2015 Kristoffer Arlefur. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blurTypeControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    @IBAction func showInControllerPressed(sender: AnyObject) {
        KANotificationView.showInViewController(self,
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In aliquam nunc at nunc pulvinar gravida. Integer vestibulum hendrerit leo eget cursus",
            blurEffectStyle: UIBlurEffectStyle(rawValue: blurTypeControl.selectedSegmentIndex)!,
            type: KANotificationView.NotificationViewType.Information) {
                (completed) -> Void in
                
                println("This is a callback")
        }
    }
}

