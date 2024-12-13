//
//  WWPatternLockView.swift
//  WWPatternLockView
//
//  Created by William.Weng on 2024/12/12.
//

import UIKit

@IBDesignable
open class WWPatternLockView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var patternLockCollectionView: PatternLockCollectionView!
    
    public weak var delegate: WWPatternLockViewDelegate?
    
    private let cellIdentifier = "PatternLockCell"          /* Cell的名字 */
    
    @IBInspectable var lockRowCount: Int = 3                /* Cell的數量 */
    @IBInspectable var moveLineColor: UIColor = .green      /* 移動時線的顏色 */
    @IBInspectable var lockLineColor: UIColor = .red        /* 選好後線的顏色 */
    @IBInspectable var selectedColor: UIColor = .white      /* 未選到時框的顏色 */
    @IBInspectable var unselectedColor: UIColor = .green    /* 選到後的框的顏色 */
    
    private var lineLayers = [CAShapeLayer]()               /* 畫在View上的Layer */
    private var moveLayer: CAShapeLayer?                    /* 跟著手指移動的Layer */
    private var currentPoint: CGPoint?                      /* 目前滑到的最後一個點 */
    private var selectedPassword: [Int] = []                /* 當前畫出的密碼 */
    private var _selectedPassword: [Int] = []               /* 上一次畫出的密碼 */

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initSetting()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetting()
    }
        
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initSetting()
        setting(lockRowCount: lockRowCount, moveLineColor: moveLineColor, lockLineColor: lockLineColor, selectedColor: selectedColor, unselectedColor: unselectedColor)
    }
    
    deinit {
        delegate = nil
    }
}

extension WWPatternLockView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {}

// MARK: - 公開函式
public extension WWPatternLockView {
        
    /// [相關數值設定](https://medium.com/jeremy-xue-s-blog/swift-玩玩-手勢-圖形解鎖-gesture-password-6863654b3f8b)
    /// - Parameters:
    ///   - lockRowCount: [列的數量](https://tympanix.github.io/pattern-lock-js/)
    ///   - moveLineColor: [移動時線的顏色](https://arstechnica.com/information-technology/2015/08/new-data-uncovers-the-surprising-predictability-of-android-lock-patterns/)
    ///   - lockLineColor: 選好後線的顏色
    ///   - selectedColor: 未選到時框的顏色
    ///   - unselectedColor: 選到後的框的顏色
    func setting(lockRowCount: Int, moveLineColor: UIColor = .green, lockLineColor: UIColor = .green, selectedColor: UIColor = .green, unselectedColor: UIColor = .white) {
        self.lockRowCount = lockRowCount
        self.moveLineColor = moveLineColor
        self.lockLineColor = lockLineColor
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.patternLockCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
public extension WWPatternLockView {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lockCellCount(with: lockRowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return lockCell(with: collectionView, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
public extension WWPatternLockView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return lockCellSize(with: collectionView.bounds.width, for: lockRowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lockCellWidth(with: collectionView.bounds.width, for: lockRowCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lockCellWidth(with: collectionView.bounds.width, for: lockRowCount)
    }
}

// MARK: - LockCollectionViewDelegate
extension WWPatternLockView: PatternLockCollectionViewDelegate {
    
    func selectedItem(at indexPath: IndexPath) {
        appendPassword(at: indexPath)
    }
    
    func move(to point: CGPoint) {
        drawLockLayerForMove(to: point)
    }
    
    func moveEnded() {
        moveEndedAction()
    }
}

// MARK: - 小工具
private extension WWPatternLockView {
    
    /// [初始化設定](https://tympanix.github.io/pattern-lock-js/)
    func initSetting() {
        initViewFromXib()
        initLockCollectionViewSetting()
    }
    
    /// 初始化CollectionView
    func initLockCollectionViewSetting() {
        patternLockCollectionView.delegate = self
        patternLockCollectionView.dataSource = self
        patternLockCollectionView.lockCollectionViewDelegate = self
        patternLockCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    /// 讀取Nib畫面 => 加到View上面
    func initViewFromXib() {
        
        let bundle = Bundle.module
        let name = String(describing: WWPatternLockView.self)
        
        bundle.loadNibNamed(name, owner: self, options: nil)
        contentView.frame = bounds
        
        addSubview(contentView)
    }
}

// MARK: - Cell相關
private extension WWPatternLockView {
    
    /// 圖形鎖的數量 (3 x 3)
    /// - Parameter row: Int
    /// - Returns: Int
    func lockCellCount(with row: Int) -> Int {
        return row * row
    }
    
    /// 圖形鎖的外觀 (圓形的)
    /// - Parameters:
    ///   - collectionView: UICollectionView
    ///   - indexPath: IndexPath
    /// - Returns: UICollectionViewCell
    func lockCell(with collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        
        let lockCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        lockCell.tag = indexPath.row
        lockCell.layer.cornerRadius = lockCell.bounds.height / 2
        lockCell.layer.borderWidth = 3
        lockCell.layer.borderColor = lockCellBorderColor(for: indexPath)
        
        return lockCell
    }
    
    /// 圖形鎖的平均寬度 (取整數)
    /// - Parameters:
    ///   - width: 總寬度
    ///   - row: row
    /// - Returns: CGFloat
    func lockCellWidth(with width: CGFloat, for row: Int) -> CGFloat {
        let cellWidth = width / CGFloat(row * 2 - 1)
        return CGFloat(Int(cellWidth))
    }
    
    /// 圖形鎖的平均大小 (正方形)
    /// - Parameters:
    ///   - width: 總寬度
    ///   - row: Int
    /// - Returns: CGSize
    func lockCellSize(with width: CGFloat, for row: Int) -> CGSize {
        let cellWidth = lockCellWidth(with: width, for: row)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - 畫線移動相關
private extension WWPatternLockView {
    
    /// 畫圖形鎖的線 (移動時)
    /// - Parameter point: CGPoint
    func drawLockLayerForMove(to point: CGPoint) {
        
        guard let currentPoint = currentPoint else { return }

        let layerPath = lockShapeLayerPath(from: currentPoint, to: point)
                
        if (moveLayer == nil) {
            moveLayer = lockShapeLayerMaker(for: layerPath, color: .green)
            patternLockCollectionView.layer.addSublayer(moveLayer!)
            return
        }
        
        moveLayerSetting(for: layerPath, color: moveLineColor)
    }
    
    /// 記錄Password的值 (畫線 / 不重複)
    /// - Parameter indexPath: IndexPath
    func appendPassword(at indexPath: IndexPath) {
        
        guard !selectedPassword.contains(indexPath.row),
              let lockCell = patternLockCollectionView.cellForItem(at: indexPath)
        else {
            return
        }
        
        selectedPassword.append(indexPath.row)
        drawLockLayerForSelected(to: lockCell.center)
        
        moveLayer?.removeFromSuperlayer()
        moveLayer = nil
        
        patternLockCollectionView.reloadItems(at: [indexPath])
        
        if (_selectedPassword != selectedPassword) {
            _selectedPassword = selectedPassword
            delegate?.patternLockView(self, didSelected: selectedPassword)
        }
    }
    
    /// 畫線完的處理
    func moveEndedAction() {
        recordFinalPassword()
        clearAllData()
    }
}

// MARK: - 小工具
private extension WWPatternLockView {

    /// 圖形鎖的外框顏色 (選到的 / 沒選到)
    /// - Parameter indexPath: IndexPath
    /// - Returns: CGColor
    func lockCellBorderColor(for indexPath: IndexPath) -> CGColor {
        let cellBorderColor = selectedPassword.contains(indexPath.row) ? UIColor.green.cgColor : UIColor.white.cgColor
        return cellBorderColor
    }
    
    /// 畫線的路徑
    /// - Parameters:
    ///   - point1: CGPoint
    ///   - point2: CGPoint
    /// - Returns: UIBezierPath
    func lockShapeLayerPath(from point1: CGPoint, to point2: CGPoint) -> UIBezierPath {
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: point1)
        bezierPath.addLine(to: point2)
        
        return bezierPath
    }
    
    /// 清除所有資料 (Layer / Password)
    func clearAllData() {
        
        lineLayers.forEach { $0.removeFromSuperlayer() }
        moveLayer?.removeFromSuperlayer()
        
        lineLayers.removeAll()
        selectedPassword.removeAll()
        
        moveLayer = nil
        currentPoint = nil
        
        patternLockCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    /// 設定畫線的Layer (有舊的就用舊的，不然就產生新的)
    /// - Parameters:
    ///   - layer: CAShapeLayer?
    ///   - path: UIBezierPath
    ///   - color: UIColor
    /// - Returns: CAShapeLayer
    func lockLayerSetting(_ layer: CAShapeLayer? = nil, for path: UIBezierPath, color: UIColor) -> CAShapeLayer {
        
        let lockLayer = (layer != nil) ? layer! : CAShapeLayer()
        
        lockLayer.frame = patternLockCollectionView.bounds
        lockLayer.position = patternLockCollectionView.center
        lockLayer.fillColor = nil
        lockLayer.lineWidth = 3
        lockLayer.strokeColor = color.cgColor
        lockLayer.lineCap = .round
        lockLayer.path = path.cgPath
        
        return lockLayer
    }
    
    /// 畫圖形鎖的線 (完成時)
    /// - Parameter point: CGPoint
    func drawLockLayerForSelected(to point: CGPoint) {
        
        if let _currentPoint = currentPoint {
            
            let layerPath = lockShapeLayerPath(from: _currentPoint, to: point)
            let lockShapeLayer = lockShapeLayerMaker(for: layerPath, color: lockLineColor)
            
            lineLayers.append(lockShapeLayer)
            patternLockCollectionView.layer.addSublayer(lockShapeLayer)
        }

        currentPoint = point
    }
    
    /// 產生畫線的Layer
    func lockShapeLayerMaker(for path: UIBezierPath, color: UIColor) -> CAShapeLayer {
        return lockLayerSetting(for: path, color: color)
    }
    
    /// 設定moveLayer
    func moveLayerSetting(for path: UIBezierPath, color: UIColor) {
        _ = lockLayerSetting(moveLayer, for: path, color: color)
    }
    
    /// 記錄密碼
    func recordFinalPassword() {
        
        if selectedPassword.count > 0 {
            delegate?.patternLockView(self, didFinished: selectedPassword)
        }
    }
}
