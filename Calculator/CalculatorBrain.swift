//
//  CalculatorBrain.swift
//  Calculator 2
//
//  Created by Michel Deiman on 19/02/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    var result: Double? {
        return accumulator
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }

    mutating func setOperand(_ operand: Double) {
        if !resultIsPending {
            clear()
        }
        accumulator = operand
        descriptions.append(formattedAccumulator!)
    }
    
    
    mutating func performOperation(_ symbol: String) {
        guard let operation = operations[symbol] else { return }
        switch operation {
        case .constant(let value) :
            accumulator = value
            descriptions.append(symbol)
        case .unaryOperation(let f):
            if let operand = accumulator {
                if resultIsPending {
                    let lastOperand = descriptions.last!
                    descriptions = [String](descriptions.dropLast()) + [symbol + "(" + lastOperand + ")"]
                } else {
                    descriptions = [symbol + "("] + descriptions + [")"]
                }
                accumulator = f(operand)
            }
        case .binaryOperation(let f):
            if resultIsPending {
                performBinaryOperation()
            }
            if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation(function: f, firstOperand: accumulator!)
                descriptions.append(symbol)
            }
        case .operationNoArguments(let f):
            accumulator = f()
            descriptions.append(symbol)
        case .equals:
            performBinaryOperation()
        }
    }

    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptions = []
    }
    
    weak var numberFormatter: NumberFormatter?
    
    var description: String {
        var returnString: String = ""
        for element in descriptions {
            returnString += element
        }
        return returnString
    }
    
    // private section starts here ...
    
    private var descriptions: [String] = []
    
    private var accumulator: Double?
    private var formattedAccumulator: String? {
        if let number = accumulator {
            return numberFormatter?.string(from: number as NSNumber) ?? String(number)
        } else {
            return nil
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case operationNoArguments(()->Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "%": Operation.unaryOperation({ $0/100 }),
        "sin": Operation.unaryOperation(sin),
        "cos": Operation.unaryOperation(cos),
        "tan": Operation.unaryOperation(tan),
        "Ran": Operation.operationNoArguments({ Double(drand48()) }),
        "⁺∕₋": Operation.unaryOperation { -$0 },
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "=": Operation.equals
    ]
    
    
    private mutating func performBinaryOperation() {
        guard pendingBinaryOperation != nil && accumulator != nil else {  return }
        accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        pendingBinaryOperation = nil
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
}
