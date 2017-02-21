//
//  CalculatorBrain.swift
//  Calculator 2
//
//  Created by Michel Deiman on 19/02/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation

private func random() -> Double {
    return Double(drand48())
}

struct CalculatorBrain {
    
    var result: Double? {
        return accumulator
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }

    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(accumulator! as AnyObject)
        let stringToAppend = numberFormatter?.string(from: operand as NSNumber) ?? String(operand)
        description += stringToAppend
    }
    
    mutating func performOperation(_ symbol: String) {
        guard let operation = operations[symbol] else { return }
        switch operation {
        case .constant(let value) :
            accumulator = value
            description += symbol
        case .unaryOperation(let f):
            if let operand = accumulator {
                description += symbol
                accumulator = f(operand)
            }
        case .binaryOperation(let f):
            if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation(function: f, firstOperand: accumulator!)
                accumulator = nil
                description += symbol
            }
        case .operationNoArguments(let f): accumulator = f()
        case .equals:
            performBinaryOperation()
        }
        internalProgram.append(symbol as AnyObject)
    }

    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        internalProgram = []
        description = ""
    }
    
    weak var numberFormatter: NumberFormatter?
    
    private var accumulator: Double?
    
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
    
    private var internalProgram = [AnyObject]()
    
    
    var description: String = ""
//    {
//        var targetString = ""
//        for property in internalProgram {
//            if let operand = property as? Double {
//                let stringToAppend = numberFormatter?.string(from: operand as NSNumber) ?? String(operand)
//                targetString = targetString + stringToAppend
//            } else {
//                let symbol = property as! String
//                let operation = operations[symbol]!
//                switch operation {
//                case .constant, .binaryOperation, .operationNoArguments:
//                    targetString = targetString + symbol
//                case .unaryOperation:
//                    targetString = symbol + "(" + targetString + ")"
//                default: break
//                }
//            }
//        }
//        return targetString
//    }
    
}
