//
//  CancelableImage.swift
//  koin
//
//  Created by 홍기정 on 10/17/26.
//

import SwiftUI

struct CancelableImage: View {

    struct XButtonLayout {
        let width: CGFloat = 20
        let trailingInset: CGFloat = 12
        let topInset: CGFloat
        let bottomInset: CGFloat
        
        init(
            topInset: CGFloat,
            bottomInset: CGFloat
        ) {
            self.topInset = topInset
            self.bottomInset = bottomInset
        }
    }
    
    // MARK: - Properties
    private let imageAsset: ImageAsset
    private let xButtonLayout: XButtonLayout
    private let onXButtonTapped: () -> Void
    private let onImageTapped: () -> Void
    
    // MARK: - Initializer
    init(
        imageAsset: ImageAsset,
        xButtonLayout: XButtonLayout,
        onXButtonTapped: @escaping () -> Void = {},
        onImageTapped: @escaping () -> Void = {}
    ) {
        self.imageAsset = imageAsset
        self.xButtonLayout = xButtonLayout
        self.onXButtonTapped = onXButtonTapped
        self.onImageTapped = onImageTapped
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: onImageTapped) {
            Image.appImage(asset: imageAsset)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            Button(action: onXButtonTapped) {
                Color.clear
                    .frame(width: xButtonLayout.width)
                    .frame(maxHeight: .infinity)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .padding(.top, xButtonLayout.topInset)
            .padding(.trailing, xButtonLayout.trailingInset)
            .padding(.bottom, xButtonLayout.bottomInset)
        }
    }
}
