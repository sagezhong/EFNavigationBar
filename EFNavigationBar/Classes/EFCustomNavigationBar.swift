//
//  EFCustomNavigationBar.swift
//  EFNavigationBar
//
//  Created by itwangrui on 2017/11/25.
//  Copyright © 2017年 wangrui. All rights reserved.
//

import UIKit

fileprivate let EFDefaultTitleSize: CGFloat = 18
fileprivate let EFDefaultTitleColor = UIColor.black
fileprivate let EFDefaultBackgroundColor = UIColor.white
fileprivate let EFScreenWidth = UIScreen.main.bounds.size.width

// MARK: - Router
public extension UIViewController {
    //  A页面 弹出 登录页面B
    //  presentedViewController:    A页面
    //  presentingViewController:   B页面
    
    func ef_toLastViewController(animated: Bool) {
        if self.navigationController != nil {
            if self.navigationController?.viewControllers.count == 1 {
                self.dismiss(animated: animated, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: animated)
            }
        } else if self.presentingViewController != nil {
            self.dismiss(animated: animated, completion: nil)
        }
    }
    
    class func ef_currentViewController() -> UIViewController {
        if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
            return self.ef_currentViewController(from: rootVC)
        } else {
            return UIViewController()
        }
    }

    class func ef_currentViewController(from fromVC: UIViewController) -> UIViewController {
        if let navigationController = fromVC as? UINavigationController, let subViewController = navigationController.viewControllers.last {
            return ef_currentViewController(from: subViewController)
        } else if let tabBarController = fromVC as? UITabBarController, let subViewController = tabBarController.selectedViewController {
            return ef_currentViewController(from: subViewController)
        } else if let presentedViewController = fromVC.presentedViewController {
            return ef_currentViewController(from: presentedViewController)
        } else {
            return fromVC
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
public class EFCustomNavigationBar: UIView {
    public var onClickLeftButton:(()->())?
    public var onClickRightButton:(()->())?
    public var title: String? {
        willSet {
            titleLabel.isHidden = false
            titleLabel.text = newValue
        }
    }
    public var titleLabelColor: UIColor? {
        willSet {
            titleLabel.textColor = newValue
        }
    }
    public var titleLabelFont: UIFont? {
        willSet {
            titleLabel.font = newValue
        }
    }
    public var barBackgroundColor: UIColor? {
        willSet {
            backgroundImageView.isHidden = true
            backgroundView.isHidden = false
            backgroundView.backgroundColor = newValue
        }
    }
    public var barBackgroundImage: UIImage? {
        willSet {
            backgroundView.isHidden = true
            backgroundImageView.isHidden = false
            backgroundImageView.image = newValue
        }
    }
    
    // fileprivate UI variable
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = EFDefaultTitleColor
        label.font = UIFont.systemFont(ofSize: EFDefaultTitleSize)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    public lazy var leftButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .center
        button.isHidden = true
        button.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        return button
    }()
    
    public lazy var rightButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .center
        button.isHidden = true
        button.addTarget(self, action: #selector(clickRight), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: (218.0 / 255.0), green: (218.0 / 255.0), blue: (218.0 / 255.0), alpha: 1.0)
        return view
    }()
    
    fileprivate lazy var backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var backgroundImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.isHidden = true
        return imgView
    }()
    
    // fileprivate other variable
    fileprivate static var isIphoneX: Bool {
        get {
            return UIScreen.main.bounds.equalTo(CGRect(x: 0, y: 0, width: 375, height: 812))
        }
    }
    fileprivate static var navBarBottom: Int {
        get {
            return isIphoneX ? 88 : 64
        }
    }
    
    // init
    public class func CustomNavigationBar() -> EFCustomNavigationBar {
        let frame = CGRect(x: 0, y: 0, width: EFScreenWidth, height: CGFloat(navBarBottom))
        return EFCustomNavigationBar(frame: frame)
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func setupView() {
        addSubview(backgroundView)
        addSubview(backgroundImageView)
        addSubview(leftButton)
        addSubview(titleLabel)
        addSubview(rightButton)
        addSubview(bottomLine)
        updateFrame()
        backgroundColor = UIColor.clear
        backgroundView.backgroundColor = EFDefaultBackgroundColor
    }
    public func updateFrame() {
        let top: CGFloat = EFCustomNavigationBar.isIphoneX ? 44 : 20
        let margin: CGFloat = 0
        let buttonHeight: CGFloat = 44
        let buttonWidth: CGFloat = 44
        let titleLabelHeight: CGFloat = 44
        let titleLabelWidth: CGFloat = 180
        
        backgroundView.frame = self.bounds
        backgroundImageView.frame = self.bounds
        leftButton.frame = CGRect(x: margin, y: top, width: buttonWidth, height: buttonHeight)
        rightButton.frame = CGRect(x: EFScreenWidth - buttonWidth-margin, y: top, width: buttonWidth, height: buttonHeight)
        titleLabel.frame = CGRect(x: (EFScreenWidth - titleLabelWidth) / 2.0, y: top, width: titleLabelWidth, height: titleLabelHeight)
        bottomLine.frame = CGRect(x: 0, y: bounds.height - 0.5, width: EFScreenWidth, height: 0.5)
    }
}

public extension EFCustomNavigationBar {
    func ef_setBottomLineHidden(hidden: Bool) {
        bottomLine.isHidden = hidden
    }
    func ef_setBackgroundAlpha(alpha: CGFloat) {
        backgroundView.alpha = alpha
        backgroundImageView.alpha = alpha
        bottomLine.alpha = alpha
    }
    func ef_setTintColor(color: UIColor) {
        leftButton.setTitleColor(color, for: .normal)
        rightButton.setTitleColor(color, for: .normal)
        titleLabel.textColor = color
    }
    
    // 左右按钮共有方法
    func ef_setLeftButton(normal: UIImage, highlighted: UIImage) {
        ef_setLeftButton(normal: normal, highlighted: highlighted, title: nil, titleColor: nil)
    }
    func ef_setLeftButton(image: UIImage) {
        ef_setLeftButton(normal: image, highlighted: image, title: nil, titleColor: nil)
    }
    func ef_setLeftButton(title: String, titleColor: UIColor) {
        ef_setLeftButton(normal: nil, highlighted: nil, title: title, titleColor: titleColor)
    }
    
    func ef_setRightButton(normal: UIImage, highlighted: UIImage) {
        ef_setRightButton(normal: normal, highlighted: highlighted, title: nil, titleColor: nil)
    }
    func ef_setRightButton(image: UIImage) {
        ef_setRightButton(normal: image, highlighted: image, title: nil, titleColor: nil)
    }
    func ef_setRightButton(title: String, titleColor: UIColor) {
        ef_setRightButton(normal: nil, highlighted: nil, title: title, titleColor: titleColor)
    }

    // 左右按钮私有方法
    private func ef_setLeftButton(normal: UIImage?, highlighted: UIImage?, title: String?, titleColor: UIColor?) {
        leftButton.isHidden = false
        leftButton.setImage(normal, for: .normal)
        leftButton.setImage(highlighted, for: .highlighted)
        leftButton.setTitle(title, for: .normal)
        leftButton.setTitleColor(titleColor, for: .normal)
    }
    private func ef_setRightButton(normal: UIImage?, highlighted: UIImage?, title: String?, titleColor: UIColor?) {
        rightButton.isHidden = false
        rightButton.setImage(normal, for: .normal)
        rightButton.setImage(highlighted, for: .highlighted)
        rightButton.setTitle(title, for: .normal)
        rightButton.setTitleColor(titleColor, for: .normal)
    }
}

// MARK: - 导航栏左右按钮事件
public extension EFCustomNavigationBar {
    @objc func clickBack() {
        if let onClickBack = onClickLeftButton {
            onClickBack()
        } else {
            let currentVC = UIViewController.ef_currentViewController()
            currentVC.ef_toLastViewController(animated: true)
        }
    }
    @objc func clickRight() {
        if let onClickRight = onClickRightButton {
            onClickRight()
        }
    }
}