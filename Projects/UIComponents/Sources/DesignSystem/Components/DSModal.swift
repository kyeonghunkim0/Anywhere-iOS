//
//  DSModal.swift
//  UIComponents
//
//  원본: components/feedback/Modal.jsx
//

import SwiftUI

public struct DSModalAction: Identifiable {
    public let id = UUID()
    public let label: String
    public let isEmphasized: Bool
    public let action: () -> Void

    public init(label: String, isEmphasized: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.isEmphasized = isEmphasized
        self.action = action
    }
}

public struct DSModal: View {
    private let title: String
    private let message: String
    private let actions: [DSModalAction]
    private let onClose: (() -> Void)?

    public init(
        title: String,
        message: String,
        actions: [DSModalAction] = [],
        onClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actions = actions
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            DSColor.overlayScrim
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            card
                .padding(DSSpacing.s6)
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(DSTypography.font(DSTypography.Size.lg, weight: DSTypography.Weight.bold))
                .foregroundStyle(DSColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, DSSpacing.s2)

            Text(message)
                .font(DSTypography.font(DSTypography.Size.base))
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(
                    DSTypography.lineSpacing(
                        size: DSTypography.Size.base,
                        leading: DSTypography.Leading.relaxed
                    )
                )
                .padding(.bottom, DSSpacing.s6)

            VStack(spacing: DSSpacing.s2) {
                ForEach(actions) { action in
                    Button(action: action.action) {
                        Text(action.label)
                            .font(
                                DSTypography.font(
                                    DSTypography.Size.base,
                                    weight: action.isEmphasized
                                        ? DSTypography.Weight.bold
                                        : DSTypography.Weight.regular
                                )
                            )
                            .foregroundStyle(
                                action.isEmphasized ? DSColor.brandPrimary : DSColor.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.s3)
                            .overlay {
                                RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                                    .strokeBorder(DSColor.border, lineWidth: 1)
                            }
                    }
                    .buttonStyle(DSPressStyle())
                }
            }
        }
        .padding(DSSpacing.s6)
        .frame(maxWidth: 360)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl, style: .continuous))
        .overlay(alignment: .topTrailing) {
            if let onClose {
                Button(action: onClose) {
                    DSIconView(.close, size: 16, color: DSColor.sand400)
                }
                .buttonStyle(.plain)
                .padding(14)
            }
        }
        .dsShadow(DSShadow.xl2)
    }
}

public extension View {
    /// 화면 위에 디자인 시스템 모달을 띄웁니다.
    func dsModal(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        actions: [DSModalAction] = [],
        showsCloseButton: Bool = true
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                DSModal(
                    title: title,
                    message: message,
                    actions: actions,
                    onClose: showsCloseButton ? { isPresented.wrappedValue = false } : nil
                )
                .transition(.opacity)
            }
        }
        .animation(DSMotion.standard(), value: isPresented.wrappedValue)
    }
}

#Preview {
    DSModal(
        title: "여기로 떠날까요?",
        message: "충남 부여군 궁남지까지\n약 1시간 40분 걸려요.",
        actions: [
            .init(label: "좋아요, 갈게요", isEmphasized: true) {},
            .init(label: "다시 뽑기") {},
        ],
        onClose: {}
    )
    .background(DSColor.bgApp)
}
