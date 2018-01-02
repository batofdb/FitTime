//
//  OnWorkoutViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import AVFoundation

class OnWorkoutViewController: UIViewController {
    var time: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.timerLabel.text = "\(self.time)"

                if let s = self.timerLabel.text {
                    let utterance = AVSpeechUtterance(string:s)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = 0.5

                    if self.synthesizer.isSpeaking {
                        self.synthesizer.stopSpeaking(at: .immediate)
                    }
                    self.synthesizer.speak(utterance)
                }
            }
        }
    }

    @IBOutlet weak var timerLabel: UILabel!
    var timer: Timer? = Timer()
    let synthesizer = AVSpeechSynthesizer()

    func start() {
        timer?.invalidate()
        timer = nil

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.time += 1
        })
    }

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        time = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Workaround during init
        let utterance = AVSpeechUtterance(string:" ")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5

        synthesizer.speak(utterance)

        timerLabel.text = "0"
    }

    @IBAction func onStart(_ sender: Any) {
        start()
    }

    @IBAction func onPause(_ sender: Any) {
        pause()
    }

    @IBAction func onStop(_ sender: Any) {
        stop()
    }

}
