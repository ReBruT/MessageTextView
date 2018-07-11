//
//  MessageTextView.swift
//
//  Created by Abashin Roman on 28/06/2018.
//  Copyright © 2018 Abashin Roman. All rights reserved.
//

import UIKit

final class MessageTextViewSettings {
    static let shared = MessageTextViewSettings()
    private init() { /* lock from manual init */ }
    
    var maxFieldWidth:CGFloat = CGFloat.greatestFiniteMagnitude
    var timeFont:UIFont = UIFont.systemFont(ofSize: 12)
    var timeColor:UIColor = UIColor.black
}

class MessageTextView: UITextView {
    var timeImageView:UIImageView = UIImageView(frame: CGRect.zero)
    var timeText:String? {
        didSet {
            updateTimeImage()
            if timeImageView.superview == nil {
                self.addSubview(timeImageView)
            }
        }
    }
    var row:Int = -1
    
    override var text: String! {
        didSet {
            self.setNeedsLayout()
        }
    }
    override var attributedText: NSAttributedString! {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.width < 100000 { //initial == 1073741824
            print("intrinsicContentSize", row, size)
            processTimePosition(initialSize: &size)
        }
        return size
    }
    
    private func processTimePosition(initialSize size:inout CGSize) {
        var endCaretRect = self.caretRect(for: self.endOfDocument)
        if endCaretRect.origin.y < 0 {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            endCaretRect = self.caretRect(for: self.endOfDocument)
        }
        
        var newTimeImageOrigin = CGPoint.zero
        if endCaretRect.origin.y < 0 {
            // use "has space to time"
            print(row, "update err")
            newTimeImageOrigin = CGPoint(x: size.width - timeImageView.frame.width, y: size.height - timeImageView.frame.height - 5)
        } else {
            switch true {
            case endCaretRect.maxY < 30: //single line
                if endCaretRect.maxX + timeImageView.frame.width < MessageTextViewSettings.shared.maxFieldWidth &&
                    size.width + timeImageView.frame.width < MessageTextViewSettings.shared.maxFieldWidth {
                    print(row, "update 11")
                    size.width += timeImageView.frame.width
                    newTimeImageOrigin = CGPoint(x: size.width - timeImageView.frame.width,
                                                 y: endCaretRect.midY - timeImageView.frame.height/2)
                } else { //+1 line
                    print(row, "update 12")
                    size.height += 7
                    newTimeImageOrigin = CGPoint(x: size.width - timeImageView.frame.width,
                                                 y: size.height - timeImageView.frame.height - 3)
                }
            case endCaretRect.maxY > size.height: //bad carret rect on next line
                print(row, "update 13")
                size.height += 7
                newTimeImageOrigin = CGPoint(x: size.width - timeImageView.frame.width,
                                             y: size.height - timeImageView.frame.height - 3)
                break
            default: //multiline
                if endCaretRect.maxX + timeImageView.frame.width < size.width {
                    //has space to time
                    print(row, "update 21")
                    newTimeImageOrigin = CGPoint(x: size.width - timeImageView.frame.width,
                                                 y: size.height - timeImageView.frame.height - 5)
                } else { //no space to time
                    print(row, "update 22")
                    size.height += 7
                    newTimeImageOrigin = CGPoint(x: size.width - timeImageView.frame.width,
                                                 y: size.height - timeImageView.frame.height - 3)
                }
            }
        }
        newTimeImageOrigin.x = newTimeImageOrigin.x.nextUp
        newTimeImageOrigin.y = newTimeImageOrigin.y.nextUp
        timeImageView.frame.origin = newTimeImageOrigin
        print("endCaretRect", endCaretRect)
    }
    
    private func updateTimeImage() {
        guard let timeText = timeText
            else { return }
        let scale = UIScreen.main.scale
        let textFontAttributes = [NSFontAttributeName: MessageTextViewSettings.shared.timeFont,
                                  NSForegroundColorAttributeName: MessageTextViewSettings.shared.timeColor]
        var size = timeText.size(attributes: textFontAttributes)
        size.width = size.width.nextUp
        size.height = size.height.nextUp
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        timeText.draw(at: CGPoint.zero, withAttributes: textFontAttributes)
        
        timeImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        timeImageView.frame.size = size
        timeImageView.frame.origin = CGPoint.zero
        UIGraphicsEndImageContext()
    }
    
}
