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
    @IBOutlet weak var backSpace_Undo: UIButton!
    @IBOutlet weak var memoryKey: UIButton!
    @IBOutlet weak var decimalSeparator: UIButton!

    private var brain = CalculatorBrain()

    var displayValue: Double {
        get {
            guard let valueString = display.text else { return 0.0 }
            let value = numberFormatter.number(from: valueString)
            return Double(value ?? 0)
        }
        set {
            display.text = numberFormatter?.string(from: newValue as NSNumber)
        }
    }
    
    var userIsInTheMiddleOfTyping = false {
        didSet {
            if userIsInTheMiddleOfTyping {
                backSpace_Undo.setTitle("⌫", for: .normal)
            } else {
                backSpace_Undo.setTitle("⋘", for: .normal)
            }
        }
    }
    

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
    {	if userIsInTheMiddleOfTyping {
            display.text = String(display.text!.characters.dropLast())
            if display.text?.characters.count == 0
            {	displayValue = 0.0
                userIsInTheMiddleOfTyping = false
            }
        } else {
            _ = brain.undo()
            evaluateExpression()
//            performOperation(backSpace_Undo)
        
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
            brain.setOperand(displayValue)
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        evaluateExpression()
    }
    
    private func evaluateExpression(using variables: Dictionary<String,Double>? = nil) {
        let evaluation = brain.evaluate(using: variables)
        if let result = evaluation.result {
            displayValue = result
        }
        userIsInTheMiddleOfTyping = false
        let postfixDescription = evaluation.isPending ? "..." : "="
        history.text = evaluation.description + postfixDescription
    }
    
    @IBAction private func clearAll()
    {	brain.clear()
        displayValue = 0.0
        history.text = " "
        memoryKey.setTitle("M", for: .normal)
    }
    
    @IBAction func onMemory(_ sender: UIButton) {
        if let key = sender.currentTitle
        {   if key == "⇢M" {
                let variables = ["M": displayValue]
                memoryKey.setTitle(display.text!, for: .normal)
                evaluateExpression(using: variables)
            } else {
                brain.setOperand(variable: "M")
                evaluateExpression()
            }
        }
    }
    

    private weak var numberFormatter: NumberFormatter! = CalculatorBrain.DoubleToString.numberFormatter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        decimalSeparator.setTitle(numberFormatter?.decimalSeparator, for: .normal)
    }
    

}

