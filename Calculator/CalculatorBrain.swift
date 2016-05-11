 //
 //  CalculatorBrain.swift
 //  Calculator
 //
 //  Created by Dino Lupo on 02/05/16.
 //  Copyright © 2016 Dino Lupo. All rights reserved.
 //
 
 import Foundation
 import CleanroomLogger
 
 
 class CalculatorBrain {
    
    
    
    // store a list of input symbols to print operations executed on the calculator
    private var inputSymbolsArray = [String]()

    // list of all supported calculator operations
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
    
    private var isPartialResult : Bool {
        get {
            return pending != nil
        }
    }
    
    private var accumulator = 0.0
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    var result: Double {
        get {
            return accumulator
        }
    }

    // prints a description of all operations inputed on the calculator
    func evalDescription() -> String {
        
        var desc = ""
        for symbol in inputSymbolsArray {
            desc += "\(symbol) "
        }
        
        if isPartialResult {
            desc = "\(desc)..."
        } else {
            desc = "\(desc)="
        }
        
        return desc
        
    }
    
    // called when an operand has been added
    func setOperand(operand: Double) {
        Log.verbose?.trace()
        Log.verbose?.value(operand)
        accumulator = operand
        
        // update symbols array
        if !isPartialResult {
            inputSymbolsArray.removeAll()
        }
        inputSymbolsArray.append(String(format: Constants.DOUBLE_FORMAT_PRECISION, operand))
    }
    
    // execute an operation
    func performOperation(symbol: String) {
        Log.verbose?.trace()
        Log.verbose?.value(symbol)
        if let operation = operations[symbol] {
            
            switch operation {
            case .Constant(let value):
                // update symbols array
                if !isPartialResult {
                    inputSymbolsArray.removeAll()
                }
                inputSymbolsArray.append(symbol)
                
                // store constant
                accumulator = value
                
            case .UnaryOperation(let function):
                // update symbols array
                let unaryOperand = inputSymbolsArray.popLast()!
                inputSymbolsArray.append("\(symbol)(\(unaryOperand))")
                
                // execute operation
                accumulator = function(accumulator)
                
            case .BinaryOperation(let function):
                // update symbols array
                inputSymbolsArray.append(symbol)
                
                // execute operation
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                
            case .Equals:
                // execute operation
                executePendingBinaryOperation()
                
            default:
                break
                
            }
            
            Log.info?.message("------------------------------")
            Log.warning?.message(evalDescription())
        }
    }
    
    
    private func executePendingBinaryOperation() {
        Log.verbose?.trace()
        if pending != nil {
            // update symbols array
            let secondOperand = inputSymbolsArray.popLast()!
            let operation = inputSymbolsArray.popLast()!
            let firstOperand = inputSymbolsArray.popLast()!
            let executedOperation = "\(firstOperand) \(operation) \(secondOperand)"
            inputSymbolsArray.append(executedOperation)
            
            // execute operation
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            
            pending = nil
        }
    }
    
    
    
 }