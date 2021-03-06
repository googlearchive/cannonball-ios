//
// Copyright (C) 2018 Google, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import QuartzCore

// Custom protocol for classes to implement the countdown.
protocol CountdownViewDelegate: class {

    func countdownView(_ countdown: CountdownView, didCountdownTo second: Int)

}

class CountdownView : UIView {

    let secondsLabel: UILabel

    let backgroundCircle: CAShapeLayer

    let foregroundCircle: CAShapeLayer

    weak var delegate: CountdownViewDelegate?

    var countdownTime: Int

    fileprivate var secondsRemaining: Double {
        didSet {
            progress = secondsRemaining / Double(countdownTime)

            let wholeSeconds = Int(ceil(secondsRemaining))
            secondsLabel.text = String(wholeSeconds)

            if wholeSeconds <= 10 {
                backgroundCircle.strokeColor = UIColor.cannonballRedLightColor().cgColor
                foregroundCircle.strokeColor = UIColor.cannonballRedColor().cgColor
                secondsLabel.textColor = UIColor.cannonballRedColor()
            }

            if wholeSeconds % 5 == 0 {
                delegate?.countdownView(self, didCountdownTo: Int(wholeSeconds))
            }
        }
    }

    fileprivate var displayLink: CADisplayLink?

    func start() {
        secondsRemaining = Double(countdownTime)

        displayLink?.invalidate()
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(CountdownView.tick))
        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }

    func stop() {
        displayLink?.invalidate()
    }

    // [1, 0]
    fileprivate var progress: Double = 1 {
        didSet {
            // Update remaining time circle and label.
            foregroundCircle.strokeEnd = (CGFloat) (progress)
        }
    }

    @objc func tick() {
        secondsRemaining -= displayLink!.duration
    }

    let textPadding: CGFloat = 5

    required init(frame aRect: CGRect, countdownTime time: Int) {
        countdownTime = time
        secondsRemaining = Double(countdownTime)

        secondsLabel = UILabel(frame: CGRect(x: textPadding, y: textPadding, width: aRect.size.width - 2 * textPadding, height: aRect.size.height - 2 * textPadding))
        backgroundCircle = CAShapeLayer()
        foregroundCircle = CAShapeLayer()
        super.init(frame: aRect)

        // Define the remaining time label.
        secondsLabel.text = String(countdownTime)
        secondsLabel.font = UIFont(name: "Avenir", size: 16)
        secondsLabel.textColor = UIColor.cannonballGreenColor()
        secondsLabel.textAlignment = NSTextAlignment.center

        // Define the path for the circle strokes.
        let arcCenter = CGPoint(x: bounds.width / 2, y: bounds.width / 2)
        let radius: CGFloat = bounds.width / 2
        let startAngle = CGFloat(-0.5 * .pi)
        let endAngle = CGFloat(1.5 * .pi)
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        // Define the background circle.
        backgroundCircle.path = path.cgPath
        backgroundCircle.fillColor = UIColor.clear.cgColor
        backgroundCircle.strokeColor = UIColor.cannonballGreenLightColor().cgColor
        backgroundCircle.strokeStart = 0
        backgroundCircle.strokeEnd = 1
        backgroundCircle.lineWidth = 2

        // Define the foreground circle indicating elapsing time.
        foregroundCircle.path = path.cgPath
        foregroundCircle.fillColor = UIColor.clear.cgColor
        foregroundCircle.strokeColor = UIColor.cannonballGreenColor().cgColor
        foregroundCircle.strokeStart = 0
        foregroundCircle.strokeEnd = 1
        foregroundCircle.lineWidth = 2

        // Add the circles and label to the main view.
        layer.addSublayer(backgroundCircle)
        layer.addSublayer(foregroundCircle)
        addSubview(secondsLabel)
    }

    override convenience init(frame aRect: CGRect) {
        self.init(frame: aRect, countdownTime: 0)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("Nibs not supported in this UIView subclass")
    }

}
