//
//  PatternLockCollectionViewDelegate.swift
//  WWPatternLockView
//
//  Created by William.Weng on 2024/12/12.
//

import Foundation

/// WWPatternLockViewDelegate
public protocol WWPatternLockViewDelegate: AnyObject {
    
    func patternLockView(_ patternLockView: WWPatternLockView, didSelected password: [Int])     /// 選到的密碼
    func patternLockView(_ patternLockView: WWPatternLockView, didFinished password: [Int])     /// 最後選到的密碼
}

/// PatternLockCollectionViewDelegate
protocol PatternLockCollectionViewDelegate: AnyObject {
    
    func selectedItem(at indexPath: IndexPath)      /// 選到Item時的反應
    func move(to point: CGPoint)                    /// 手指滑動時的反應
    func moveEnded()                                /// 手指滑動完成後的反應
}
