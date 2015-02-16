import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
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
        evaluate()
    }

    @IBAction func operate(sender: UIButton) {
        var operation = sender.currentTitle!
        if !displayEmpty {
            enter()
        }
        calculator.performOperation(operation)
        evaluate()
    }

    private func evaluate()
    {
        if let result = calculator.evaluate() {
            displayValue = result
        } else {
            displayValue = 0
        }
        displayEmpty = true
    }
}
