//
//  SVGPath.swift
//  UIComponents
//
//  아이콘 세트가 SVG `d` 경로 문자열로 정의되어 있어(components/iconography/Icon.jsx),
//  이를 그대로 SwiftUI Path로 변환하는 최소 SVG path 파서입니다.
//  M/m, L/l, H/h, V/v, C/c, S/s, Q/q, T/t, A/a, Z/z 명령을 지원합니다.
//

import SwiftUI

enum SVGPath {
    private enum Token {
        case command(Character)
        case number(CGFloat)
    }

    private static func tokenize(_ d: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(d)
        var i = 0
        let commandLetters = Set("MmLlHhVvCcSsQqTtAaZz")
        while i < chars.count {
            let c = chars[i]
            if c.isWhitespace || c == "," {
                i += 1
                continue
            }
            if commandLetters.contains(c) {
                tokens.append(.command(c))
                i += 1
                continue
            }
            var j = i
            var s = ""
            if chars[j] == "-" || chars[j] == "+" { s.append(chars[j]); j += 1 }
            var sawDot = false
            var sawDigit = false
            while j < chars.count {
                let cj = chars[j]
                if cj.isNumber {
                    s.append(cj); sawDigit = true; j += 1
                } else if cj == "." && !sawDot {
                    s.append(cj); sawDot = true; j += 1
                } else {
                    break
                }
            }
            if sawDigit, let val = Double(s) {
                tokens.append(.number(CGFloat(val)))
                i = j
            } else {
                i += 1
            }
        }
        return tokens
    }

    static func path(from d: String) -> Path {
        var path = Path()
        let tokens = tokenize(d)
        var idx = 0
        var current = CGPoint.zero
        var subpathStart = CGPoint.zero
        var lastCommand: Character = " "
        var lastCubicControl: CGPoint?
        var lastQuadControl: CGPoint?

        func nextNumber() -> CGFloat {
            guard idx < tokens.count, case .number(let v) = tokens[idx] else { return 0 }
            idx += 1
            return v
        }
        func hasNextNumber() -> Bool {
            if idx < tokens.count, case .number = tokens[idx] { return true }
            return false
        }

        while idx < tokens.count {
            guard case .command(let cmdChar) = tokens[idx] else {
                idx += 1
                continue
            }
            idx += 1
            let isRelative = cmdChar.isLowercase
            var upper = Character(cmdChar.uppercased())

            func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                isRelative ? CGPoint(x: current.x + x, y: current.y + y) : CGPoint(x: x, y: y)
            }

            var first = true
            repeat {
                switch upper {
                case "M":
                    let x = nextNumber(), y = nextNumber()
                    let p = point(x, y)
                    if first {
                        path.move(to: p)
                        subpathStart = p
                    } else {
                        path.addLine(to: p)
                    }
                    current = p
                    // M 뒤에 추가로 오는 좌표쌍은 암묵적으로 lineto로 취급합니다.
                    upper = "L"
                case "L":
                    let x = nextNumber(), y = nextNumber()
                    let p = point(x, y)
                    path.addLine(to: p)
                    current = p
                case "H":
                    let x = nextNumber()
                    let p = CGPoint(x: isRelative ? current.x + x : x, y: current.y)
                    path.addLine(to: p)
                    current = p
                case "V":
                    let y = nextNumber()
                    let p = CGPoint(x: current.x, y: isRelative ? current.y + y : y)
                    path.addLine(to: p)
                    current = p
                case "C":
                    let x1 = nextNumber(), y1 = nextNumber()
                    let x2 = nextNumber(), y2 = nextNumber()
                    let x = nextNumber(), y = nextNumber()
                    let c1 = point(x1, y1), c2 = point(x2, y2), p = point(x, y)
                    path.addCurve(to: p, control1: c1, control2: c2)
                    lastCubicControl = c2
                    current = p
                case "S":
                    let x2 = nextNumber(), y2 = nextNumber()
                    let x = nextNumber(), y = nextNumber()
                    let c2 = point(x2, y2), p = point(x, y)
                    let c1: CGPoint
                    if let last = lastCubicControl, "CcSs".contains(lastCommand) {
                        c1 = CGPoint(x: 2 * current.x - last.x, y: 2 * current.y - last.y)
                    } else {
                        c1 = current
                    }
                    path.addCurve(to: p, control1: c1, control2: c2)
                    lastCubicControl = c2
                    current = p
                case "Q":
                    let x1 = nextNumber(), y1 = nextNumber()
                    let x = nextNumber(), y = nextNumber()
                    let c1 = point(x1, y1), p = point(x, y)
                    path.addQuadCurve(to: p, control: c1)
                    lastQuadControl = c1
                    current = p
                case "T":
                    let x = nextNumber(), y = nextNumber()
                    let p = point(x, y)
                    let c1: CGPoint
                    if let last = lastQuadControl, "QqTt".contains(lastCommand) {
                        c1 = CGPoint(x: 2 * current.x - last.x, y: 2 * current.y - last.y)
                    } else {
                        c1 = current
                    }
                    path.addQuadCurve(to: p, control: c1)
                    lastQuadControl = c1
                    current = p
                case "A":
                    let rx = nextNumber(), ry = nextNumber()
                    let rot = nextNumber()
                    let largeArc = nextNumber() != 0
                    let sweep = nextNumber() != 0
                    let x = nextNumber(), y = nextNumber()
                    let p = point(x, y)
                    addArc(to: &path, from: current, to: p, rx: rx, ry: ry, xRotationDeg: rot, largeArc: largeArc, sweep: sweep)
                    current = p
                case "Z":
                    path.closeSubpath()
                    current = subpathStart
                default:
                    break
                }
                lastCommand = cmdChar
                first = false
            } while hasNextNumber()
        }
        return path
    }

    /// SVG 타원 호(A)를 3차 베지어 곡선들로 근사합니다. (SVG 스펙 부록 F.6.5 endpoint-to-center 파라미터화)
    private static func addArc(to path: inout Path, from p0: CGPoint, to p1: CGPoint, rx: CGFloat, ry: CGFloat, xRotationDeg: CGFloat, largeArc: Bool, sweep: Bool) {
        if rx == 0 || ry == 0 || p0 == p1 {
            path.addLine(to: p1)
            return
        }
        var rx = abs(rx), ry = abs(ry)
        let phi = xRotationDeg * .pi / 180
        let cosPhi = cos(phi), sinPhi = sin(phi)

        let dx2 = (p0.x - p1.x) / 2
        let dy2 = (p0.y - p1.y) / 2
        let x1p = cosPhi * dx2 + sinPhi * dy2
        let y1p = -sinPhi * dx2 + cosPhi * dy2

        let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
        if lambda > 1 {
            let s = sqrt(lambda)
            rx *= s
            ry *= s
        }

        let sign: CGFloat = (largeArc != sweep) ? 1 : -1
        let num = max(0, rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p)
        let den = rx * rx * y1p * y1p + ry * ry * x1p * x1p
        let coef = den == 0 ? 0 : sign * sqrt(num / den)
        let cxp = coef * (rx * y1p / ry)
        let cyp = coef * (-ry * x1p / rx)

        let cx = cosPhi * cxp - sinPhi * cyp + (p0.x + p1.x) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (p0.y + p1.y) / 2

        func angle(_ ux: CGFloat, _ uy: CGFloat, _ vx: CGFloat, _ vy: CGFloat) -> CGFloat {
            let dot = ux * vx + uy * vy
            let len = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
            var ang = acos(max(-1, min(1, dot / len)))
            if ux * vy - uy * vx < 0 { ang = -ang }
            return ang
        }

        let theta1 = angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry)
        var dTheta = angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
        if !sweep && dTheta > 0 { dTheta -= 2 * .pi }
        if sweep && dTheta < 0 { dTheta += 2 * .pi }

        let segments = max(1, Int(ceil(abs(dTheta) / (.pi / 2))))
        let delta = dTheta / CGFloat(segments)
        let t = 4.0 / 3.0 * tan(delta / 4)

        var theta = theta1
        var startPoint = p0
        for _ in 0..<segments {
            let theta2 = theta + delta
            let e1 = CGPoint(x: -sin(theta), y: cos(theta))
            let e2 = CGPoint(x: -sin(theta2), y: cos(theta2))

            func ellipsePoint(_ ang: CGFloat) -> CGPoint {
                let ex = cx + rx * cos(ang) * cosPhi - ry * sin(ang) * sinPhi
                let ey = cy + rx * cos(ang) * sinPhi + ry * sin(ang) * cosPhi
                return CGPoint(x: ex, y: ey)
            }

            let p1c = CGPoint(
                x: startPoint.x + t * rx * e1.x * cosPhi - t * ry * e1.y * sinPhi,
                y: startPoint.y + t * rx * e1.x * sinPhi + t * ry * e1.y * cosPhi
            )
            let endPoint = ellipsePoint(theta2)
            let p2c = CGPoint(
                x: endPoint.x - t * rx * e2.x * cosPhi + t * ry * e2.y * sinPhi,
                y: endPoint.y - t * rx * e2.x * sinPhi - t * ry * e2.y * cosPhi
            )

            path.addCurve(to: endPoint, control1: p1c, control2: p2c)

            startPoint = endPoint
            theta = theta2
        }
    }
}
