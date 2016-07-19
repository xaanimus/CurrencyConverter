//
//  ViewController.swift
//  CurrencyConvert
//
//  Created by Serge-Olivier Amega on 7/18/16.
//  Copyright © 2016 xaanimus. All rights reserved.
//

import UIKit
import Hue

let appFont = UIFont(name: "Avenir-Book", size: 15)!

class ViewController: UIViewController {

    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    
    @IBOutlet weak var numpadView: UIView!
    @IBOutlet weak var fromNumberView: NumberFieldView!
    @IBOutlet weak var toNumberView: NumberFieldView!
    var yPickerViewShown : CGFloat { get {return self.view.frame.origin.y + self.view.frame.size.height - self.numpadView.frame.size.height}}
    var yPickerViewHidden : CGFloat { get {return self.view.frame.height}}
    
    lazy var improperFormatLabel : UILabel = {
        let label = UILabel()
        label.text = "IMPROPER NUMBER FORMAT!"
        label.font = appFont
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        let margins = self.view.layoutMarginsGuide
        label.centerXAnchor.constraintEqualToAnchor(margins.centerXAnchor).active = true
        label.bottomAnchor.constraintEqualToAnchor(self.numpadView.layoutMarginsGuide.topAnchor, constant:-14.0).active = true
        
        label.textColor = UIColor.clearColor()
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 1.0
        label.layer.shadowRadius = 1.0
        label.layer.masksToBounds = false
        return label
    }()
    
    lazy var picker : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        
        let rect = self.view.frame
        
        picker.frame = CGRect(x: rect.origin.x,
                              y: self.yPickerViewHidden,
                              width: rect.size.width, height: self.numpadView.frame.size.height)
        picker.backgroundColor = self.numpadView.backgroundColor
        
        self.view.addSubview(picker)
        
        let pickerTitleLabel = UILabel()
        pickerTitleLabel.text = "Choose a currency."
        pickerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        picker.addSubview(pickerTitleLabel)
        pickerTitleLabel.centerXAnchor.constraintEqualToAnchor(picker.layoutMarginsGuide.centerXAnchor).active = true
        pickerTitleLabel.topAnchor.constraintEqualToAnchor(picker.layoutMarginsGuide.topAnchor, constant: 10.0).active = true
        pickerTitleLabel.textColor = UIColor.whiteColor()
        pickerTitleLabel.font = appFont.fontWithSize(20.0)
        
        return picker
    }()
    
    var exchangeRateManager : ExchangeRateManager?
    
    func loadButtons() {
        let margins = numpadView.layoutMarginsGuide
        let width = numpadView.frame.width
        let height = numpadView.frame.height
        
        let xInset = numpadView.frame.size.width / 7
        let yInset = numpadView.frame.size.height / 9
        
        for i in 0..<3 {
            for j in 0..<3 {
                let num = (i*3) + j + 1
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: width/3, height: height/4))
                button.contentEdgeInsets = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
                button.setTitle("\(num)", forState: UIControlState.Normal)
                button.titleLabel?.font = appFont.fontWithSize(20.0)
                button.translatesAutoresizingMaskIntoConstraints = false
                
                numpadView.addSubview(button)
                
                button.centerXAnchor.constraintEqualToAnchor(margins.centerXAnchor, constant: width/3*(CGFloat(j)-1)).active = true
                button.centerYAnchor.constraintEqualToAnchor(margins.centerYAnchor, constant: height/4*(-3/2+CGFloat(i))).active = true
                
                button.addTarget(self, action: #selector(ViewController.numberPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        let buttons = (0..<3).map { _ in
            UIButton(frame:CGRect(x: 0, y: 0, width: width/3, height: height/4))
        }
        let titles = [".", "0", "del"]
        for i in 0..<buttons.count {
            let b = buttons[i]
            b.contentEdgeInsets = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
            b.setTitle(titles[i], forState: UIControlState.Normal)
            b.titleLabel?.font = appFont.fontWithSize(20.0)
            b.translatesAutoresizingMaskIntoConstraints = false
            numpadView.addSubview(b)
            b.centerXAnchor.constraintEqualToAnchor(margins.centerXAnchor, constant: CGFloat(i-1)*width/3).active = true
            b.centerYAnchor.constraintEqualToAnchor(margins.centerYAnchor, constant: height/8*3).active = true
            b.addTarget(self, action: #selector(ViewController.numberPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            self.exchangeRateManager = try FixerioExchangeRateManager()
        } catch let e {
            print("exchange rate manager not initialized")
            print(e)
            abort()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        loadButtons()
        picker.frame.origin.y = yPickerViewHidden
    }
    
    func numberPressed(sender: UIButton) {
        guard let text = sender.titleLabel?.text else {print("ERROR no title for button pressed"); return}
        
        switch text {
        case "del": fromNumberView.delete()
        case let x: fromNumberView.insertString(x)
        }
        
        convertMoney()
    }
    
    func convertMoney() {
        guard let num = fromNumberView.number else {showImproperFormat(); return}
        hideImproperFormat()
        if let result = exchangeRateManager!.convert(Money(currency: fromButton.titleLabel!.text!, value:num ),
                                                     to: toButton.titleLabel!.text!)
        {
            toNumberView.setString(String(result.value))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var showing = false
    @IBAction func showPicker(sender: UIButton) {
        if showing == false {
            showing = true
            UIView.animateWithDuration(0.25) {
                self.picker.frame.origin.y = self.yPickerViewShown
            }
            if sender == fromButton {
                setCurrencyForTop = true
            } else {
                setCurrencyForTop = false
            }
        } else {
            showing = false
            UIView.animateWithDuration(0.25) {
                self.picker.frame.origin.y = self.yPickerViewHidden
            }
        }
    }
    
    var setCurrencyForTop = false
    func setCurrency(str:String) {
        if setCurrencyForTop {
            fromButton.setTitle(str, forState: UIControlState.Normal)
        } else {
            toButton.setTitle(str, forState: UIControlState.Normal)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    var showingImproperFormat = false
    func showImproperFormat() {
        if !showingImproperFormat {
            showingImproperFormat = true
            let label = improperFormatLabel
            UIView.transitionWithView(label,
                                      duration: 0.1,
                                      options: UIViewAnimationOptions.TransitionCrossDissolve,
                                      animations: {
                                        label.textColor = UIColor.hex("#ffbbbb")
                                        label.layer.shadowColor = UIColor.hex("#ffaaaa").CGColor
                }, completion: nil)
        }
    }
    
    func hideImproperFormat() {
        if showingImproperFormat {
            showingImproperFormat = false
            UIView.transitionWithView(improperFormatLabel,
                                      duration: 0.5,
                                      options: UIViewAnimationOptions.TransitionCrossDissolve,
                                      animations: {
                                        self.improperFormatLabel.textColor = UIColor.clearColor()
                }, completion: nil)
        }
    }

}

extension ViewController : UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.exchangeRateManager!.size
    }
}

extension ViewController : UIPickerViewDataSource {
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let str = self.exchangeRateManager!.currencies[row]
        let attr : [String:AnyObject] = [NSForegroundColorAttributeName : UIColor.whiteColor(),
                                         NSFontAttributeName : appFont]
        return NSAttributedString(string: str, attributes: attr)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let str = self.exchangeRateManager!.currencies[row]
        setCurrency(str)
    }
}