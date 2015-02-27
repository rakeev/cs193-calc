import Foundation

class Calculator: Printable {
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case UnaryOperator(String, Double -> Double)
        case BinaryOperator(String, (Double, Double) -> Double)

        var description: String {
            switch self {
            case .Operand(let operand):
                let format = NSNumberFormatter()
                format.numberStyle = NSNumberFormatterStyle.DecimalStyle
                return format.stringFromNumber(operand) ?? "�"
            case .Variable(let symbol):
                return symbol
            case .UnaryOperator(let symbol, _):
                return symbol
            case .BinaryOperator(let symbol, _):
                return symbol
            }
        }
    }

    private var opStack = [Op]()
    private var knownOps = [String: Op]()
    private var variables = [String: Double]()
    private var constants = ["π": M_PI]
    var description: String {
        var result = [String]()
        var desc: String
        var ops = opStack
        while !ops.isEmpty {
            (desc, ops) = describe(ops)
            result.insert(desc, atIndex: result.startIndex)
        }
        return ",".join(result)
    }

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
        learnOp(.UnaryOperator("±", -))
    }

    func getVariable(symbol: String) -> Double? {
        return constants[symbol] ?? variables[symbol]
    }

    func setVariable(symbol: String, value: Double) {
        variables[symbol] = value
    }

    func pushOperand(operand: Double) {
        opStack.append(.Operand(operand))
    }

    func pushOperand(symbol: String) {
        opStack.append(.Variable(symbol))
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
            case .Variable(let symbol):
                return (getVariable(symbol), remainder)
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

    private func describe(ops: [Op]) -> (result: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainder = ops
            let op = remainder.removeLast()
            switch op {
            case .Operand:
                fallthrough
            case .Variable:
                return ("\(op)", remainder)
            case .UnaryOperator:
                let (operand, remainder) = describe(remainder)
                return ("\(op)(\(operand))", remainder)
            case .BinaryOperator:
                let (opRight, remRight) = describe(remainder)
                let (opLeft, remLeft) = describe(remRight)
                return ("(\(opLeft)\(op)\(opRight))", remLeft)
            }
        }
        return ("?", ops)
    }

    func clearVariables() {
        variables.removeAll()
    }

    func reset() {
        opStack.removeAll()
    }
}
