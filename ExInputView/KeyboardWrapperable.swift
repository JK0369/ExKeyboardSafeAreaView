//
//  KeyboardWrapperable.swift
//  ExInputView
//
//  Created by 김종권 on 2023/07/01.
//

import UIKit
import SnapKit
import RxSwift

private struct AssociatedKeys {
    static var isEnabled = "isEnabled"
}

protocol KeyboardWrapperable {
    var keyboardWrapperView: PassThroughView { get }
    var keyboardSafeAreaView: PassThroughView { get }
    var disposeBag: DisposeBag { get }
    
    func setupKeybaordWrapper()
}

extension KeyboardWrapperable where Self: UIViewController {
    private var isEnabled: Bool {
        get {
            (objc_getAssociatedObject(self, &AssociatedKeys.isEnabled) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setupKeybaordWrapper() {
        guard !isEnabled else { return }
        isEnabled.toggle()

        setupLayout()
        observeKeyboardHeight()
    }
    
    private func setupLayout() {
        view.addSubview(keyboardWrapperView)
        view.addSubview(keyboardSafeAreaView)

        keyboardWrapperView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0).priority(.high)
        }

        keyboardSafeAreaView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(keyboardWrapperView.snp.top)
        }
    }
    
    private func observeKeyboardHeight() {
        Observable<(Bool, Notification)>
            .merge(
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                    .map { notification in (true, notification) },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                    .map { notification in (false, notification) }
            )
            .bind(with: self) { ss, tuple in
                let (isKeyboardUp, notification) = tuple
                let uesrInfo = notification.userInfo
                guard let endFrame = uesrInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                
                let endFrameMinY = endFrame.origin.y
                let shownKeyboardHeight = isKeyboardUp ? endFrame.height : 0
                
                ss.keyboardWrapperView.snp.updateConstraints {
                    $0.height.equalTo(shownKeyboardHeight).priority(.high)
                }
                UIView.transition(
                    with: ss.keyboardWrapperView,
                    duration: 0.25,
                    options: .init(rawValue: 458752),
                    animations: ss.view.layoutIfNeeded
                )
            }
            .disposed(by: disposeBag)
    }
}
