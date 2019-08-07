//
//  PLTabBar.swift
//  PLKit
//
//  Created by iOS on 2019/8/7.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit

@objc protocol PLTabBarDelegate: NSObjectProtocol {
    @objc optional func tabBar(_ tabBar: PLTabBar, willSelect index: Int) -> Bool
    @objc optional func tabBar(_ tabBar: PLTabBar, didSelect index: Int)
}

class PLTabBar: UIView {
    
    weak var delegate: PLTabBarDelegate?
    
    /// 内容高度 去掉safe边距
    var contentHeight: CGFloat = 0 {
        didSet {
            if oldValue != contentHeight {
                renewContentLayout()
            }
        }
    }
    
    var items: [PLTabBarItem]? {
        didSet {
            oldValue?.forEach({$0.removeFromSuperview()})
            items?.forEach({contentView.addSubview($0)})
            renewContentLayout()
            setSelectedIndex(0)
        }
    }
    
    /// 当前选中item
    var selectedItem: PLTabBarItem? {
        guard let items = items else {
            return nil
        }
        if selectedIndex >= 0 && selectedIndex < items.count {
            return items[selectedIndex]
        }
        return nil
    }
    
    /// 使用set方法更改
    private(set) var selectedIndex = -1
    
    ///
    private var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    private func commInit() {
        self.backgroundColor = .white
        
        self.contentView = UIView()
        self.addSubview(contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        renewContentLayout()
    }
    
    /// 重新布局item
    private func renewContentLayout() {
        let height = contentHeight > 0 ? contentHeight : bounds.height
        self.contentView.frame = .init(x: 0, y: 0, width: bounds.width, height: height)
        
        guard let items = items else {
            return
        }
        
        let width = bounds.width / CGFloat(items.count)
        for (idx, item) in items.enumerated() {
            item.frame = .init(x: CGFloat(idx) * width, y: 0, width: width, height: height)
        }
    }
    
    /// 设置选中index
    /// - Parameter index:
    @discardableResult
    func setSelectedIndex(_ index: Int) -> Bool {
        guard self.selectedIndex != index else {
            return false
        }
        
        self.selectedItem?.isSelected = false
        self.selectedIndex = index
        self.selectedItem?.isSelected = true
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) {
            guard let items = items else {
                return
            }
            guard items.count > 0 else {
                return
            }

            let width = contentView.frame.width / CGFloat(items.count)
            if contentView.frame.contains(point) {
                let idx = Int(point.x / width)
                guard idx != self.selectedIndex else {
                    return
                }
                
                if (self.delegate?.tabBar?(self, willSelect: idx) ?? true) && self.setSelectedIndex(idx) {
                    self.delegate?.tabBar?(self, didSelect: idx)
                }
            }
        }
    }
}
