//
//  CircleCell.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

struct CircleCell: View {
    let viewModel: CircleCellViewModel
    
    init(viewModel: CircleCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                WebImage(url: URL(string: self.viewModel.backgroudImageUrl))
                    .placeholder {
                        Rectangle().foregroundColor(Color("light_navy"))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 111, maxHeight: 111, alignment: .center)
                }
                .resizable()
                .indicator(.activity)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 111, maxHeight: 111, alignment: .center)
                
                VStack {
                    WebImage(url: URL(string: self.viewModel.logoImageUrl))
                        .placeholder {
                            Circle().foregroundColor(Color("warm_grey"))
                                .frame(minWidth: 72, maxWidth: 72, minHeight: 72, maxHeight: 72, alignment: .center)
                    }
                    .resizable()
                        
                    .indicator(.activity)
                        
                    .frame(minWidth: 72, maxWidth: 72, minHeight: 72, maxHeight: 72, alignment: .center)
                    .clipShape(Circle())
                    
                }
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("store_menu_border"), lineWidth: 1))
                    
                .offset(y: -36)
                .padding(.bottom, -36)
                
                Text(self.viewModel.title)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .padding(.bottom, 4)
                Text(self.viewModel.content)
                    .font(.system(size: 13))
                    .fontWeight(.regular)
                    .foregroundColor(Color("warm_grey"))
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 224, maxHeight: 224, alignment: .center)
            .border(Color("store_menu_border"))
            NavigationLink(destination: CircleDetailView(viewModel: CircleDetailViewModel(id: self.viewModel.id)).navigationBarTitle(self.viewModel.title)) {
            EmptyView()
        }.buttonStyle(PlainButtonStyle())
                .frame(width: 0)
                .opacity(0)
        }
    }
}

struct CircleCell_Previews: PreviewProvider {
    
    static var previews: some View {
        return CircleCell(viewModel: CircleCellViewModel(item: CircleData(background_img_url: nil, category: "", id: 0, introduce_url: nil, line_description: "line Description", location: nil, logo_url: nil, major_business: nil, name: "test", professor: nil)))
    }
}
