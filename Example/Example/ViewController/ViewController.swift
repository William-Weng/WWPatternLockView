//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/12/12.
//

import UIKit
import WWPrint
import WWPatternLockView

@IBDesignable
final class MyPatternLockView: WWPatternLockView {}

// MARK: - ViewController
final class ViewController: UIViewController {
    
    @IBOutlet weak var patternLockView: MyPatternLockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patternLockView.delegate = self
    }
}

// MARK: - 小工具
extension ViewController: WWPatternLockViewDelegate {
    
    func patternLockView(_ patternLockView: WWPatternLockView, didSelected password: [Int]) {
        wwPrint(password)
    }
    
    func patternLockView(_ patternLockView: WWPatternLockView, didFinished password: [Int]) {
        wwPrint(password)
    }
}
