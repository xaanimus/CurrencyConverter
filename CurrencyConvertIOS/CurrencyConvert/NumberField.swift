//
//  NumberField.swift
//  CurrencyConvert
//
//  Created by Serge-Olivier Amega on 7/18/16.
//  Copyright © 2016 xaanimus. All rights reserved.
//

import UIKit

class NumberFieldView : UIView {
    
    var string : String? { get {return label.text} }
    var number : Double? {
        get {
            if let str = string {
                return Double(str)
            } else {
                return nil
            }
        }
    }
    
    let label : UILabel!
    
    override init(frame: CGRect) {
        label = UILabel(frame: frame)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)
        setup()
    }
    
    func setString(str:String) {
        label.text = str
    }
    
    func insertString(str:String) {
        if label.text != nil {
            label.text = label.text! + str
        } else {
            label.text = str
        }
    }
    
    func delete() {
        if let text = label.text {
            guard text.characters.count > 0 else {return}
            label.text = text[text.startIndex..<text.endIndex.predecessor()]
        }
    }
    
    func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.leftAnchor.constraintEqualToAnchor(self.layoutMarginsGuide.leftAnchor).active = true
        label.centerYAnchor.constraintEqualToAnchor(self.layoutMarginsGuide.centerYAnchor).active = true
        label.text = "0"
        label.textColor = UIColor.whiteColor()
    }
    
    override func drawRect(rect: CGRect) {
        drawLine(rect)
    }
    
    func drawLine(rect: CGRect) {
        UIColor.whiteColor().setStroke()
        
        let path = CGPathCreateMutable()
        let xOffset : CGFloat = 7
        let y = rect.origin.y + rect.size.height - 3
        CGPathMoveToPoint(path, nil, xOffset + rect.origin.x, y)
        CGPathAddLineToPoint(path, nil, rect.origin.x + rect.size.width, y)
        UIBezierPath(CGPath: path).stroke()
    }
}