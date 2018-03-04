//
//  ViewController.swift
//  Calculator
//
//  Created by user on 2/4/18.
//  Copyright © 2018 Varfolomeew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!    //Наш дисплей
    
    @IBOutlet weak var history: UILabel!   //History
    var userIsInTheMiddleOfTyping = false  //чтобы удалять 0, когда юзер начинает писать
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit != ".") || !(textCurrentlyInDisplay.contains(".")) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    var displayValue: Double {                      //Здесь мы преобразовываем display text из string в double
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    private var brain = CalculatorBrain() //здесь мы связываем нашу model с view controller (экземпляр)
    
    @IBAction func performOperation(_ sender: UIButton) {   // КНОПКИ ОПЕРАЦИЙ
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)         //посылаем в преобразованную переменную в функцию setOperand
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {      //optional banding
            brain.performOperation(mathematicalSymbol) //посылаем currentTitle в performOperation
        }
        
        if let result = brain.result {              //даём нашему displayValue инфу полученную от brain.result
            displayValue = result
        }
        if let description = brain.description {
            history.text = description + (brain.resultIsPending ? " ..." : " =")  //добавляем формирование текста HistroyLabel при нажатии кнопки с операцией
        }
    }
    
    @IBAction func clearAll(_ sender: Any) {
        brain.clear()
        displayValue = 0
        history.text = " "
    }
    
}

