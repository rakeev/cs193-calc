import XCTest

class CalculatorTests: XCTestCase {
    private var calculator = Calculator()
    
    override func setUp() {
        super.setUp()
        calculator.reset()
        calculator.clearVariables()
    }

    func testSimpleClause() {
        pushTwoPlusThree()
        XCTAssertEqual(calculator.evaluate()!, 5)
        XCTAssertEqual(calculator.description, "2+3")
    }

    func testSeparateClauses() {
        pushTwoPlusThree()
        pushSquareRootFour()
        XCTAssertEqual(calculator.evaluate()!, 2)
        XCTAssertEqual(calculator.description, "2+3,√(4)")
    }

    func testOperatorPrecedence() {
        pushTwoPlusThree()
        pushSquareRootFour()
        calculator.performOperation("×")
        XCTAssertEqual(calculator.evaluate()!, 10)
        XCTAssertEqual(calculator.description, "(2+3)×√(4)")
    }

    func testExcessiveParentheses() {
        pushTwoPlusThree()
        calculator.pushOperand(4)
        calculator.pushOperand(2)
        calculator.performOperation("×")
        calculator.performOperation("+")
        XCTAssertEqual(calculator.evaluate()!, 13)
        XCTAssertEqual(calculator.description, "2+3+4×2")
    }

    func testSetVariable() {
        XCTAssertNil(calculator.getVariable("x"))
        calculator.setVariable("x", value: 42)
        XCTAssertEqual(calculator.getVariable("x")!, 42)
    }

    func testConstantOverride() {
        let accuracy = pow(Double(10), Double(-6))
        XCTAssertEqualWithAccuracy(calculator.getVariable("π")!, M_PI, accuracy)
        calculator.setVariable("π", value: M_E)
        XCTAssertEqualWithAccuracy(calculator.getVariable("π")!, M_PI, accuracy)
    }

    func testUseVariable() {
        calculator.pushOperand(2)
        calculator.pushOperand("x")
        calculator.performOperation("+")
        XCTAssertNil(calculator.evaluate())
        XCTAssertEqual(calculator.description, "2+x")

        calculator.setVariable("x", value: 3)
        XCTAssertEqual(calculator.evaluate()!, 5)
        XCTAssertEqual(calculator.description, "2+x")

        calculator.setVariable("x", value: 2.1)
        XCTAssertEqual(calculator.evaluate()!, 4.1)
        XCTAssertEqual(calculator.description, "2+x")
    }

    func testNotANumber() {
        calculator.pushOperand(-9)
        calculator.performOperation("√")
        XCTAssert(calculator.evaluate()!.isNaN)
    }

    private func pushTwoPlusThree() {
        calculator.pushOperand(2)
        calculator.pushOperand(3)
        calculator.performOperation("+")
    }

    private func pushSquareRootFour() {
        calculator.pushOperand(4)
        calculator.performOperation("√")
    }
}
