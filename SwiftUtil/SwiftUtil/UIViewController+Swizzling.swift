//
//  UIViewController+Swizzling.swift
//  RunningTimeSwift
//
//  Created by 123 on 2018/5/28.
//  Copyright © 2018年 NoName. All rights reserved.
//

import UIKit

private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    
    guard (originalMethod != nil && swizzledMethod != nil) else {
        return
    }
    
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
    //为了防止子类没有实现给方法,然后把父类的方法给换了
//    if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
//        class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
//    }else {
//        method_exchangeImplementations(originalMethod!, swizzledMethod!)
//    }
    
}


extension UIViewController {
    
    static func awake() {
        UIViewController.classInit
    }
    
    static let classInit : Void = {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.my_viewWillAppear(animated:))
        swizzling(UIViewController.self, originalSelector, swizzledSelector)
    }()
    
    
    @objc func my_viewWillAppear(animated: Bool) {
        self.my_viewWillAppear(animated: animated)
        let viewControllerName = NSStringFromClass(type(of: self))
        print("viewWillAppear: \(viewControllerName)")
    }
}


extension Person {
    static func awake() {
        Person.classInit
    }
    
    static let classInit : Void = {
        let originalSelector = #selector(Person.hehe)
        let swizzledSelector = #selector(Person.my_hehe)
        swizzling(Person.self, originalSelector, swizzledSelector)
    }()
    
    
    @objc func my_hehe() {
        self.my_hehe()
        let log = NSStringFromClass(type(of: self))
        NSLog("+++++:%@",log)
    }
}


