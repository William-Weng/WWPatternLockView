//
//  PatternLockCollectionView.swift
//  WWPatternLockView
//
//  Created by William.Weng on 2024/12/12.
//

import UIKit

// MARK: - 自訂解鎖功能的UICollectionView
final class PatternLockCollectionView: UICollectionView {
    
    weak var lockCollectionViewDelegate: PatternLockCollectionViewDelegate?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchPoint = touches.first?.location(in: self) else { return }
        
        if let indexPath = self.indexPathForItem(at: touchPoint) {
            lockCollectionViewDelegate?.selectedItem(at: indexPath); return
        }
        
        lockCollectionViewDelegate?.move(to: touchPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lockCollectionViewDelegate?.moveEnded()
    }
    
    deinit {
        lockCollectionViewDelegate = nil
    }
}
