import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    private var displayValue: Double {
        get {
            return (display.text! as NSString).doubleValue
        }
        set {
            display.text = "\(newValue)"
            displayEmpty = true
        }
    }
    private var displayEmpty = true
    private var calculator = Calculator()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if displayEmpty {
            display.text = digit
            displayEmpty = false
        } else if digit != "." || display.text?.rangeOfString(digit) == nil {
            display.text = display.text! + digit
        }
    }

    @IBAction func enter() {
        calculator.pushOperand(displayValue)
        history.text = "\(calculator)"
        displayEmpty = true
    }

    @IBAction func operate(sender: UIButton) {
        var operation = sender.currentTitle!
        if !displayEmpty {
            enter()
        }
        calculator.performOperation(operation)
        if let result = calculator.evaluate() {
            displayValue = result
        } else {
            displayValue = 0
        }
        history.text = "\(calculator) ="
    }

    @IBAction func erase() {
        if displayEmpty || countElements(display.text!) < 2 {
            displayValue = 0
            return
        }
        display.text = dropLast(display.text!)
    }

    @IBAction func reset() {
        calculator.reset()
        history.text = ""
        displayValue = 0
    }
}
