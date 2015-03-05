import XCTest

class CalculatorTests: XCTestCase {
    private var calculator = Calculator()
    
    override func setUp() {
        super.setUp()
        calculator.reset()
        calculator.clearVariables()
    }

    func testSimpleClause() {
        calculator.pushOperand(2)
        calculator.pushOperand(3)
        calculator.performOperation("+")
        XCTAssertEqual(calculator.evaluate()!, 5)
        XCTAssertEqual(calculator.description, "2+3")
    }
}
