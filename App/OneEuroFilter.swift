
import Foundation
import QuartzCore

// 1€ Filter algorithm for jitter reduction
// Adapted from http://www.lifl.fr/~casiez/1euro/

class OneEuroFilter {
    private var freq: Double
    private var mincutoff: Double
    private var beta: Double
    private var dcutoff: Double
    
    private var x: LowPassFilter?
    private var dx: LowPassFilter?
    private var lasttime: Double?
    
    init(freq: Double = 60.0, mincutoff: Double = 1.0, beta: Double = 0.0, dcutoff: Double = 1.0) {
        self.freq = freq
        self.mincutoff = mincutoff
        self.beta = beta
        self.dcutoff = dcutoff
    }
    
    func updateParams(mincutoff: Double, beta: Double) {
        self.mincutoff = mincutoff
        self.beta = beta
    }
    
    func filter(_ value: Double, timestamp: Double? = nil) -> Double {
        let t = timestamp ?? CACurrentMediaTime()
        
        // Compute the time interval (dt)
        var dt = 1.0 / freq
        if let last = lasttime {
            dt = t - last
        }
        lasttime = t
        
        // Estimate the current variation (derivative)
        // If it's the first time, we assume the derivative is 0
        let dxValue: Double
        if let xFilter = x {
            dxValue = (value - xFilter.lastValue()) / dt
        } else {
            dxValue = 0.0
        }
        let edx = dx?.filter(dxValue, dt: dt, cutoff: dcutoff) ?? {
            let f = LowPassFilter()
            let _ = f.filter(dxValue, dt: dt, cutoff: dcutoff)
            dx = f
            return dxValue
        }()
        
        // Use the estimated variation to adapt the cutoff frequency
        let cutoff = mincutoff + beta * abs(edx)
        
        // Filter the signal
        return x?.filter(value, dt: dt, cutoff: cutoff) ?? {
            let f = LowPassFilter()
            let res = f.filter(value, dt: dt, cutoff: cutoff)
            x = f
            return res
        }()
    }
}

private class LowPassFilter {
    private var y: Double?
    private var s: Double?
    
    func lastValue() -> Double {
        return y ?? 0
    }
    
    func filter(_ value: Double, dt: Double, cutoff: Double) -> Double {
        let rc = 1.0 / (2.0 * .pi * cutoff)
        let alpha = dt / (rc + dt)
        let newY = (y != nil) ? (alpha * value + (1.0 - alpha) * y!) : value
        y = newY
        return newY
    }
}

// Helper for CGPoint
class OneEuroPointFilter {
    private let xFilter: OneEuroFilter
    private let yFilter: OneEuroFilter
    
    init(freq: Double = 60.0, mincutoff: Double = 1.0, beta: Double = 0.0, dcutoff: Double = 1.0) {
        xFilter = OneEuroFilter(freq: freq, mincutoff: mincutoff, beta: beta, dcutoff: dcutoff)
        yFilter = OneEuroFilter(freq: freq, mincutoff: mincutoff, beta: beta, dcutoff: dcutoff)
    }
    
    func filter(_ point: CGPoint) -> CGPoint {
        let t = CACurrentMediaTime()
        let x = xFilter.filter(Double(point.x), timestamp: t)
        let y = yFilter.filter(Double(point.y), timestamp: t)
        return CGPoint(x: x, y: y)
    }
    
    // Config update
    func updateParams(mincutoff: Double, beta: Double) {
        xFilter.updateParams(mincutoff: mincutoff, beta: beta)
        yFilter.updateParams(mincutoff: mincutoff, beta: beta)
    }
}
