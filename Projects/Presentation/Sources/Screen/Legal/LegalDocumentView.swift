//
//  LegalDocumentView.swift
//  Presentation
//
//  원본: Prototype.dc.html의 isDoc 화면.
//

import SwiftUI
import UIComponents

struct LegalDocumentView: View {
    private let document: LegalDocument
    private let onClose: () -> Void

    init(document: LegalDocument, onClose: @escaping () -> Void = {}) {
        self.document = document
        self.onClose = onClose
    }

    var body: some View {
        VStack(spacing: 0) {
            BackBar(title: document.title, onBack: onClose)
                .padding(.bottom, 14)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(DSColor.border).frame(height: 1)
                }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(document.title)
                        .font(DSTypography.font(30, weight: DSTypography.Weight.extrabold))
                        .foregroundStyle(DSColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(document.meta)
                        .font(DSTypography.font(DSTypography.Size.sm, weight: DSTypography.Weight.semibold))
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, 12)

                    Text(document.intro)
                        .font(DSTypography.font(DSTypography.Size.base, weight: DSTypography.Weight.regular))
                        .foregroundStyle(DSColor.textSecondary)
                        .lineSpacing(DSTypography.lineSpacing(size: DSTypography.Size.base, leading: 1.7))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 26) {
                        ForEach(document.sections) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.heading)
                                    .font(DSTypography.font(DSTypography.Size.md, weight: DSTypography.Weight.extrabold))
                                    .foregroundStyle(DSColor.textPrimary)

                                Text(section.body)
                                    .font(DSTypography.font(14, weight: DSTypography.Weight.regular))
                                    .foregroundStyle(DSColor.textSecondary)
                                    .lineSpacing(DSTypography.lineSpacing(size: 14, leading: 1.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 28)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.s6)
                .padding(.top, 28)
                .padding(.bottom, 36)
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}
