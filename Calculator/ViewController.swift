import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    var displayEmpty = true

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if displayEmpty {
            display.text = digit
            displayEmpty = false
        } else {
            display.text = display.text! + digit
        }
    }
}
