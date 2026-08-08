//
//  DSIcon.swift
//  UIComponents
//
//  아무데나 디자인 시스템의 커스텀 라인 아이콘 세트입니다. (원본: components/iconography/Icon.jsx)
//  24×24 스트로크 그리드 기준이며, star/flame만 채움(filled)으로 렌더링됩니다.
//

import SwiftUI

enum DSIconElement {
    case path(String)
    case circle(cx: CGFloat, cy: CGFloat, r: CGFloat, alwaysFilled: Bool = false)
    case rect(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, rx: CGFloat = 0)

    var alwaysFilled: Bool {
        if case .circle(_, _, _, let filled) = self { return filled }
        return false
    }

    var path: Path {
        switch self {
        case .path(let d):
            return SVGPath.path(from: d)
        case .circle(let cx, let cy, let r, _):
            return Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        case .rect(let x, let y, let w, let h, let rx):
            return rx > 0
                ? Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: rx, style: .continuous)
                : Path(CGRect(x: x, y: y, width: w, height: h))
        }
    }
}

public enum DSIcon: String, CaseIterable, Sendable {
    // 시스템 세트
    case home, pin, passport, sprout, settings, target, compass, lock, flame
    case check, chevronRight, close, star, quote, car, backpack, clock, chat
    // 지역/뱃지 세트
    case ranking, tree, bridge, leaf, sparkles, cheese, train, wind, temple, baseball, fish

    var isFilled: Bool { self == .star || self == .flame }

    var elements: [DSIconElement] {
        switch self {
        case .home:
            return [.path("M4 12 12 4l8 8"), .path("M6 10.5V20h5v-5h2v5h5V10.5")]
        case .pin:
            return [.path("M12 21c4.2-4.6 7-8.4 7-11.5A7 7 0 1 0 5 9.5C5 12.6 7.8 16.4 12 21Z"), .circle(cx: 12, cy: 9.3, r: 2.6)]
        case .passport:
            return [.rect(x: 5, y: 3, w: 14, h: 18, rx: 2.5), .circle(cx: 12, cy: 10, r: 2.4), .path("M9 15.5h6")]
        case .sprout:
            return [
                .path("M12 21v-7.5"),
                .path("M12 13.5c0-4-3-6.2-7-6.2 0 4 3 6.9 7 6.2Z"),
                .path("M12 11.3c0-3.4 2.4-5.3 5.8-5.3 0 3.4-2.4 5.8-5.8 5.3Z"),
            ]
        case .settings:
            return [
                .circle(cx: 12, cy: 12, r: 3.2),
                .circle(cx: 12, cy: 12, r: 7),
                .path("M12 2.8v2.2M12 19v2.2M21.2 12H19M5 12H2.8M18.5 5.5l-1.6 1.6M7.1 16.9l-1.6 1.6M18.5 18.5l-1.6-1.6M7.1 7.1L5.5 5.5"),
            ]
        case .ranking:
            return [
                .path("M3 21h18"),
                .rect(x: 4.5, y: 13, w: 5, h: 8),
                .rect(x: 9.5, y: 8, w: 5, h: 13),
                .rect(x: 14.5, y: 15.5, w: 5, h: 5.5),
            ]
        case .target:
            return [
                .circle(cx: 12, cy: 12, r: 8.3),
                .circle(cx: 12, cy: 12, r: 4.6),
                .circle(cx: 12, cy: 12, r: 1, alwaysFilled: true),
            ]
        case .compass:
            return [.circle(cx: 12, cy: 12, r: 9), .path("M15.2 8.8l-2 5.2-5.2 2 2-5.2 5.2-2Z")]
        case .lock:
            return [.rect(x: 5, y: 10.5, w: 14, h: 9.5, rx: 2.2), .path("M7.8 10.5V8a4.2 4.2 0 0 1 8.4 0v2.5")]
        case .flame:
            return [.path("M12 2.5c1.2 3.4-2.6 4.6-2.6 8.4a2.6 2.6 0 0 0 5.2 0c0-.9-.3-1.6-.7-2.1.7 1.7 1.9 2.6 1.9 4.9A5.8 5.8 0 1 1 5 13.7c0-4.6 4.4-5.9 7-11.2Z")]
        case .check:
            return [.path("M5 12.5l4.5 4.5L19 7.5")]
        case .chevronRight:
            return [.path("M9 4.5l7.5 7.5L9 19.5")]
        case .close:
            return [.path("M6 6l12 12M18 6L6 18")]
        case .star:
            return [.path("M12 2.7l2.9 6 6.6.8-4.9 4.6 1.3 6.5L12 17.4l-5.9 3.2 1.3-6.5-4.9-4.6 6.6-.8Z")]
        case .quote:
            return [
                .path("M7 10.5c0-2.7 1.6-4.3 4.2-4.3v2.1c-1.4 0-2.1.8-2.1 2.2h2.1v4.3H7v-4.3Z"),
                .path("M14.6 10.5c0-2.7 1.6-4.3 4.2-4.3v2.1c-1.4 0-2.1.8-2.1 2.2h2.1v4.3h-4.2v-4.3Z"),
            ]
        case .car:
            return [
                .path("M4.5 15.5l1.3-4.4A2 2 0 0 1 7.7 9.6h8.6a2 2 0 0 1 1.9 1.5l1.3 4.4"),
                .rect(x: 3.2, y: 15.5, w: 17.6, h: 3.8, rx: 1.6),
                .circle(cx: 7.5, cy: 19.3, r: 1.3),
                .circle(cx: 16.5, cy: 19.3, r: 1.3),
            ]
        case .backpack:
            return [
                .path("M8.5 8.2V6.3a3.5 3.5 0 1 1 7 0v1.9"),
                .rect(x: 6, y: 8.2, w: 12, h: 12.3, rx: 2.6),
                .path("M9 11.8h6M9 15.2h6"),
            ]
        case .clock:
            return [.circle(cx: 12, cy: 12, r: 8.5), .path("M12 7.5V12l3.2 2")]
        case .chat:
            return [.path("M4.5 5.5h15v10.2H9.8l-3.6 3.3v-3.3H4.5Z")]
        case .tree:
            return [.path("M12 21v-5.3"), .path("M12 4l4 6h-2.4l3.4 5.6H7l3.4-5.6H8Z")]
        case .bridge:
            return [.path("M3 16c2-3 5-4.5 9-4.5s7 1.5 9 4.5"), .path("M6 16v3M18 16v3M12 11.5V16")]
        case .leaf:
            return [.path("M6 18C4 11 8 5 17 5c1 8-4 13-11 13Z"), .path("M8 16c2.5-3 5-5.5 9-9.5")]
        case .sparkles:
            return [
                .path("M12 4.5l1.2 3.6 3.6 1.2-3.6 1.2-1.2 3.6-1.2-3.6-3.6-1.2 3.6-1.2Z"),
                .path("M18.5 15l.7 2 2 .7-2 .7-.7 2-.7-2-2-.7 2-.7Z"),
            ]
        case .cheese:
            return [
                .path("M4 17.5 12 6l8 11.5Z"),
                .circle(cx: 12, cy: 14.5, r: 0.9, alwaysFilled: true),
                .circle(cx: 9.5, cy: 16.2, r: 0.7, alwaysFilled: true),
            ]
        case .train:
            return [
                .rect(x: 5, y: 6, w: 14, h: 10.5, rx: 2.4),
                .path("M5 11h14"),
                .circle(cx: 8.3, cy: 19, r: 1.1),
                .circle(cx: 15.7, cy: 19, r: 1.1),
            ]
        case .wind:
            return [
                .path("M3 8h11a2.5 2.5 0 1 0-2.2-3.7"),
                .path("M3 13h14.5a2.5 2.5 0 1 1-2.2 3.7"),
                .path("M3 18h8"),
            ]
        case .temple:
            return [.path("M4 20h16"), .path("M6 20v-6.5M18 20v-6.5"), .path("M4 13.5 12 4l8 9.5Z")]
        case .baseball:
            return [.circle(cx: 12, cy: 12, r: 8.5), .path("M6.5 6.5c2 1.6 2.8 3.7 2.8 5.5s-.8 3.9-2.8 5.5M17.5 6.5c-2 1.6-2.8 3.7-2.8 5.5s.8 3.9 2.8 5.5")]
        case .fish:
            return [
                .path("M3 12c3-4 8-5.5 12-3.5 2 1 3.5 2.3 6 1.5-1 2-1 3-.3 4.5-2.5 3.5-8.5 4-13.5.5"),
                .circle(cx: 7.5, cy: 11, r: 0.7, alwaysFilled: true),
            ]
        }
    }
}
