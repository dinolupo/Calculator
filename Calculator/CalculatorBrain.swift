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
    
    // store last executed binary operation, in case the user press "=" symbol multiple times,
    // this operation will be executed
    private var lastBinaryOperation: BinaryOperationInfo?
    
    // store a list of input symbols to print operations executed on the calculator
    private var inputSymbolsArray = [String]()

    // if last input is a number then true, else false
    private var lastIsOperand: Bool = false
    
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
        "=" : Operation.Equals,
        "AC": Operation.Reset
        
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case Equals
        case Reset
    }
    
    var isPartialResult : Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private var accumulator = 0.0
    
    private struct BinaryOperationInfo {
        var symbol: String
        var binaryFunction: (Double, Double) -> Double
        var operand: Double
    }
    
    private var pendingBinaryOperation: BinaryOperationInfo?
    
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
        }
        else {
            desc = "\(desc)="
        }
        
        return desc
        
    }
    
    // called when an operand has been added
    func setOperand(operand: Double) {
        lastIsOperand = true
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
                lastIsOperand = true
                // update symbols array
                if !isPartialResult {
                    inputSymbolsArray.removeAll()
                }
                inputSymbolsArray.append(symbol)
                
                // store constant
                accumulator = value
                
            case .UnaryOperation(let function):
                lastIsOperand = true
                // update symbols array
                let unaryOperand = inputSymbolsArray.popLast()!
                inputSymbolsArray.append("\(symbol)(\(unaryOperand))")
                
                // execute operation
                accumulator = function(accumulator)
                
            case .BinaryOperation(let function):
                lastIsOperand = false
                // execute operation
                executePendingBinaryOperation()
                pendingBinaryOperation = BinaryOperationInfo(symbol: symbol, binaryFunction: function, operand: accumulator)
                
                // update description symbols array
                inputSymbolsArray.append(symbol)

            case .Equals:
               
                if isPartialResult {
                    if !lastIsOperand {
                        setOperand((pendingBinaryOperation?.operand)!)
                    }
                    
                    executePendingBinaryOperation()
                } else {
                    executePreviousOperation()
                }

            case .Reset:
                accumulator = 0.0
                pendingBinaryOperation = nil
                lastBinaryOperation = nil
                inputSymbolsArray.removeAll()
            }
        }
    }
    
    // this will be called on subsequent press of Equals sign
    private func executePreviousOperation() {
        Log.verbose?.trace()
        if lastBinaryOperation != nil {
            // update the symbols array for building the string of all executed operations
            
            // update symbols array
            let secondOperand = String(format: Constants.DOUBLE_FORMAT_PRECISION, lastBinaryOperation!.operand)
            let operation = lastBinaryOperation!.symbol
            let firstOperand = inputSymbolsArray.popLast()!
            let executedOperation = "\(firstOperand) \(operation) \(secondOperand)"
            inputSymbolsArray.append(executedOperation)
            
            // execute again the binary operation on multiple "=" touch
            accumulator = lastBinaryOperation!.binaryFunction(accumulator, lastBinaryOperation!.operand)
        }
    }
    
    
    private func executePendingBinaryOperation() {
        Log.verbose?.trace()
        Log.warning?.message(evalDescription())
        if pendingBinaryOperation != nil {
            
            // merge the current binary operation into a single description symbol
            let secondOperand = inputSymbolsArray.popLast()!
            let operation = inputSymbolsArray.popLast()!
            let firstOperand = inputSymbolsArray.popLast()!
            let executedOperation = "\(firstOperand) \(operation) \(secondOperand)"
            inputSymbolsArray.append(executedOperation)
            
            // store last binary function and last operand in case the user press = signs again execute operation again
            lastBinaryOperation = BinaryOperationInfo(symbol: pendingBinaryOperation!.symbol, binaryFunction: pendingBinaryOperation!.binaryFunction, operand: accumulator)
            
            // execute operation
            accumulator = pendingBinaryOperation!.binaryFunction(pendingBinaryOperation!.operand, accumulator)
            
            pendingBinaryOperation = nil
        }
    }
    
    
    
 }