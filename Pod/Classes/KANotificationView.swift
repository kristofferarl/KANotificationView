//
//  NotificationView.swift
//
//  Created by Kristoffer Arlefur on 2015-08-27.
//  Copyright (c) 2015 Arlefur Mobile. All rights reserved.
//

import UIKit

public class KANotificationView: UIView {

    let duration:NSTimeInterval = 3.0
    let animationDuration:NSTimeInterval = 0.8

    public enum NotificationViewPosition: Int {
        case Top
        case Bottom
    }

    public enum NotificationViewType: Int {
        case Information
    }

    let blurEffect:UIBlurEffect
    let title:String
    let position:NotificationViewPosition

    var positionConstraint:NSLayoutConstraint!

    init(blurEffectStyle: UIBlurEffectStyle, type: NotificationViewType, title: String, position:NotificationViewPosition) {

        self.blurEffect = UIBlurEffect(style: blurEffectStyle)
        self.title = title
        self.position = position

        super.init(frame: CGRectZero)

        setup()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public class func showInViewController(controller: UIViewController, title:String, blurEffectStyle: UIBlurEffectStyle, type: NotificationViewType, callback:((completed:Bool) -> Void)?) {

        let notificationView = KANotificationView(
            blurEffectStyle: blurEffectStyle,
            type: type,
            title: title,
            position: .Top
        )

        if let navigationController = controller.navigationController {

            controller.view.insertSubview(notificationView, belowSubview: navigationController.navigationBar)

            let leftConstraint = NSLayoutConstraint(
                item: notificationView,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: navigationController.navigationBar,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1,
                constant: 0)
            let rightConstraint = NSLayoutConstraint(
                item: notificationView,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: navigationController.navigationBar,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1,
                constant: 0)

            notificationView.positionConstraint = NSLayoutConstraint(
                item: notificationView,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: navigationController.navigationBar,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1,
                constant: 0)

            NSLayoutConstraint.activateConstraints([
                notificationView.positionConstraint,
                leftConstraint,
                rightConstraint
                ])

            notificationView.showViewWithDuration(notificationView.duration) {
                (completed:Bool) in

                if let callback = callback {
                    callback(completed: completed)
                }
            }
        }
        else {

            println("No valid navigationController was found in viewController!")
        }
    }

    public class func showInView(view:UIView, title:String, blurStyle:UIBlurEffectStyle, type: NotificationViewType, position:NotificationViewPosition, callback:(() -> Void)?) {

        let notificationView = KANotificationView(
            blurEffectStyle: blurStyle,
            type: type,
            title: title,
            position: position
        )

        view.addSubview(notificationView)

        let leftConstraint = NSLayoutConstraint(
            item: notificationView,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1,
            constant: 0)
        let rightConstraint = NSLayoutConstraint(
            item: notificationView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: 0)

        notificationView.positionConstraint = NSLayoutConstraint(
            item: notificationView,
            attribute: position == NotificationViewPosition.Top ? NSLayoutAttribute.Bottom : NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: position == NotificationViewPosition.Top ? NSLayoutAttribute.Top : NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)

        NSLayoutConstraint.activateConstraints([
            notificationView.positionConstraint,
            leftConstraint,
            rightConstraint
            ])

        notificationView.showViewWithDuration(notificationView.duration) {
            (completed:Bool) in

            if completed {

                if let callback = callback {
                    callback()
                }
            }
        }
    }

    private func showViewWithDuration(duration:NSTimeInterval, callback:((completed:Bool ) -> Void)?) {

        layoutIfNeeded()

        let offset:CGFloat

        switch position {
        case .Top:
            offset = frame.size.height - 90
        case .Bottom:
            offset = -frame.size.height
        }

        positionConstraint.constant = offset

        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in

            self.layoutIfNeeded()

            }) {
                (completed) -> Void in

                self.hideViewWithDelay(duration, callback: callback)
        }
    }

    private func hideViewWithDelay(delay:NSTimeInterval, callback:((completed:Bool ) -> Void)?) {

        layoutIfNeeded()

        positionConstraint.constant = 0

        UIView.animateWithDuration(animationDuration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in

            self.layoutIfNeeded()

            }) { (completed:Bool) -> Void in

                self.removeFromSuperview()

                if let callback = callback {
                    callback(completed: completed)
                }
        }
    }
    
    private func setup() {
        
        setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let blurView = NotificationBlurView(blurEffect: self.blurEffect, title: self.title)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        addSubview(blurView)
        
        let views = [
            "BlurView": blurView
        ]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[BlurView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[BlurView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(horizontalConstraints)
        NSLayoutConstraint.activateConstraints(verticalConstraints)
    }

    private class NotificationBlurView: UIVisualEffectView {

        var icon:UIImage?

        let titleLabel:UILabel

        init(blurEffect:UIBlurEffect, title:String) {

            titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            titleLabel.font = UIFont.systemFontOfSize(16)
            titleLabel.numberOfLines = 0

            super.init(effect: blurEffect)

            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyView.setTranslatesAutoresizingMaskIntoConstraints(false)

            contentView.addSubview(vibrancyView)

            vibrancyView.contentView.addSubview(titleLabel)

            let views = [
                "VibrancyView": vibrancyView,
                "Label": titleLabel
            ]

            let labelHorizontalConstrains = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[Label]-10-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
            let labelVerticalConstrains = NSLayoutConstraint.constraintsWithVisualFormat("V:|-100-[Label]-10-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
            let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[VibrancyView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views)
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[VibrancyView]|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: views)

            NSLayoutConstraint.activateConstraints(horizontalConstraints)
            NSLayoutConstraint.activateConstraints(verticalConstraints)

            NSLayoutConstraint.activateConstraints(labelHorizontalConstrains)
            NSLayoutConstraint.activateConstraints(labelVerticalConstrains)
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
