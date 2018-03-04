//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by user on 2/6/18.
//  Copyright © 2018 Varfolomeew. All rights reserved.
//

import Foundation

//func changeSign(operand: Double) -> Double {
//   return -operand
//}
//func multiply(op1: Double, op2: Double) -> Double {
//    return op1 * op2
//}

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var descriptionAccumulator: String?
    
    let formatter: NumberFormatter = {              //настройка представления чисел с 6-ю значащими цифрами
        let formatter = NumberFormatter ()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.notANumberSymbol = "Error"
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    } () //- иницализация переменной(или константы) с помощью мгновенного выполнения замыкания.
    
    var description: String? {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, descriptionAccumulator ?? "" )
            }
        }
    }
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double,((String) -> String)?)
        case binaryOperation((Double, Double) -> Double,((String, String) -> String)?)
        case nullaryOperation(()-> Double, String)
        case equals
        
    }
    private var operations: Dictionary<String, Operation> = [
        "Ran": Operation.nullaryOperation({Double(arc4random())/Double(UInt32.max)}, "rand()"),
        "π": Operation.constant(Double.pi),
        "√": Operation.unaryOperation(sqrt, nil),
        "e": Operation.constant(M_E),
        "ln": Operation.unaryOperation(log, nil),
        "sin": Operation.unaryOperation(sin, nil),
        "cos": Operation.unaryOperation(cos, nil),
        "tan": Operation.unaryOperation(tan, nil),
        "x⁻¹": Operation.unaryOperation({ 1.0 / $0 }, {"(" + $0 + ")⁻¹"}),
        "xʸ": Operation.binaryOperation(pow, { $0 + " ^ " + $1}),
        "sin⁻¹": Operation.unaryOperation(asin, nil),
        "cos⁻¹": Operation.unaryOperation(acos, nil),
        "tan⁻¹": Operation.unaryOperation(atan, nil),
        "х²" : Operation.unaryOperation( {$0 * $0}, { "(" + $0 + ")²"} ),
        "±": Operation.unaryOperation({ -$0} , nil ),
        "×": Operation.binaryOperation({ $0 * $1} , nil),//{(op1: Double, op2: Double) -> Double in return op1 * op2}
        "÷": Operation.binaryOperation({ $0 / $1} , nil),
        "+": Operation.binaryOperation({ $0 + $1}, nil),
        "-": Operation.binaryOperation({ $0 - $1} , nil),
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {     //mutating!
        if let operation = operations[symbol] {                      //if let, потому что запрашиваемого ключа может и не быть в словаре
            switch operation {
                
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
                
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
                
            case .unaryOperation(let function, var descriptionFunction):
                if accumulator != nil {
                    accumulator = function (accumulator!)
                    if descriptionFunction  == nil{
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                    descriptionAccumulator = descriptionFunction!(descriptionAccumulator!)
                }
                
            case .binaryOperation (let function, var descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    if descriptionFunction  == nil {
                        descriptionFunction = {$0 + " " + symbol + " " + $1}
                    }
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: descriptionAccumulator!)
                    accumulator = nil
                    descriptionAccumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            
            descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator!)
            
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil        //возвращает значение, показывающее, является ли бинарная операция отложенной (если да, возвращает true, если нет, то false).
        }
    }
    
    private struct PendingBinaryOperation {                     //создали структуру с автоинициализаторами, чтобы высчитывать equals
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        func performDescription (with secondOperand: String) -> String {
            return descriptionFunction ( descriptionOperand, secondOperand)
        }
    }
    
    mutating  func setOperand(_ operand: Double) { //устанавливаем операнд
        accumulator = operand
        if let value = accumulator {
            descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
        }
    }
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptionAccumulator = " "
    }
    







}























