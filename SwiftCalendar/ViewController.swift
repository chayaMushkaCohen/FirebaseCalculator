//
//  ViewController.swift
//  SwiftCalendar
//
//  Created by hyperactive on 08/09/2020.
//  Copyright © 2020 hyperactive. All rights reserved.
//

import UIKit
import FirebaseDatabase



class ViewController: UIViewController {
    var ref:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    
    var user:User?
    var exerciseDescription = ""

    

    @IBOutlet weak var equationLabel: UILabel!

    

    @IBOutlet weak var clearButton: UIButton!
    var arrayOfNumbersAndArithmetics: [String] = [""]
    var isNewNumber = true
    var isFraction = false
    var placesAfterDecimalPoint:Int = 0
    var lastArithmetic: String = ""
    var isContinousCalculate: Bool = false
    var lastNumberForContinousCalculation: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayOfNumbersAndArithmetics.removeAll()
        isContinousCalculate = false
        
        ref = Database.database().reference()
        if user != nil {
            print("received : \(exerciseDescription)")
            loadExercise()
        }
    }
    
    
    // read From database
    func loadExercise()
    {
        if user != nil
        {
            arrayOfNumbersAndArithmetics.removeAll()
            arrayOfNumbersAndArithmetics = exerciseDescription.components(separatedBy:",")
            if arrayOfNumbersAndArithmetics.last == ","
            {
                arrayOfNumbersAndArithmetics.removeLast()
            }
            print(arrayOfNumbersAndArithmetics)
            calculateEquation()
        }
    }
    
    // write to database
    public func writeToDatabase() {
        var drillDescription = ""
        for item in self.arrayOfNumbersAndArithmetics
        {
            drillDescription += item
            drillDescription += ","
        }
        if user != nil {
            ref?.child("users").child(user!.userName).child("description").setValue(drillDescription)
        }
    }
    
 
    @IBAction func addNumberToArray(_ sender: AnyObject) {
        clearButton.titleLabel?.text = "C"
        let buttonPressed: UIButton = sender as! UIButton
        if (isNewNumber)
        {
            arrayOfNumbersAndArithmetics.append(buttonPressed.titleLabel?.text ?? "0")
            print(arrayOfNumbersAndArithmetics)
            isNewNumber = false
        }
        else // it's not a new number
        {
            if isFraction {
                addFractionToCurrentNumber(buttonPressed.titleLabel?.text ?? "0")
            }
            else
            {
                var lastNumber:Int! = Int(arrayOfNumbersAndArithmetics.last ?? "0")
                lastNumber *= 10
                let buttonPressedValue: String = buttonPressed.titleLabel!.text!
                let buttonPressedIntValue:Int? = Int(buttonPressedValue)
                if let bpiv = buttonPressedIntValue {
                    lastNumber += bpiv
                    if arrayOfNumbersAndArithmetics.count > 0
                    {
                        arrayOfNumbersAndArithmetics.removeLast()
                    }
                    arrayOfNumbersAndArithmetics.append(String(lastNumber))
                }
            }
        }
        equationLabel.text = arrayOfNumbersAndArithmetics.last
        
        if arrayOfNumbersAndArithmetics.last == "7"
        {
            
        }
    }

    
    func addFractionToCurrentNumber(_ numberPressed:String)
    {
        placesAfterDecimalPoint += 1
        var multiplier = 0
        var divider = 1
        while multiplier < placesAfterDecimalPoint
        {
            divider *= 10
            multiplier += 1
        }

        if var newNumber = Double(numberPressed) {
            newNumber /= Double(divider)
            if var lastNumber = Double(arrayOfNumbersAndArithmetics.last!) {
                lastNumber += newNumber
                arrayOfNumbersAndArithmetics.removeLast()
                arrayOfNumbersAndArithmetics.append("\(lastNumber)")
                print(arrayOfNumbersAndArithmetics)
            }
        }
    }

    
    @IBAction func addArithmeticToArray(_ sender: AnyObject) {
        let buttonPressed: UIButton = sender as! UIButton
        if arrayOfNumbersAndArithmetics.last == "+" || arrayOfNumbersAndArithmetics.last == "-" || arrayOfNumbersAndArithmetics.last == "/" || arrayOfNumbersAndArithmetics.last == "*"
        {
            arrayOfNumbersAndArithmetics.removeLast()
        }

        arrayOfNumbersAndArithmetics.append(buttonPressed.titleLabel!.text!)
        if (arrayOfNumbersAndArithmetics.last == "+" || arrayOfNumbersAndArithmetics.last == "-") && arrayOfNumbersAndArithmetics.count > 2 // calculate equation till now
        {
            let lastOperation:String! = arrayOfNumbersAndArithmetics.last
            arrayOfNumbersAndArithmetics.removeLast()
            if checkIfDividedByZero()
            {
                return // divider is 0
            }
            addAndSubtractPartsInEquation()
            equationLabel.text = arrayOfNumbersAndArithmetics.last
            arrayOfNumbersAndArithmetics.append(lastOperation)
        }
        else // it's * or /
        {
            if lastArithmetic == "*" || lastArithmetic == "/"
            {
                let lastOperation:String! = arrayOfNumbersAndArithmetics.last
                arrayOfNumbersAndArithmetics.removeLast()
                if checkIfDividedByZero()
                {
                    return // divider is 0
                }
                equationLabel.text = arrayOfNumbersAndArithmetics.last
                arrayOfNumbersAndArithmetics.append(lastOperation)
            }
        }
        print(arrayOfNumbersAndArithmetics)
        isNewNumber = true
        lastArithmetic = buttonPressed.titleLabel?.text ?? "0"
    }

    
    func checkIfDividedByZero() -> Bool
    {
        if !divideAndMultiplyPartsInEquation()
        {
            equationLabel.text = "not a number"
            arrayOfNumbersAndArithmetics.removeAll()
            return true
        }
        return false
    }


    @IBAction func clear(_ sender: Any) {
        clearButton.titleLabel?.text = "Ac"
        arrayOfNumbersAndArithmetics.removeAll()
        equationLabel.text = "0"
        isContinousCalculate = false
    }

    

    @IBAction func calculate(_ sender: Any) {
        
        writeToDatabase()
        calculateEquation()
        

    }
    
    func calculateEquation()
    {
        while arrayOfNumbersAndArithmetics.last == ""
        {
            arrayOfNumbersAndArithmetics.removeLast()
        }
        if isLastItemIsOperation()
        {
            let itemBeforeOperation = arrayOfNumbersAndArithmetics[arrayOfNumbersAndArithmetics.count - 2]
            arrayOfNumbersAndArithmetics.append(itemBeforeOperation)
            isContinousCalculate = true
            lastNumberForContinousCalculation = itemBeforeOperation
        }
        else if isContinousCalculate && (arrayOfNumbersAndArithmetics.last == "*" || arrayOfNumbersAndArithmetics.last == "/" || arrayOfNumbersAndArithmetics.last == "-" || arrayOfNumbersAndArithmetics.last == "+") // like x + = ...
        {
            arrayOfNumbersAndArithmetics.append(lastArithmetic)
            arrayOfNumbersAndArithmetics.append(lastNumberForContinousCalculation)
        }
        else if arrayOfNumbersAndArithmetics.count > 2 // it's of the form x + b = ...
        {
            lastArithmetic = arrayOfNumbersAndArithmetics[arrayOfNumbersAndArithmetics.count - 2]
            lastNumberForContinousCalculation = arrayOfNumbersAndArithmetics.last ?? "0"
            isContinousCalculate = true
        }
        divideAndMultiplyPartsInEquation()
        addAndSubtractPartsInEquation()
        equationLabel.text = arrayOfNumbersAndArithmetics.last
        
    }

    
    func isLastItemIsOperation() -> Bool
    {
        if arrayOfNumbersAndArithmetics.last == "+" || arrayOfNumbersAndArithmetics.last == "-" || arrayOfNumbersAndArithmetics.last == "*" || arrayOfNumbersAndArithmetics.last == "/"
        {
            return true
        }
        return false
    }


    func divideAndMultiplyPartsInEquation() -> Bool
    {
        if (arrayOfNumbersAndArithmetics.count - 2) > 0
        {
            for index in 0...(arrayOfNumbersAndArithmetics.count - 2)
            {
                if arrayOfNumbersAndArithmetics[index] == "*" || arrayOfNumbersAndArithmetics[index] == "/"
                {
                    if let firstNumber = Double(arrayOfNumbersAndArithmetics[index - 1]) {
                        if let secondNumber = Double(arrayOfNumbersAndArithmetics[index + 1]) {
                            if arrayOfNumbersAndArithmetics[index] == "*"
                            {
                                arrayOfNumbersAndArithmetics[index - 1] = "\(firstNumber * secondNumber)"
                            }
                            else // it is /
                            {
                                if arrayOfNumbersAndArithmetics[index + 1] == "0"
                                {
                                    return false
                                }
                                arrayOfNumbersAndArithmetics[index - 1] = "\(firstNumber / secondNumber)"
                            }
                            arrayOfNumbersAndArithmetics.remove(at: index)
                            arrayOfNumbersAndArithmetics.remove(at: index)
                            print(arrayOfNumbersAndArithmetics)
                        }
                    }
                }
            }
        }
        return true
    }
    

    func addAndSubtractPartsInEquation()
    {
        if (arrayOfNumbersAndArithmetics.count - 2) > 0
        {
            let range = arrayOfNumbersAndArithmetics.count - 2
            for index in 0...range
            {
                if arrayOfNumbersAndArithmetics[index] == "+" || arrayOfNumbersAndArithmetics[index] == "-"
                {
                    if let firstNumber = Double(arrayOfNumbersAndArithmetics[index - 1]) {
                        if let secondNumber = Double(arrayOfNumbersAndArithmetics[index + 1]) {
                            if arrayOfNumbersAndArithmetics[index] == "+"
                            {
                                arrayOfNumbersAndArithmetics[index - 1] = "\(firstNumber + secondNumber)"
                            }
                            else // it is -
                            {
                                arrayOfNumbersAndArithmetics[index - 1] = "\(firstNumber - secondNumber)"
                            }
                            arrayOfNumbersAndArithmetics.remove(at: index)
                            arrayOfNumbersAndArithmetics.remove(at: index)
                            print(arrayOfNumbersAndArithmetics)
                        }
                    }
                }
            }
        }
    }

    

    @IBAction func addFraction(_ sender: Any) {
        isFraction = true
        equationLabel.text?.append(".")
    }

    

    @IBAction func changeSign(_ sender: Any) {
        if let lastNumber = Int(arrayOfNumbersAndArithmetics.last ?? "0")

        {
            arrayOfNumbersAndArithmetics.removeLast()
            arrayOfNumbersAndArithmetics.append("\(lastNumber * -1)")
            print(arrayOfNumbersAndArithmetics)
        }
    }

    

    @IBAction func divideBy100(_ sender: Any) {
        if let lastNumber = Double(arrayOfNumbersAndArithmetics.last ?? "0") {
            arrayOfNumbersAndArithmetics.removeLast()
            arrayOfNumbersAndArithmetics.append("\(lastNumber / 100)")
            equationLabel.text = arrayOfNumbersAndArithmetics.last
            print(arrayOfNumbersAndArithmetics)
        }
    }
}



extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return String(formatter.string(from: number) ?? "")
    }
}

