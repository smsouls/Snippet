//
//  ViewController.swift
//  sign
//
//  Created by 小朋友 on 2016/12/14.
//  Copyright © 2016年 小朋友. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    var draw : DrawSignatureView?
    var resetButton : UIButton?
    var imageButton : UIButton?
    
    var imageView : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        draw = DrawSignatureView(frame: CGRect(x: 50, y: 60, width: 200, height: 200))
        
        resetButton = UIButton(frame: CGRect(x: 20, y: (draw?.frame.maxY)! + 20, width: 80, height: 30))
        resetButton?.backgroundColor = UIColor.blue
        resetButton?.setTitle("清空", for: .normal)
        resetButton?.addTarget(self, action: #selector(reset(_:)), for: .touchUpInside)
        
        imageButton = UIButton(frame: CGRect(x: (resetButton?.frame.maxX)! + 50, y: (draw?.frame.maxY)! + 20, width: 80, height: 30))
        imageButton?.backgroundColor = UIColor.purple
        imageButton?.setTitle("图片", for: .normal)
        imageButton?.addTarget(self, action: #selector(showImage(_:)), for: .touchUpInside)
        
        imageView = UIImageView(frame: CGRect(x: 50, y: (resetButton?.frame.maxY)! + 10, width: 200, height: 200))
        imageView?.backgroundColor = UIColor.lightGray
        
        self.view.addSubview(draw!)
        self.view.addSubview(resetButton!)
        self.view.addSubview(imageButton!)
        self.view.addSubview(imageView!)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func reset(_ sender : Any) -> () {
        draw?.clearSignature()
        
    }
    
    func showImage(_ sender : Any) -> () {
        let image = draw?.getSignature()
        imageView?.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

