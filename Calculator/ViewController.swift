import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var point: UIButton!
    private var displayValue: Double? {
        get {
            return display.text == nil ? nil : format.numberFromString(display.text!)?.doubleValue
        }
        set {
            display.text = newValue == nil ? nil : format.stringFromNumber(newValue!)
            displayEmpty = true
        }
    }
    private var displayEmpty = true
    private var calculator = Calculator()
    private var format = NSNumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        format.notANumberSymbol = "Err"
        format.numberStyle = NSNumberFormatterStyle.DecimalStyle
        point.setTitle(format.decimalSeparator, forState: UIControlState.Normal)
    }

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if displayEmpty {
            display.text = digit
            displayEmpty = false
        } else if digit != format.decimalSeparator || display.text?.rangeOfString(digit) == nil {
            display.text = display.text! + digit
        }
    }

    @IBAction func enter() {
        if let value = displayValue {
            calculator.pushOperand(value)
            history.text = "\(calculator)"
            displayEmpty = true
        }
    }

    @IBAction func useVariable(sender: UIButton) {
        var symbol = sender.currentTitle!
        if !displayEmpty {
            enter()
        }
        calculator.pushOperand(symbol)
        history.text = "\(calculator)"
    }

    @IBAction func setVariable(sender: UIButton) {
        var symbol = dropFirst(sender.currentTitle!)
        if let value = displayValue {
            calculator.variables[symbol] = value
            evaluate()
        }
    }

    @IBAction func operate(sender: UIButton) {
        var operation = sender.currentTitle!
        if !displayEmpty {
            enter()
        }
        calculator.performOperation(operation)
        evaluate()
    }

    @IBAction func plusMinus(sender: UIButton) {
        if displayEmpty {
            return operate(sender)
        }
        if let text = display.text {
            display.text = text.hasPrefix("-") ? dropFirst(text) : "-\(text)"
        }
    }

    @IBAction func erase() {
        if displayEmpty || countElements(display.text!) < 2 {
            displayValue = nil
            return
        }
        display.text = dropLast(display.text!)
    }

    @IBAction func reset() {
        calculator.variables.removeAll()
        calculator.reset()
        evaluate()
    }

    private func evaluate() {
        displayValue = calculator.evaluate()
        let sign = displayValue == nil ? "" : " ="
        history.text = "\(calculator)\(sign)"
    }
}
