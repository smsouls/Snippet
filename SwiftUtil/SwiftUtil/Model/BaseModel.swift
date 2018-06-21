//
//  BaseModel.swift
//  RunningTimeSwift
//
//  Created by 123 on 2018/5/28.
//  Copyright © 2018年 NoName. All rights reserved.
//

import UIKit

class BaseModel: NSObject {
    
    @objc func hehe() {
        NSLog("-----hehe")
    }
    
    
    @objc func update0() {
        NSLog("-----Update0")
    }
    
    @objc func update1() {
        NSLog("-----Update1")
    }
    
    
    @objc func update2() {
        NSLog("-----Update2")
    }
    
    
    func update3() {
        NSLog("-----Update3")
    }
    
    
    func print() {
        NSLog(MirrorObject())
    }
    
    func MirrorObject() -> String{
        let description = NSMutableString()
        description.append("***** \(type(of: self)) ***** \n")
        let selfMirror = Mirror(reflecting: self)
        MirrorProperty(selfMirror, description)
        description.append("***** \(type(of: self)) ***** \n")
        return description as String
    }
    
    
    func MirrorProperty(_ mirror: Mirror, _ description: NSMutableString) {
        for child in mirror.children {
            if let propertyName = child.label {
                if (child.value is BaseModel) {
                    description.append((child.value as! BaseModel).MirrorObject())
                }else {
                    description.append("\(propertyName): \(child.value)\n")
                }
            }
        }
        
        guard let superMirror = mirror.superclassMirror else {
            return
        }
        MirrorProperty(superMirror, description)
    }

}

class Dog: BaseModel {
    var color: String?
}

class Person: BaseModel {
    var dog: Dog?
    var name: String?
    var age: Int?
}
