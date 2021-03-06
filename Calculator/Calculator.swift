import Foundation

class Calculator: Printable {
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case UnaryOperator(String, Double -> Double)
        case BinaryOperator(String, (Double, Double) -> Double, precedence: Int)

        var description: String {
            switch self {
            case .Operand(let operand):
                return Formatter.toString(operand) ?? "�"
            case .Variable(let symbol):
                return symbol
            case .UnaryOperator(let symbol, _):
                return symbol
            case .BinaryOperator(let symbol, _, _):
                return symbol
            }
        }

        var precedence: Int {
            switch self {
            case .BinaryOperator(_, _, let level):
                return level
            default:
                return Int.max
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
    // PropertyList
    var program: AnyObject {
        get {
            return opStack.map { $0.description }
        }
        set {
            reset()
            if let opSymbols = newValue as? [String] {
                for opSymbol in opSymbols {
                    if performOperation(opSymbol) {
                        continue
                    }
                    if let op = Formatter.toDouble(opSymbol) {
                        pushOperand(op)
                    } else {
                        pushOperand(opSymbol)
                    }
                }
            }
        }
    }

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(.BinaryOperator("×", *, precedence: 2))
        learnOp(.BinaryOperator("÷", /, precedence: 2))
        learnOp(.BinaryOperator("+", +, precedence: 1))
        learnOp(.BinaryOperator("−", -, precedence: 1))
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

    func performOperation(symbol: String) -> Bool {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            return true
        }
        return false
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
            case .BinaryOperator(_, let operation, _):
                let (opRight, remRight) = evaluate(remainder)
                let (opLeft, remLeft) = evaluate(remRight)
                if opLeft != nil && opRight != nil {
                    return (operation(opLeft!, opRight!), remLeft)
                }
            }
        }
        return (nil, ops)
    }

    private func describe(ops: [Op], precedence: Int = 0) -> (result: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainder = ops
            let op = remainder.removeLast()
            switch op {
            case .Operand:
                fallthrough
            case .Variable:
                // Shitty test runner does not expand "\(op)"
                return (op.description, remainder)
            case .UnaryOperator:
                let (operand, remainder) = describe(remainder)
                return ("\(op.description)(\(operand))", remainder)
            case .BinaryOperator:
                let (opRight, remRight) = describe(remainder, precedence: op.precedence)
                let (opLeft, remLeft) = describe(remRight, precedence: op.precedence)
                var description = "\(opLeft)\(op.description)\(opRight)"
                if precedence > op.precedence {
                    description = "(\(description))"
                }
                return (description, remLeft)
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

    func undo() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
}

struct Formatter {
    private static let format: NSNumberFormatter = {
        let format = NSNumberFormatter()
        format.numberStyle = .DecimalStyle
        format.notANumberSymbol = "Err"
        return format
    }()

    static var separator: String? {
        return format.decimalSeparator
    }

    static func toDouble(value: String?) -> Double? {
        return value == nil ? nil : format.numberFromString(value!)?.doubleValue
    }

    static func toString(value: Double?) -> String? {
        return value == nil ? nil : format.stringFromNumber(value!)
    }
}
