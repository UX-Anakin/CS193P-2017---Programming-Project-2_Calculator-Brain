//
//  CalculatorBrain.swift
//  Calculator 2
//
//  Created by Michel Deiman on 19/02/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
@available(iOS, deprecated, message: "No longer needed")
    var result: Double? {
        let evaluation = evaluate()
        return evaluation.result
    }
    
@available(iOS, deprecated, message: "No longer needed")
    var resultIsPending: Bool {
        let evaluation = evaluate()
        return evaluation.isPending
    }
    
    mutating func setOperand(_ operand: Double) {
        if pendingBinaryOperation == nil {
            clear()
        }
        accumulator = operand
        expression.append(.operand(.value(operand)))
    }
    
    mutating func setOperand(variable named: String)
    {   if pendingBinaryOperation == nil {
            clear()
        }
        variables[named] = accumulator ?? 0
        expression.append(.operand(.variable(named)))
    }
    
    mutating func undo() {
        guard !expression.isEmpty else { return }
        expression = [ExpressionLiteral](expression.dropLast())
        let evaluation = evaluate(using: variables)
        
    }
    
    private func evaluate(using calculatorBrain: CalculatorBrain) -> (result: Double?, isPending: Bool, description: String) {
        
        
        return (0, true, "")
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String)
    {   var calculatorBrain = CalculatorBrain()
        calculatorBrain.numberFormatter = numberFormatter
        for expressionLiteral in expression {
            switch expressionLiteral {
            case .operand(let operand):
                switch operand {
                case .variable(let name):
                    calculatorBrain.setOperand(variables?[name] ?? 0)
                case .value(let operandValue):
                    calculatorBrain.setOperand(operandValue)
                case .valueAsString(let valueAsString):
                    calculatorBrain.setOperand(Double(valueAsString)!)
                }
            case .operation(let symbol):
                calculatorBrain.performOperation(symbol)
            }
        }
        return(calculatorBrain.accumulator, calculatorBrain.pendingBinaryOperation != nil, calculatorBrain.createDescription())
    }
    
    mutating func performOperation(_ symbol: String) {
        guard let operation = operations[symbol] else { return }
        switch operation {
        case .constant(let value) :
            accumulator = value
        case .unaryOperation(let f):
            if let operand = accumulator {
                accumulator = f(operand)
            }
        case .binaryOperation(let f):
            if pendingBinaryOperation != nil {
                performBinaryOperation()
            }
            if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation(function: f, firstOperand: accumulator!)
            }
        case .operationNoArguments(let f):
            accumulator = f()
        case .equals:
            performBinaryOperation()
        }
        if accumulator != nil {
            expression.append(.operation(symbol))
        }
    }

    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        expression = []
    }
    
    weak var numberFormatter: NumberFormatter?
    
@available(iOS, deprecated, message: "No longer needed")
    var description: String {
        return createDescription()
    }
    
    // private section starts here ...
    private func createDescription() -> String {
        var descriptions: [String] = []
        var pendingBinaryOperation = false
        for literal in expression
        {   switch literal {
            case .operand(let operand):
                switch operand {
                case .value(let value): descriptions += [numberFormatter?.string(from: value as NSNumber) ?? String(value)]
                case .variable(let name): descriptions += [name]
                case .valueAsString(let valueAsString): descriptions += [valueAsString]
                }
            case .operation(let symbol):
                guard let operation = operations[symbol] else { break }
                switch operation {
                case .equals:
                    pendingBinaryOperation = false
                case .unaryOperation:
                    if pendingBinaryOperation {
                        let lastOperand = descriptions.last!
                        descriptions = [String](descriptions.dropLast()) + [symbol + "(" + lastOperand + ")"]
                    } else {
                        descriptions = [symbol + "("] + descriptions + [")"]
                    }
                case .binaryOperation:
                    pendingBinaryOperation = true
                    fallthrough
                default: descriptions += [symbol]
                }
            }
        }
        return descriptions.reduce("", +)
    }
    
    private var accumulator: Double?
    private var formattedAccumulator: String? {
        if let number = accumulator {
            return numberFormatter?.string(from: number as NSNumber) ?? String(number)
        } else {
            return nil
        }
    }
    
    private var expression: [ExpressionLiteral] = []
    
    private enum ExpressionLiteral {
        case operand(Operand)
        case operation(String)
        
        enum Operand {
            case variable(String)
            case value(Double)
            case valueAsString(String)
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case operationNoArguments(()->Double)
        case equals
    }
    
    private var variables: [String: Double] = [:]
    
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
