//
//  ViewController.swift
//  Calculator
//
//  Created by Dino Lupo on 02/05/16.
//  Copyright © 2016 Dino Lupo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    private var userIsInTheMiddleOfTyping = false
    
    @IBOutlet private weak var display: UILabel!
    
    @IBAction func touchDot(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            // if there isn't already a dot, print it
            if display.text!.rangeOfString(".") == nil {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + "."
            }
        } else {
            display.text = "0."
        }
        userIsInTheMiddleOfTyping = true
    }

    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        //print("touched \(digit) digit")
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if displayValue == 0 && digit == "0" {
                return
            }
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        
    }
    
    private var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            if (newValue % 1 == 0) {
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)
            }
        }
    }
    
    private var brain = CalculatorBrain()

    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    
}

