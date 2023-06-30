//
//  ViewController.swift
//  ExInputView
//
//  Created by 김종권 on 2023/07/01.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxGesture

class ViewController: UIViewController, KeyboardWrapperable {
    private enum Metric {
        static let textViewHeight = UIScreen.main.bounds.height * 0.3
    }
    
    private let textView = UITextView().then {
        $0.backgroundColor = .lightGray.withAlphaComponent(0.1)
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        $0.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .lightGray
    }
    fileprivate let button = UIButton(type: .system).then {
        $0.backgroundColor = .green.withAlphaComponent(0.3)
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.setTitleColor(.systemBlue, for: [.normal, .highlighted])
    }
    
    fileprivate let textViewPlaceHolder = "텍스트를 입력하세요"
    let disposeBag = DisposeBag()
    
    var keyboardWrapperView = PassThroughView()
    var keyboardSafeAreaView = PassThroughView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        setupKeybaordWrapper()
    }
    
    private func setupUI() {
        textView.text = textViewPlaceHolder
        textView.delegate = self
        
        view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(Metric.textViewHeight)
        }
        
        keyboardSafeAreaView.addSubview(button)
        button.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(120)
        }
    }
    
    private func bind() {
        view.rx.tapGesture()
            .when(.ended)
            .bind(with: self) { ss, _ in
                ss.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

        let characterCount = newString.count
        guard characterCount <= 700 else { return false }
        return true
    }
}
