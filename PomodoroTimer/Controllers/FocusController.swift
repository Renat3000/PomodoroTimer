//
//  ViewController.swift
//  PomodoroTimer
//
//  Created by Maxim Samodurov on 03.03.2023.
//

import UIKit

class FocusController: UIViewController {
    
    let focusView = FocusView(frame: CGRect.zero)
    
    var timer: Timer!
    let totalTimeInSecondsIs = 25*60
    
    var minutesOnClock: Int = 0
    var secondsOnClock: Int = 0
    
    var secondsLeft: Int?
    var isCounting = false
    var startTime: Date?
    var stopTime: Date?
    
    let userDefaults = UserDefaults.standard
    let StartTimeKey = "startTime"
    let StopTimeKey = "stopTime"
    let CountingKey = "countingKey"
    
    let config = UIImage.SymbolConfiguration(pointSize: 23)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(focusView)
        focusView.fillSuperview()
        focusView.pausePlayButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        focusView.nextSectionButton.addTarget(self, action: #selector(nextSection), for: .touchUpInside)
        focusView.threeDotsButton.addTarget(self, action: #selector(resetTimer), for: .touchUpInside)
        
        focusView.timeMinutesCounter.text = String(format: "%02d", minutesOnClock)
        focusView.timeSecondsCounter.text = String(format: "%02d", secondsOnClock)
        
        startTime = userDefaults.object(forKey: StartTimeKey) as? Date
        stopTime = userDefaults.object(forKey: StopTimeKey) as? Date
        isCounting = userDefaults.bool(forKey: CountingKey)
        
        if isCounting {
            startTimer()
        } else {
            stopTimer()
            if let start = startTime {
                print(start)
                if let stop = stopTime {
                    print(stop)
                    //указываем разницу во времени тут
                    let time = calcRestartTime(start: start, stop: stop)
                    let diff = Date().timeIntervalSince(time)
                    setTimeLabel(Int(diff))
                }
            }
        }
    }
    
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        focusView.pausePlayButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
        setIsCounting(true)
    }
    
    func stopTimer(){
        focusView.pausePlayButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        if timer != nil {
            timer.invalidate()
        }
        setIsCounting(false)
    }
    
    func calcRestartTime(start: Date, stop: Date) -> Date {
        let diff = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(diff)
    }
    
    @objc func resetTimer() {
        
        setStopTime(date: nil)
        setStartTime(date: nil)
        //        timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
        minutesOnClock = 25
        secondsOnClock = 00
        focusView.timeMinutesCounter.text = String(format: "%02d", minutesOnClock)
        focusView.timeSecondsCounter.text = String(format: "%02d", secondsOnClock)
    }
    
    @objc func playPause() {
        if isCounting {
            // куда деть строку ниже, может засунуть в stopTimer()?
            setStopTime(date: Date())
            stopTimer()
        } else {
            if let stop = stopTime {
                let restartTime = calcRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
            }  else {
                setStartTime(date: Date())
            }
            startTimer()
        }
    }
    
    func setTimeLabel(_ val: Int) {
        
        secondsLeft = totalTimeInSecondsIs - val
        minutesOnClock = secondsLeft! / 60
        secondsOnClock = secondsLeft! % 60
        
//        print("it means \(minutesOnClock):\(secondsOnClock) left")
        
        focusView.timeMinutesCounter.text = String(format: "%02d", minutesOnClock)
        focusView.timeSecondsCounter.text = String(format: "%02d", secondsOnClock)
    }
    
    //MARK: – @objc funcs
    @objc func refreshValue() {
        if let start = startTime {
            let diff = Date().timeIntervalSince(start)
            setTimeLabel(Int(diff))
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    @objc func nextSection() {
        let destinationVC = ShortBreakController()
        self.present(destinationVC, animated: true)
        print("tapped")
    }
    
    
    @objc func openPopupMenu() {
        print("openPopupMenu")
    }
    
    //MARK: – set user defaults Keys
    func setStartTime(date: Date?){
        startTime = date
        userDefaults.set(startTime, forKey: StartTimeKey)
        //        print("StartTime is \(String(describing: userDefaults.object(forKey: StartTimeKey)!))")
    }
    
    func setStopTime(date: Date?){
        stopTime = date
        userDefaults.set(stopTime, forKey: StopTimeKey)
        //        print("StopTime is \(String(describing: userDefaults.object(forKey: StopTimeKey)))")
    }
    func setIsCounting(_ val: Bool){
        isCounting = val
        userDefaults.set(isCounting, forKey: CountingKey)
        //        print("IsCounting is \(String(describing: userDefaults.object(forKey: CountingKey)!))")
    }
}
