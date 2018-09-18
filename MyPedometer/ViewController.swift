//
//  ViewController.swift
//  MyPedometer
//
//  Created by JiangNan on 2018/9/3.
//  Copyright © 2018年 nickjiang. All rights reserved.
//

import UIKit
import RxSwift
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet private var stepCountLabel: UILabel!
    @IBOutlet private var calorieButton: UIButton!
    @IBOutlet private var calorieLabel: UITextField!
    
    private let pedometer = CMPedometer()
    private static var historicalSteps: Variable<Int> = Variable(0)
    private let disposeBag = DisposeBag()
    
    @IBAction private func transferStepToCalorie(_ sender: Any) {
        if let step = stepCountLabel.text {
            let cal = Int(step)!/10
            calorieLabel.text = String(cal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildStepObserver()
        
        pedometer.startUpdates(from: Date(), withHandler: { [weak self]
            pedometerData, _ in
            
            guard let `self` = self else { return }
            self.queryPedometerData()
        })
    }

    private func buildStepObserver() {
        ViewController.historicalSteps.asObservable()
            .subscribe(onNext: {
                _ in
                self.updateSteps()
            })
            .disposed(by: disposeBag)
        
        queryPedometerData()
    }
    
    private func queryPedometerData() {
        let dayStart = startDate()
        
        pedometer.queryPedometerData(from: dayStart, to: Date(), withHandler: {
            pedometerData, _ in
            guard let data = pedometerData else { return }
            DispatchQueue.main.async {
                ViewController.historicalSteps.value = data.numberOfSteps.intValue
            }
        })
    }
    
    private func updateSteps(with liveData: CMPedometerData? = nil) {
        let steps = ViewController.historicalSteps.value + (liveData?.numberOfSteps.intValue ?? 0)
        guard let _ = view.window else { return }
        stepCountLabel.text = "\(steps)"
        updateOthers(with: steps)
    }
    
    private func updateOthers(with steps: Int) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.calorieButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
    }
    
    /// today's date from 0:00 AM
    private func startDate() -> Date {
        let currentCalendar = Calendar.current
        var components = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let startDate = currentCalendar.date(from: components) else { return Date() }
        return startDate
    }
}

