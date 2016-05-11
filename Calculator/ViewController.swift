//
//  ViewController.swift
//  Calculator
//
//  Created by Dino Lupo on 02/05/16.
//  Copyright © 2016 Dino Lupo. All rights reserved.
//

import UIKit
import CleanroomLogger

class ViewController: UIViewController {

    // the calculator brain
    private var brain = CalculatorBrain()
    
    // store if the user is typing a number
    private var userIsInTheMiddleOfTyping = false
    
    // the label that shows all operands that leads to the result
    @IBOutlet weak var displayOperands: UILabel!
    
    // calculator display
    @IBOutlet private weak var display: UILabel!
    
    // touch the dot to input floating point numbers
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

    // touch a digit
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
    
    // update the displayOperands
    private func updateDisplayOperands() {
        displayOperands.text = brain.evalDescription()
    }
    
    // variable to simplify set and get of the calculator display
    private var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            if (newValue % 1 == 0) {
                display.text = String(format: Constants.INT_FORMAT_PRECISION, newValue)
                //display.text = String(Int(newValue))
            } else {
                display.text = String(format: Constants.DOUBLE_FORMAT_PRECISION, newValue)
            }
        }
    }
    

    // touch an operation
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        updateDisplayOperands()
    }
    
    
}

