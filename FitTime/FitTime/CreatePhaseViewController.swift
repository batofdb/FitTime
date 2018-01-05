//
//  CreatePhaseViewController.swift
//  FitTime
//
//  Created by Francis Bato on 1/1/18.
//  Copyright © 2018 LateRisers. All rights reserved.
//

import UIKit
import RealmSwift

protocol CreatePhaseViewControllerDelegate: class {
    func saved(phase: ExercisePhase)
}

class CreatePhaseViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var interval: UITextField!

    weak var delegate: CreatePhaseViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func save(_ sender: Any) {
        guard let interText = interval.text, let inter = Int(interText), let n = name.text else { return }
        let phase = ExercisePhase()
        phase.interval = inter
        phase.name = n

        delegate?.saved(phase: phase)

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
