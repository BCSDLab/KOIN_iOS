//
//  CommonFunction.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/17.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import CryptoKit
import CryptoTokenKit
import Foundation
import Combine
import PKHUD

extension String {
    func getArrayAfterRegex(regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                    range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{4})(\\d{3})", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

extension AnyTransition {
    static var tabButtonAction: AnyTransition {
        let transition = AnyTransition.scale(scale: 0.75)
        return transition
    }
}

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
    var NotchTopHeight: CGFloat {
        let top = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        return top
    }
    
    var NotchBottomHeight: CGFloat {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom
    }
}

extension UINavigationController {
    
    func clear() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.removeFromSuperview()
        view.addSubview(statusBarView)
    }
    
}

extension UIApplication {
    var statusBarUIView: UIView? {
        
        if #available(iOS 13.0, *) {
            let tag = 3848245
            
            let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999
                
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
            
        } else {
            
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}



struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            VStack{
                TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0xd2dae2))
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal)
                    .background(Color.white)
            }
        }
    }
}


struct TextWithAttributedString: UIViewRepresentable {
    var attributedString: NSMutableAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.init(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.autoresizesSubviews = true
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<TextWithAttributedString>) {
        uiView.attributedText = attributedString
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
    func border(width: CGFloat, edge: Edge, color: Color) -> some View {
        ZStack {
            self
            EdgeBorder(width: width, edge: edge).foregroundColor(color)
        }
    }
    func fillParent(alignment: Alignment = .center) -> some View {
        self
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: alignment
        )
    }
}

func checkRegex(target: String, pattern: String) -> Bool {

    do {
        print(target)
        print(pattern)
        let range = NSRange(location: 0, length: target.utf16.count)
        let regex = try NSRegularExpression(pattern: pattern)
        let filtered = regex.matches(in: target, options: [], range: range)
        
        if (filtered.isEmpty) {
            return false
        } else {
            return true
        }
    } catch(let error) {
        print(error)
        return false
    }
    return false
}

struct GridView<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int) -> Content
    
    var body: some View {
        VStack(alignment:.center,spacing: 1) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(alignment:.center,spacing: 1) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(3*row + column)
                    }
                }
            }
        }
    }
    
    //컨텐츠 클로저
    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

struct EdgeBorder: Shape {
    
    var width: CGFloat
    var edge: Edge
    
    func path(in rect: CGRect) -> Path {
        var x: CGFloat {
            switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
            }
        }
        
        var y: CGFloat {
            switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
            }
        }
        
        var w: CGFloat {
            switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
            }
        }
        
        var h: CGFloat {
            switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
            }
        }
        
        return Path( CGRect(x: x, y: y, width: w, height: h) )
    }
}

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height
                
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

func prepare_project() {
    let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
    let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    yourLabel.center = CGPoint(x: uiview.frame.size.width  / 2,
                               y: uiview.frame.size.height / 2)
    yourLabel.textAlignment = .center
    
    yourLabel.text = "서비스 준비중입니다."
    uiview.addSubview(yourLabel)
    PKHUD.sharedHUD.contentView = uiview
    PKHUD.sharedHUD.show()
    PKHUD.sharedHUD.hide(afterDelay: 1.0)
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
    
}
