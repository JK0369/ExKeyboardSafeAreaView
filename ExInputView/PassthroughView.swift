//
//  PassthroughView.swift
//  ExInputView
//
//  Created by 김종권 on 2023/07/01.
//

import UIKit

class PassThroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
}
