//
//  LCWaveView.swift
//
//  Created by Liu Chuan on 2017/3/15.
//  Copyright © 2017年 LC. All rights reserved.
//


import UIKit

class LCWaveView: UIView {
    
    public var waveRate: CGFloat = 1.5
    
    public var waveSpeed: CGFloat = 0.5
    
    public var waveHeight: CGFloat = 5
    
    public var realWaveColor: UIColor = UIColor.white {
        didSet {
            realWaveLayer.fillColor = realWaveColor.cgColor
        }
    }
    
    public var maskWaveColor: UIColor = UIColor.white {
        didSet {
            maskWaveLayer.fillColor = maskWaveColor.cgColor
        }
    }
    
    public var completion: ((_ centerY: CGFloat)->())?
    
    private lazy var realWaveLayer: CAShapeLayer = CAShapeLayer()
   
    private lazy var maskWaveLayer: CAShapeLayer = CAShapeLayer()
    
    private var waveDisplayLink: CADisplayLink?
    
    private var offset: CGFloat = 0
    
    private var priFrequency: CGFloat = 0

    private var priWaveSpeed: CGFloat = 0

    private var priWaveHeight: CGFloat = 0
    
    private var isStarting: Bool = false

    private var isStopping: Bool = false
    
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var tempf = bounds
        tempf.origin.y = frame.size.height
        tempf.size.height = 0
        
        maskWaveLayer.frame = tempf
        realWaveLayer.frame = tempf
        
        backgroundColor = .clear
        layer.addSublayer(realWaveLayer)
        layer.addSublayer(maskWaveLayer)
    }
    

    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        
        realWaveColor = color
        maskWaveColor = color.withAlphaComponent(0.7)
        realWaveLayer.fillColor = realWaveColor.cgColor
        maskWaveLayer.fillColor = maskWaveColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LCWaveView {
    
    public func startWave() {
        
        if !isStarting {
            
            removeTimer()   // 先移除屏幕刷新率定时器
            isStarting = true
            isStopping = false
            
            waveDisplayLink = CADisplayLink(target: self, selector: #selector(waveEvent))
            waveDisplayLink?.add(to: .current, forMode: RunLoop.Mode.common)
        }
    }
    
    public func stopWave() {
        if !isStopping {
            isStarting = false
            isStopping = true
        }
    }
    
    private func removeTimer() {
        // 从运行循环中移除定时器
        waveDisplayLink?.invalidate()
        waveDisplayLink = nil
    }
    
    @objc func waveEvent() {
        

        if isStarting {
            BeganToWave()
        }
        if isStopping {
            endToWave()
        }
        other()
    }
    
}


extension LCWaveView {
    
    private func BeganToWave() {
        guard priWaveHeight < waveHeight else {
            isStarting = false
            return
        }
        priWaveHeight = priWaveHeight + waveHeight / 100
        
        var f = self.bounds
        
        f.origin.y = f.size.height - priWaveHeight
        f.size.height = priWaveHeight
        
        maskWaveLayer.frame = f
        realWaveLayer.frame = f
        priFrequency = priFrequency + waveRate / 100
        priWaveSpeed = priWaveSpeed + waveSpeed / 100
    }
    
    private func endToWave() {
        guard priWaveHeight > 0 else {  // 停止
            isStopping = false
            stopWave()
            return
        }
        priWaveHeight = priWaveHeight - waveHeight / 50.0

        var f = self.bounds

        f.origin.y = f.size.height
        f.size.height = priWaveHeight

        maskWaveLayer.frame = f
        realWaveLayer.frame = f
        priFrequency = priFrequency - waveRate / 50.0
        priWaveSpeed = priWaveSpeed - waveSpeed / 50.0
    }
    
    /// 其他情况
    private func other() {

        offset += priWaveSpeed
        
        var y: CGFloat = 0.0
        let width: CGFloat = frame.width
        let height: CGFloat = priWaveHeight

        let realPath = CGMutablePath()
        let maskPath = CGMutablePath()
        
        realPath.move(to: CGPoint(x: 0, y: height))
        maskPath.move(to: CGPoint(x: 0, y: height))
        
        let offset_f = Float(offset * 0.045)
        
        let waveFrequency_f = Float(0.01 * priFrequency)
        
        for x in 0...Int(width) {
            
            y = height * CGFloat(sin(waveFrequency_f * Float(x) + offset_f))
            
            realPath.addLine(to: CGPoint(x: CGFloat(x), y: y))
            maskPath.addLine(to: CGPoint(x: CGFloat(x), y: -y))
        }
        
        let midX = bounds.size.width * 0.5
        let midY = height * sin(midX * CGFloat(waveFrequency_f) + CGFloat(offset_f))
        
        if let callback = completion {
            callback(midY)
        }
        
        realPath.addLine(to: CGPoint(x: width, y: height))
        realPath.addLine(to: CGPoint(x: 0, y: height))
        maskPath.addLine(to: CGPoint(x: width, y: height))
        maskPath.addLine(to: CGPoint(x: 0, y: height))

        maskPath.closeSubpath()
        realPath.closeSubpath()

        realWaveLayer.path = realPath
        maskWaveLayer.path = maskPath
    }
    
}

