import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var point: UIButton!
    private var displayValue: Double {
        get {
            return format.numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = format.stringFromNumber(newValue)
            displayEmpty = true
        }
    }
    private var displayEmpty = true
    private var calculator = Calculator()
    private var format = NSNumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func plusMinus(sender: UIButton) {
        if displayEmpty {
            return operate(sender)
        }
        display.text = display.text!.hasPrefix("-") ? dropFirst(display.text!) : "-\(display.text!)"
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
