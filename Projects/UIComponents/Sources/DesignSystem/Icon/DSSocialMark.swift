//
//  DSSocialMark.swift
//  UIComponents
//
//  소셜 로그인 버튼에 쓰이는 브랜드 마크. DSIcon은 단색 fill 하나만 표현할 수 있어
//  4색인 Google 로고는 별도로 둔다. Apple 로고는 SF Symbol(`applelogo`)로 이미
//  충분해 여기 넣지 않는다.
//

import SwiftUI

public struct DSGoogleMark: View {
    private let size: CGFloat

    public init(size: CGFloat = 20) {
        self.size = size
    }

    public var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 48
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            for (d, color) in Self.paths {
                context.fill(SVGPath.path(from: d).applying(transform), with: .color(color))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private static let paths: [(String, Color)] = [
        (
            "M45.1 24.5c0-1.6-.1-3.2-.4-4.7H24v8.9h11.8c-.5 2.8-2 5.1-4.4 6.7v5.5h7.1c4.1-3.8 6.6-9.4 6.6-16.4Z",
            Color(red: 0x42 / 255, green: 0x85 / 255, blue: 0xF4 / 255)
        ),
        (
            "M24 46c5.9 0 10.9-2 14.5-5.3l-7.1-5.5c-2 1.3-4.5 2.1-7.4 2.1-5.7 0-10.5-3.8-12.2-9H4.5v5.7C8.1 41.2 15.5 46 24 46Z",
            Color(red: 0x34 / 255, green: 0xA8 / 255, blue: 0x53 / 255)
        ),
        (
            "M11.8 28.3c-.4-1.3-.7-2.7-.7-4.3s.3-3 .7-4.3v-5.7H4.5A22 22 0 0 0 2 24c0 3.6.9 6.9 2.5 9.9l7.3-5.6Z",
            Color(red: 0xFB / 255, green: 0xBC / 255, blue: 0x05 / 255)
        ),
        (
            "M24 10.5c3.2 0 6.1 1.1 8.4 3.3l6.3-6.3C34.9 3.9 29.9 2 24 2 15.5 2 8.1 6.8 4.5 13.9l7.3 5.7c1.7-5.2 6.5-9.1 12.2-9.1Z",
            Color(red: 0xEA / 255, green: 0x43 / 255, blue: 0x35 / 255)
        ),
    ]
}

#Preview {
    DSGoogleMark(size: 40)
        .padding()
}
