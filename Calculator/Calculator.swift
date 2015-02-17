import Foundation

class Calculator {
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperator(String, Double -> Double)
        case BinaryOperator(String, (Double, Double) -> Double)

        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .UnaryOperator(let symbol, _):
                return symbol
            case .BinaryOperator(let symbol, _):
                return symbol
            }
        }
    }

    private var opStack = [Op]()
    private var knownOps = [String: Op]()

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(.BinaryOperator("×", *))
        learnOp(.BinaryOperator("÷", /))
        learnOp(.BinaryOperator("+", +))
        learnOp(.BinaryOperator("−", -))
        learnOp(.UnaryOperator("sin", sin))
        learnOp(.UnaryOperator("cos", cos))
        learnOp(.UnaryOperator("√", sqrt))
    }

    func pushOperand(operand: Double) {
        opStack.append(.Operand(operand))
    }

    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }

    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }

    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainder = ops
            let op = remainder.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainder)
            case .UnaryOperator(_, let operation):
                let (operand, remainder) = evaluate(remainder)
                if let operand = operand {
                    return (operation(operand), remainder)
                }
            case .BinaryOperator(_, let operation):
                let (opRight, remRight) = evaluate(remainder)
                let (opLeft, remLeft) = evaluate(remRight)
                if opLeft != nil && opRight != nil {
                    return (operation(opLeft!, opRight!), remLeft)
                }
            }
        }
        return (nil, ops)
    }
}
