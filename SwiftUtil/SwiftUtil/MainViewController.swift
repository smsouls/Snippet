//
//  MainViewController.swift
//  RunningTimeSwift
//
//  Created by 123 on 2018/5/28.
//  Copyright © 2018年 NoName. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
//        self.update(1)
        let dog = Dog()
        dog.color = "黄色"
        
        let person = Person()
        person.age = 18
        person.name = "小朋友"
        person.dog = dog
//        let selector = NSSelectorFromString("my_hehe")
////        person.perform(selector)
//        person.hehe()
        
        let model = BaseModel()
        model.hehe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func update(_ version: Int) {
        let selector = NSSelectorFromString("update" + String(version))
        let model = BaseModel()
        model.perform(selector)
    }

}



extension UIViewController {
    
    
}
