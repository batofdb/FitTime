//
//  OnWorkoutViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import AVFoundation

enum TimerState {
    case intro
    case inProgress
    case pause
    case stopped
    case unknown
}

class OnWorkoutViewController: UIViewController {
    var backgroundTimer: BackgroundTimer = BackgroundTimer()
    var timerSections = [[Timeable]]()
    var isDragging: Bool = false
    var timerQueue = [Timeable]()
    var workout: Workout?
    var timerState: TimerState = .stopped {
        didSet {
            processTimerState()
        }
    }

    var currentIndexPath: IndexPath = IndexPath(row: 0, section: 0) {
        didSet {
            guard   timerSections.indices.contains(currentIndexPath.section),
                    timerSections[currentIndexPath.section].indices.contains(currentIndexPath.row) else {
                    return
            }

            if !isDragging {
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: self.currentIndexPath, at: .top, animated: true)
                }
            }
        }
    }
    let initialDelayInSeconds: Int = 5
    let introCount: Int = 10
    var introUtterance: String = ""
    var isFinished: Bool = false {
        didSet {
            if isFinished {
                timer?.invalidate()
                timer = nil

                currentIndexPath.section = 0
                currentIndexPath.row = 0

                isFinished = false
            }
        }
    }
    var countdownTimer: Timer? = nil
    let bufferCount: Int = 3
    var countdownTime: Int = 0 {
        didSet {
            countdownUpdated()
        }
    }

    var currentExerciseCount: Int = 0

    @IBOutlet weak var tableView: UITableView!
    var time: Int = 0 {
        didSet {
            if time != 0 {
                timeUpdated()
            }
        }
    }

    func processTimerState() {
        switch timerState {
        case .stopped:
            stop()
        case .intro:
            speak("Workout starting in \(introCount) seconds")
            intro()
        case .inProgress:
            start()
        case .pause:
            break
        default:
            break
        }
    }



    func intro() {
        countdownTime = introCount

        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdownDecremented), userInfo: nil, repeats: true)

        RunLoop.current.add(countdownTimer!, forMode: RunLoopMode.commonModes)
    }

    @objc func countdownDecremented() {
        self.countdownTime -= 1
    }

    func countdownUpdated() {
        if countdownTime == 0 {
            timerState = .inProgress

            for t in timerQueue {
                speak(t.name, delay: Double(t.duration))
            }
        } else if countdownTime == 5  {
            if let firstExercise = timerSections.first?.first {
               // speak("\(firstExercise.name) is next")
            }
        } else if countdownTime == introCount - 1, let name = workout?.name {
           // speak("\(name)")
        }
    }

    func timeUpdated() {
        guard   timerSections.indices.contains(currentIndexPath.section),
                timerSections[currentIndexPath.section].indices.contains(currentIndexPath.row) else {
                   // speak("Workout Complete")
                    timerState = .stopped
                return
        }

        var currentExercise = timerSections[currentIndexPath.section][currentIndexPath.row]

        print("\(currentExercise.name) countdowntimer:\(currentExerciseCount)")

        if time == 1 {
            currentExerciseCount = currentExercise.duration
        } else {
            let sectionCount = currentIndexPath.section
            let exerciseCount = currentIndexPath.row
            let timer = timerSections[currentIndexPath.section]

            if currentExerciseCount == 0  {
                if currentIndexPath.row < timerSections[currentIndexPath.section].count - 1 {
                    currentIndexPath.row += 1

                    currentExercise = timerSections[currentIndexPath.section][currentIndexPath.row]
                    currentExerciseCount = currentExercise.duration
                } else {
                    currentIndexPath = IndexPath(row: 0, section: currentIndexPath.section + 1)

                    guard   timerSections.indices.contains(currentIndexPath.section),
                            timerSections[currentIndexPath.section].indices.contains(currentIndexPath.row) else {
                            //speak("Workout Complete")
                            timerState = .stopped
                            return
                    }

                    currentExercise = timerSections[currentIndexPath.section][currentIndexPath.row]
                    currentExerciseCount = currentExercise.duration
                }
            }

            if currentIndexPath.section > timerSections.count - 1 {
                isFinished = true
            }
        }


        if currentExerciseCount == currentExercise.duration {
            var verbalExercise: String = currentExercise.name
            /*
            if currentExercise.repType == .repetition {
                var comps = verbalExercise.components(separatedBy: ":")
                comps.remove(at: 0)
                verbalExercise = comps.first ?? "Exercise"
            }*/
            speak(verbalExercise)
        }




        self.timerLabel.text = "\(currentExerciseCount)"
    }

    func speak(_ string: String, delay: Double = 0.0) {
        let utterance = AVSpeechUtterance(string:string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        utterance.volume = 0.9

        if delay > 0 {
            utterance.postUtteranceDelay = delay
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Uh oh!")
        }


        synthesizer.speak(utterance)
    }

    @IBOutlet weak var timerLabel: UILabel!
    var timer: Timer? = Timer()
    let synthesizer = AVSpeechSynthesizer()

    func start() {
        backgroundTimer.startBackgroundTimer {
            print("finished background timer")
        }

        timer?.invalidate()
        timer = nil

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerIncremented), userInfo: nil, repeats: true)

        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }

    @objc func timerIncremented() {
        self.time += 1

        if self.countdownTime > 0 {
            self.countdownTime -= 1
        }

        if self.currentExerciseCount > 0 {
            self.currentExerciseCount -= 1
        }
    }

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        time = 0
        currentIndexPath = IndexPath(row: 0, section: 0)
        currentExerciseCount = 0

        timerLabel.text = "0"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print(timerSections)

        introUtterance = "\(workout?.name) starts in 10 seconds"

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
        synthesizer.delegate = self

        timerLabel.text = "0"
    }

    @IBAction func onStart(_ sender: Any) {
        timerState = .intro
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
    }
}

extension OnWorkoutViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        do {
//            try AVAudioSession.sharedInstance().setActive(false)
//        } catch {
//            print("Uh oh!")
//        }
    }
}


