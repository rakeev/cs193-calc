import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    var displayValue: Double {
        get {
            return (display.text! as NSString).doubleValue
        }
        set {
            display.text = "\(newValue)"
            displayEmpty = true
        }
    }
    var displayEmpty = true
    var operandStack = [Double]()

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
        operandStack.append(displayValue)
        displayEmpty = true
    }

    @IBAction func operate(sender: UIButton) {
        var operation = sender.currentTitle!
        if !displayEmpty {
            enter()
        }
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        default: break
        }
    }

    func performOperation(operation: (Double, Double) -> Double) {
        padStack(2)
        displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
        enter()
    }

    func performOperation(operation: Double -> Double) {
        padStack(1)
        displayValue = operation(operandStack.removeLast())
        enter()
    }

    func padStack(count: Int) {
        while operandStack.count < count {
            enter()
        }
    }
}
