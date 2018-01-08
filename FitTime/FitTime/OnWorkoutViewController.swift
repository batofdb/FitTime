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
    var timerSections = [[Timeable]]()
    var workout: Workout?

    @IBOutlet weak var tableView: UITableView!
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
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }

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

    @IBAction func onExistTapped(_ sender: UIButton) {
        dismiss(animated: true) {

        }
    }
}

extension OnWorkoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerSections[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return timerSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var time = timerSections[indexPath.section][indexPath.row]
        cell.textLabel?.text = time.name
        cell.detailTextLabel?.text = "Duration: \(time.duration)"
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let first = timerSections[section].first {
            switch first.type {
            case .cooldown:
                return "Cooldown"
            case .warmup:
                return "Warmup"
            case .main(_):
                var warmupExists: Bool = false
                let firstItem = timerSections.first

                if let i = firstItem?.first, i.type == .warmup {
                    warmupExists = true
                }

                return "Set \(warmupExists ? section : section+1)"
            }
        }

        return nil
    }
}
