//: [Previous](@previous)

import UIKit
import PlaygroundSupport
import GameplayKit




var stackViewController = StackViewController()
Playground.present(viewController: stackViewController)

let equalizer1 = EqualizerView()
let equalizer2 = EqualizerView()
stackViewController.views = [equalizer1, equalizer2]
equalizer1.fill = .secondary
equalizer1.background = .background
equalizer2.fill = .accent
equalizer2.background = .background

let bandCount = 10


func set(bandValues: [CGFloat], equalizer: EqualizerView, completion: @escaping () -> ()) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.2)
    CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
    equalizer.bandValues = bandValues
    CATransaction.commit()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        equalizer.bandValues = bandValues.map { max($0 * 0.1, 0.1) }
        CATransaction.commit()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        completion()
    }
}

// Uniform random

func loopAnimate1() {
    var bandValues: [CGFloat] = []
    for _ in 0..<bandCount {
        let bandValue = 0.1 + 0.9 * (CGFloat(arc4random()) / CGFloat(UINT32_MAX))
        bandValues.append(bandValue)
    }

    set(bandValues: bandValues, equalizer: equalizer1) {
        loopAnimate1()
    }
}
loopAnimate1()

// GameplayKit

let source2 = GKPerlinNoiseSource()
source2.frequency = 2
source2.octaveCount = 3
source2.persistence = 0.5
source2.lacunarity = 2

let noise2 = GKNoise(source2)
let map2 = GKNoiseMap(
    noise2,
    size: vector2(1, 1),
    origin: vector2(0, 0),
    sampleCount: vector2(Int32(bandCount), 200),
    seamless: true
)
var sliceIndex = 0
func loopAnimate2() {
    var bandValues: [CGFloat] = []
    for i in 0..<bandCount {
        let normalized = 0.5 + CGFloat(map2.value(at: vector2(numericCast(i), numericCast(sliceIndex)))) / 2
        let bandValue = 0.1 + 0.9 * normalized
        bandValues.append(bandValue)
    }
    sliceIndex += 10
    if sliceIndex > numericCast(map2.sampleCount.y) {
        sliceIndex = 0
    }

    set(bandValues: bandValues, equalizer: equalizer2) {
        loopAnimate2()
    }
}
loopAnimate2()


/* Screenshots for talk */
do {
    let bandCount = 20
    let sampleCount = 50
    let stepSize = 1
    let size = CGSize(width: 700, height: 525)

    // Noise
    let source = GKPerlinNoiseSource()
    source.seed = 0
    source.frequency = 2
    source.octaveCount = 3
    source.persistence = 0.5
    source.lacunarity = 2

    let noise2 = GKNoise(source)
    let map2 = GKNoiseMap(
        noise2,
        size: vector2(1, 1),
        origin: vector2(0, 0),
        sampleCount: vector2(Int32(bandCount), numericCast(sampleCount * stepSize)),
        seamless: true
    )

    // View
    let equalizer = EqualizerView()
    equalizer.fill = .accent
    equalizer.background = .background

    // Naive
    let nvSampleBandValues: [[CGFloat]] = {
        var sampleBandValues: [[CGFloat]] = []
        for _ in 0..<sampleCount {
            var bandValues: [CGFloat] = []
            for _ in 0..<bandCount {
                let bandValue = 0.1 + 0.9 * (CGFloat(arc4random()) / CGFloat(UINT32_MAX))
                bandValues.append(bandValue)
            }
            sampleBandValues.append(bandValues)
        }
        return sampleBandValues
    }()
    for (index, bandValues) in nvSampleBandValues.enumerated() {
        equalizer.bandValues = bandValues
        equalizer.save(filename: "NaiveEqualizer\(index)", size: size)
    }


    // GameplayKit
    let gkSampleBandValues: [[CGFloat]] = {
        var sampleBandValues: [[CGFloat]] = []
        var sliceIndex = 0
        for _ in 0..<sampleCount {
            var bandValues: [CGFloat] = []
            for i in 0..<bandCount {
                let normalized = 0.5 + CGFloat(map2.value(at: vector2(numericCast(i), numericCast(sliceIndex)))) / 2
                let bandValue = 0.1 + 0.9 * normalized
                bandValues.append(bandValue)
            }
            sliceIndex += stepSize
            if sliceIndex > numericCast(map2.sampleCount.y) {
                sliceIndex = 0
            }
            sampleBandValues.append(bandValues)
        }
        return sampleBandValues
    }()

    for (index, bandValues) in gkSampleBandValues.enumerated() {
        equalizer.bandValues = bandValues
        equalizer.save(filename: "GemEqualizer\(index)", size: size)
    }
}



//: [Next](@next)
