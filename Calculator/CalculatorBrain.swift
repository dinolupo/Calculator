 //
 //  CalculatorBrain.swift
 //  Calculator
 //
 //  Created by Dino Lupo on 02/05/16.
 //  Copyright © 2016 Dino Lupo. All rights reserved.
 //
 
 import Foundation
 
 
 class CalculatorBrain {
    
    private let DOUBLE_FORMAT_PRECISION = "%.8g"
    
    private var inputSymbols = [String]()

    func evalDescription() -> String {
        
        var desc = ""
        for symbol in inputSymbols {
            desc += symbol
        }
        
        return desc
        
    }
    
    private var isPartialResult : Bool {
        get {
            return pending != nil
        }
    }
    
    private var description = "" {
        didSet {
            print("isPartialResult: \(isPartialResult) - \(description)")
        }
    }
    
    private var accumulator = 0.0
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    
    // called when an operand has been added
    func setOperand(operand: Double) {
        accumulator = operand
        inputSymbols.append(String(format: DOUBLE_FORMAT_PRECISION, operand))
        
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "×" : Operation.BinaryOperation(*),
        "÷" : Operation.BinaryOperation(/),
        "+" : Operation.BinaryOperation(+),
        "−" : Operation.BinaryOperation(-),
        "=" : Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
        case Number(Double)
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            
            inputSymbols.append(symbol)
            
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                
                //                if isPartialResult {
                //                    description += " \(symbol)(\(accumulator))"
                //                } else {
                //                    description = " \(symbol)(\(description))"
                //                }
                
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                //                if isPartialResult {
                //                    description += symbol
                //                } else {
                //                    description = "\(accumulator) \(symbol) "
                //                }
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                //                description += "\(accumulator)"
                executePendingBinaryOperation()
                
            default:
                break
                
            }
            
            print("------------------------------")
            
            print(evalDescription())
            
            
        }
    }
    
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
 }