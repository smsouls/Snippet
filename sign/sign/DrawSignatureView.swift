//
//  DrawSignatureView.swift
//  sign
//
//  Created by 小朋友 on 2016/12/14.
//  Copyright © 2016年 小朋友. All rights reserved.
//

import UIKit

class DrawSignatureView: UIView {

    private var path = UIBezierPath()
    public var lineWidth : CGFloat = 2.0 {
        didSet{
            self.path.lineWidth = lineWidth
        }
    }
    

    public var strokeColor : UIColor = UIColor.black
    public var signatureBackgroundColor : UIColor = UIColor.lightGray
    
    private var pts = [CGPoint](repeating:CGPoint(), count:5)
    private var ctr = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = self.signatureBackgroundColor
        self.path.lineWidth = self.lineWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = self.signatureBackgroundColor
        self.path.lineWidth = self.lineWidth
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
//        self.strokeColor.setStroke()
        self.path.stroke()
    }
    
    
    //刚刚点击
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            self.ctr = 0
            self.pts[self.ctr] = touchPoint
        }
    }
    
    
    //手指开始移动
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            self.ctr += 1
            self.pts[self.ctr] = touchPoint
            if (self.ctr == 4)  {
                self.pts[3] = CGPoint(x: (self.pts[2].x + self.pts[4].x) * 0.5, y: (self.pts[2].y + self.pts[4].y) * 0.5)
                self.path.move(to: self.pts[0])
                self.path.addCurve(to: self.pts[3], controlPoint1: self.pts[1], controlPoint2: self.pts[2])
                
                self.setNeedsDisplay()
                self.pts[0] = self.pts[3]
                self.pts[1] = self.pts[4]
                self.ctr = 1
            }
            
            self.setNeedsDisplay()
        }
    }
    
    //移动结束
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.ctr == 0 {
            let touchPoint = self.pts[0]
            self.path.move(to: CGPoint(x: touchPoint.x - 1.0, y: touchPoint.y))
            self.path.addLine(to: CGPoint(x: touchPoint.x + 1, y: touchPoint.y))
            self.setNeedsDisplay()
        } else {
            self.ctr = 0
        }
    }
    
    //将签名视图清空
    public func clearSignature() {
        self.path.removeAllPoints()
        self.setNeedsDisplay()
    }
    
    //将签名保存为UIimage
    public func getSignature() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.bounds.size.width, height: self.bounds.size.height))
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let signature : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return signature
    }
    
    
    

}
