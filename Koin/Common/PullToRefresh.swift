import UIKit
import SwiftUI

public extension View {
    func tagging(_ tag: Int = 1192296,
                 window: UIWindow? = UIApplication.shared.keyWindow,
                 onRetrieve: @escaping ((_ taggedView: UIView?) -> Void) = { _ in }) -> some View {
        modifier(TagModifier(tag: tag)).onAppear {
            DispatchQueue.main.async {
                let rootView = window?.rootViewController?.view
                guard let tagView = rootView?.viewWithTag(tag) as? TagView else { return }
                onRetrieve(tagView.target)
            }
        }
    }
}

struct TagModifier: ViewModifier {
    let tag: Int
    
    func body(content: Content) -> some View {
        ZStack {
            content
            Tag(tag: tag).frame(width: 0, height: 0)
        }
    }
}

struct Tag: UIViewRepresentable {
    typealias UIViewType = UIView
    let tag: Int
    
    func makeUIView(context: UIViewRepresentableContext<Tag>) -> UIView {
        return TagView()
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Tag>) {
        uiView.tag = tag
        uiView.frame = .zero
        uiView.isUserInteractionEnabled = false
        uiView.backgroundColor = .clear
    }
}

/// Musi initialize from SwiftUI.
class TagView: UIView {
    var target: UIView? {
        // UIViewRepresentable give adaptor view.
        guard let adaptor = self.superview else { return nil }
        // Access parent view.
        guard let parent = adaptor.superview else { return nil }
        // Search top view in zindex.
        guard let target = parent.subviews.first else { return nil }
        
        return target
    }
}

public struct Token: Identifiable {
    public let id: Int
}

public extension List {
    func onPull(perform: @escaping () -> Void, isLoading: Bool) -> some View {
        onPull(perform: perform, isLoading: isLoading, token: Token(id: 1))
    }
    
    func onPull<T: Identifiable>(perform: @escaping () -> Void, isLoading: Bool, token: T) -> some View where T.ID == Int {
        
        // run in body calculation
        if isLoading {
            NotificationCenter.default.post(name: .beginRefreshing, object: nil, userInfo: ["id" : token.id])
        } else {
            NotificationCenter.default.post(name: .endRefreshing, object: nil, userInfo: ["id" : token.id])
        }
        
        return tagging(token.id) { (target) in
            guard let managerBox = target else { return }
            guard let tableViewWrapper = managerBox.subviews.first else { return }
            guard let tableView = tableViewWrapper.subviews.first as? UITableView else { return }
            if tableView.refreshControlHandler == nil && tableView.refreshControl == nil {
                let refreshControl = UIRefreshControl()
                let handler = PullToRefreshHandler(refreshControl: refreshControl, id: token.id)
                handler.onPull = perform
                tableView.refreshControlHandler = handler
                tableView.refreshControl = refreshControl
                refreshControl.endRefreshing()
            }
        }
    }
}

extension Notification.Name {
    static var beginRefreshing: Notification.Name {
        Notification.Name(rawValue: "com.noppe.refreshUI.beginRefreshing")
    }
    static var endRefreshing: Notification.Name {
        Notification.Name(rawValue: "com.noppe.refreshUI.endRefreshing")
    }
}

internal class PullToRefreshHandler: NSObject {
    weak var refreshControl: UIRefreshControl? = nil
    var onPull: (() -> Void)? = nil
    let id: Int
    
    init(refreshControl: UIRefreshControl, id: Int) {
        self.id = id
        super.init()
        self.refreshControl = refreshControl
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(PullToRefreshHandler.beginRefreshing), name: .beginRefreshing, object: nil)
        nc.addObserver(self, selector: #selector(PullToRefreshHandler.endRefreshing), name: .endRefreshing, object: nil)
        refreshControl.addTarget(self, action: #selector(PullToRefreshHandler.valueChanged), for: .valueChanged)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func valueChanged(_ sender: UIRefreshControl) {
        onPull?()
    }
    
    @objc func beginRefreshing(_ notification: Notification) {
        guard let id = notification.userInfo?["id"] as? Int else { return }
        guard self.id == id else { return }
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl?.beginRefreshing()
        }
    }
    
    @objc func endRefreshing(_ notification: Notification) {
        guard let id = notification.userInfo?["id"] as? Int else { return }
        guard self.id == id else { return }
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
}

var StoredPropertyKey: UInt8 = 0

extension UITableView {
    var refreshControlHandler: PullToRefreshHandler? {
        get {
            guard let object = objc_getAssociatedObject(self, &StoredPropertyKey) as? PullToRefreshHandler else {
                return nil
            }
            return object
        }
        set {
            objc_setAssociatedObject(self, &StoredPropertyKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
