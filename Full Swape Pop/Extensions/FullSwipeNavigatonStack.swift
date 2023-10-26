//
//  FullSwapeNavigatonStack.swift
//  Full Swape Pop
//
//  Created by 笠井翔雲 on 2023/10/26.
//

import SwiftUI

struct FullSwipeNavigationStack<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var customGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.name = UUID().uuidString
        gesture.isEnabled = false
        return gesture
    }()
    
    var body: some View {
        NavigationStack {
            content
                .background {
                    AttachGestureView(gesture: $customGesture)
                }
        }
        .environment(\.popGestureID, customGesture.name)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(customGesture.name ?? "")), perform: { info in
            if let userInfo = info.userInfo, let status = userInfo["status"] as? Bool {
                customGesture.isEnabled = status
            }
        })
    }
}

fileprivate struct PopGestureIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var popGestureID: String? {
        get {
            return self[PopGestureIDKey.self]
        }
        set {
            self[PopGestureIDKey.self] = newValue
        }
    }
}

extension View {
    @ViewBuilder
    func enableFullSwipePop(_ isEnabled: Bool) -> some View {
        self.modifier(FullSwipeModifier(isEnabled: isEnabled))
    }
}

fileprivate struct FullSwipeModifier: ViewModifier {
    var isEnabled: Bool
    @Environment(\.popGestureID) private var gestureID

    func body(content: Content) -> some View {
        content
            .onChange(of: isEnabled) { newValue in
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: Notification.Name(gestureID), object: nil, userInfo: ["status": newValue])
            }
            .onDisappear {
                guard let gestureID = gestureID else { return }
                NotificationCenter.default.post(name: Notification.Name(gestureID), object: nil, userInfo: ["status": false])
            }
    }
}

fileprivate struct AttachGestureView: UIViewRepresentable {
    @Binding var gesture: UIPanGestureRecognizer
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let parentViewController = uiView.parentViewController, let navigationController = parentViewController.navigationController {
            if navigationController.view.gestureRecognizers?.first(where: { $0.name == gesture.name }) != nil {
                print("Already Attached")
            } else {
                navigationController.addFullSwipeGesture(gesture)
                print("Attached")
            }
        }
    }
}

fileprivate extension UINavigationController {
    func addFullSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        if let gestureRecognizer = interactivePopGestureRecognizer,
           let targets = gestureRecognizer.value(forKey: "targets") {
            gesture.setValue(targets, forKey: "targets")
        }
        view.addGestureRecognizer(gesture)
    }
}

fileprivate extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) {
            $0.next
        }.first(where: { $0 is UIViewController }) as? UIViewController
    }
}


struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
