//
//  ViewController.swift
//  Calculator
//
//  Created by Michel Deiman on 16/02/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

 
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var display: UILabel!

    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = numberFormatter.string(from: newValue as NSNumber)
        }
    }
    
    var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction private func backSpace()
    {	guard userIsInTheMiddleOfTyping else { return }
        display.text = String(display.text!.characters.dropLast())
        if display.text?.characters.count == 0
        {	displayValue = 0.0
            userIsInTheMiddleOfTyping = false
        }
    }
    
    @IBAction func floatingPoint() {
        if !userIsInTheMiddleOfTyping {
            display.text = "0" + numberFormatter.decimalSeparator
        } else if !display.text!.contains(numberFormatter.decimalSeparator) {
            display.text = display.text! + numberFormatter.decimalSeparator
        }
        userIsInTheMiddleOfTyping = true
    }

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if !brain.resultIsPending {
                brain.clear()
            }
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        let postfixDescription = brain.resultIsPending ? "..." : "="
        history.text = brain.description + postfixDescription
    }
    
    @IBAction private func clearAll()
    {	brain.clear()
        displayValue = 0.0
        history.text = " "
    }

    @IBOutlet weak var decimalSeparator: UIButton!
    private var numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        decimalSeparator.setTitle(numberFormatter.decimalSeparator,
                                  for: .normal)
        brain.numberFormatter = numberFormatter
    }
    

}

