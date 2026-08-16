//
//  KoinModalStyle.swift
//  koin
//
//  Created by 홍기정 on 8/15/26.
//

import UIKit

struct KoinModalStyle {
    let mainTitle: TitleStyle
    let subTitle: TitleStyle
    let singleTitle: TitleStyle
    let leftButton: ButtonStyle
    let rightButton: ButtonStyle
    
    struct TitleStyle {
        let textColor: ColorAsset
        let font: FontAsset
        let fontSize: Int
    }
    
    struct ButtonStyle {
        let textColor: ColorAsset
        let font: FontAsset
        let fontSize: Int
        let backgroundColor: ColorAsset?
        let borderColor: ColorAsset?
        let borderWidth: CGFloat?
        let cornerRadius: CGFloat?
    
        init(
            textColor: ColorAsset,
            font: FontAsset,
            fontSize: Int
        ) {
            self.textColor = textColor
            self.font = font
            self.fontSize = fontSize
            self.backgroundColor = nil
            self.borderColor = nil
            self.borderWidth = nil
            self.cornerRadius = nil
        }
        
        init(
            textColor: ColorAsset,
            font: FontAsset,
            fontSize: Int,
            backgroundColor: ColorAsset,
            cornerRadius: CGFloat
        ) {
            self.textColor = textColor
            self.font = font
            self.fontSize = fontSize
            self.backgroundColor = backgroundColor
            self.borderColor = nil
            self.borderWidth = nil
            self.cornerRadius = cornerRadius
        }
        
        init(
            textColor: ColorAsset,
            font: FontAsset,
            fontSize: Int,
            borderColor: ColorAsset,
            borderWidth: CGFloat,
            cornerRadius: CGFloat
        ) {
            self.textColor = textColor
            self.font = font
            self.fontSize = fontSize
            self.backgroundColor = nil
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
        }
    }
}
