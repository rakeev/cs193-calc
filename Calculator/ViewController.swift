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
        } else {
            display.text = display.text! + digit
        }
    }

    @IBAction func enter() {
        operandStack.append(displayValue)
        displayEmpty = true
    }
}
