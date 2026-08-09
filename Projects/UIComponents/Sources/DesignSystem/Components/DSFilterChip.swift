//
//  DSFilterChip.swift
//  UIComponents
//
//  원본: components/core/FilterChip.jsx
//

import SwiftUI

public struct DSFilterChip: View {
    private let title: String
    private let icon: DSIcon?
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: DSIcon? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    DSIconView(icon, size: 14, color: foreground)
                }
                Text(title)
                    .font(DSTypography.font(DSTypography.Size.xs, weight: DSTypography.Weight.bold))
                    .fixedSize()
            }
            .foregroundStyle(foreground)
            .padding(.vertical, DSSpacing.s2)
            .padding(.horizontal, DSSpacing.s4)
            .background(isSelected ? DSColor.green50 : DSColor.surface)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected ? DSColor.brandPrimary : DSColor.border,
                        lineWidth: 1
                    )
            }
            .dsShadow(DSShadow.sm)
        }
        .buttonStyle(DSPressStyle())
    }

    private var foreground: Color {
        isSelected ? DSColor.brandPrimaryDark : DSColor.sand600
    }
}

#Preview {
    @Previewable @State var selected = "1박 2일"
    let options: [(String, DSIcon)] = [
        ("당일치기", .clock),
        ("1박 2일", .backpack),
        ("2박 이상", .car),
    ]

    return HStack(spacing: DSSpacing.s2) {
        ForEach(options, id: \.0) { option in
            DSFilterChip(option.0, icon: option.1, isSelected: selected == option.0) {
                selected = option.0
            }
        }
    }
    .padding(DSSpacing.s5)
    .background(DSColor.bgApp)
}
