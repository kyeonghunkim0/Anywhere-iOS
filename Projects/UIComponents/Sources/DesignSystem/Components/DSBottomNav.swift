//
//  DSBottomNav.swift
//  UIComponents
//
//  원본: components/navigation/BottomNav.jsx
//

import SwiftUI

public struct DSBottomNavItem: Identifiable, Sendable {
    public let id: String
    public let icon: DSIcon
    public let label: String

    public init(id: String, icon: DSIcon, label: String) {
        self.id = id
        self.icon = icon
        self.label = label
    }
}

public struct DSBottomNav: View {
    private let items: [DSBottomNavItem]
    @Binding private var selection: String

    public init(items: [DSBottomNavItem], selection: Binding<String>) {
        self.items = items
        self._selection = selection
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(items) { item in
                let isActive = item.id == selection
                Button {
                    withAnimation(DSMotion.standard(duration: DSMotion.fast)) {
                        selection = item.id
                    }
                } label: {
                    VStack(spacing: DSSpacing.s1) {
                        DSIconView(item.icon, size: 20, color: tint(isActive: isActive))
                        Text(item.label)
                            .font(DSTypography.font(DSTypography.Size.xs2, weight: DSTypography.Weight.bold))
                            .foregroundStyle(tint(isActive: isActive))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, DSSpacing.s4)
        .padding(.horizontal, DSSpacing.s2)
        .padding(.bottom, DSSpacing.s8)
        .background {
            DSColor.surface.opacity(0.92)
                .background(.ultraThinMaterial)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(DSColor.border)
                .frame(height: 1)
        }
        .dsShadow(DSShadow.nav)
    }

    private func tint(isActive: Bool) -> Color {
        isActive ? DSColor.brandAccent : DSColor.sand400
    }
}

#Preview {
    @Previewable @State var tab = "home"

    return VStack {
        Spacer()
        DSBottomNav(
            items: [
                .init(id: "home", icon: .home, label: "홈"),
                .init(id: "match", icon: .target, label: "매칭"),
                .init(id: "passport", icon: .passport, label: "여권"),
                .init(id: "ranking", icon: .ranking, label: "랭킹"),
                .init(id: "settings", icon: .settings, label: "설정"),
            ],
            selection: $tab
        )
    }
    .background(DSColor.bgApp)
    .ignoresSafeArea(edges: .bottom)
}
