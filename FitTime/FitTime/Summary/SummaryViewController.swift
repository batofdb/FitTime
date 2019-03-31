//
//  SummaryViewController.swift
//  FitTime
//
//  Created by Francis Bato on 3/14/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, MusclesInvolvedCalculate {
    var navigationView: FitTimeNavigationBar = {
        let nav = FitTimeNavigationBar()
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.backgroundColor = .white
        //nav.titleLabel.textColor = .black
        nav.subTitleLabel.isHidden = true
        //nav.gradientLayer.removeFromSuperlayer()
        nav.update(type: .summary)
        nav.titleLabel.text = "Summary"
        nav.summaryTitleLabel.text = "Workout name"
        nav.summaryNameLabel.text = "Back & Legs"
        nav.titleLabel.textColor = .white
        nav.leftButton.setImage(UIImage(named: "back_button"), for: .normal)
//        nav.ri
        //nav.rightButton.setImage(UIImage(named: "add"), for: .normal)
        nav.rightButton.setTitle("Finish", for: .normal)
        nav.rightButton.setTitleColor(UIColor(red: 80/255.0, green: 99/255.0, blue: 238/255.0, alpha: 1.0), for: .normal)
        return nav
    }()

    var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    var sets: [Int] = [2, 4, 5, 1]
    var setCount: Int = 0

    var leftInset: CGFloat = 24.0
    var rightInset: CGFloat = 24.0
    var stringWidths: [String : CGFloat] = [String : CGFloat]()
    var newLineWidth: CGFloat = UIScreen.main.bounds.width - 24 - 24
    var muscleOrder = [[String]]()
    var muscles: [String] = {
        var s = [String]()
        s.append("Chest")
        s.append("Triceps")
        s.append("Deltoids")
        s.append("Abs")
        s.append("Neck")
        s.append("Quad")
        s.append("Calves")
        s.append("Lower Back")
        return s
    }()

    var muscleSectionHeight: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setCount = sets.reduce(0, +)
        view.backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 248/255.0, alpha: 1.0)

        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.addSubview(navigationView)
        navigationView.backgroundColor = .clear

        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: 253).isActive = true

        navigationView.leftButtonTappedHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        navigationView.rightButtonTappedHandler = { [weak self] in
            if let button = self?.navigationView.rightButton {
                button.isSelected = !button.isSelected

                if button.isSelected {
                    button.setImage(UIImage(named: "added")!, for: .normal)
                    //self?.showSavedAlert(style: .saved)
                } else {
                    button.setImage(UIImage(named: "add")!, for: .normal)
                    //self?.showSavedAlert(style: .removed)
                }
            }
        }

        tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.register(UINib(nibName: "MusclesInvolvedCell", bundle: nil), forCellReuseIdentifier: "MusclesInvolvedCell")

        tableView.register(UINib(nibName: "MuscleHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "MuscleHistoryTableViewCellTop")

        tableView.register(UINib(nibName: "MuscleHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "MuscleHistoryTableViewCellMiddle")

        tableView.register(UINib(nibName: "MuscleHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "MuscleHistoryTableViewCellBottom")

        tableView.register(UINib(nibName: "MuscleHistoryTopTableViewCell", bundle: nil), forCellReuseIdentifier: "MuscleHistoryTopTableViewCell")

        tableView.register(UINib(nibName: "BasicTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "BasicTableHeaderView")

        calculateMuscleViewWidths()
        createMuscleOrder()


        let multiLineSpacing: CGFloat = (CGFloat(muscleOrder.count) - 1) * 10
        let labelHeight: CGFloat = CGFloat(muscleOrder.count) * 38
        let topBottomPadding: CGFloat = 16 + 16
        let musclesInvolvedHeight: CGFloat = multiLineSpacing + labelHeight + topBottomPadding
        let musclesDiagramHeight: CGFloat = (UIScreen.main.bounds.height * 0.49) // includes padding
        muscleSectionHeight = musclesInvolvedHeight + musclesDiagramHeight
    }
}

extension SummaryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sets.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return sets[section - 1] + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MusclesInvolvedCell", for: indexPath)
            return cell
        }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuscleHistoryTopTableViewCell", for: indexPath) as! MuscleHistoryTopTableViewCell
            return cell
        }

        let count = sets[indexPath.section - 1]

        if indexPath.row == 1 && (count > 1){
            // first
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuscleHistoryTableViewCellTop", for: indexPath) as! MuscleHistoryTableViewCell
            cell.bottomConstraint.constant = 0
            return cell
        }

        if count == 1 {
            // only 1
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuscleHistoryTableViewCellBottom", for: indexPath) as! MuscleHistoryTableViewCell
            return cell
        }



        if (indexPath.row) == count {
            // last
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuscleHistoryTableViewCellBottom", for: indexPath) as! MuscleHistoryTableViewCell
            cell.topConstraint.constant = 0
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "MuscleHistoryTableViewCellMiddle", for: indexPath) as! MuscleHistoryTableViewCell
        cell.topConstraint.constant = 0
        cell.bottomConstraint.constant = 0
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return muscleSectionHeight
        }

        if indexPath.row == 0 {
            return 75
        }

        return 90
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BasicTableHeaderView") as! BasicTableHeaderView
        if section == 0 {
            view.titleLabel.text = "muscles invovled".uppercased()
        } else if section == 1 {
            view.titleLabel.text = "exercises".uppercased()

        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section <= 1 {
            return 55
        }

        return 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

class BasicTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var leadingTitleLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = Fonts.getScaledFont(textStyle: .subheadline, mode: .light)
        titleLabel.textColor = UIColor(red: 38/255.0, green: 38/255.0, blue: 43/255.0, alpha: 1.0)
        backgroundColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 248/255.0, alpha: 1.0)
    }
}

class MusclesInvolvedCell: UITableViewCell {
    var frontImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named:"front_muscles")!)
        // bigger
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    var backImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named:"back_muscles")!)
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    var musclesInvolvedView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        //v.layer.borderColor = UIColor(red: 233/255.0, green: 234/255.0, blue: 242/255.0, alpha: 1.0).cgColor
        //v.layer.borderWidth = 1.0
        return v
    }()

    var bottomGradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor(white: 1.0, alpha: 0.0).cgColor, UIColor(red: 246/255.0, green: 246/255.0, blue: 248/255.0, alpha: 1.0).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 0, y: 1.0)
        return g
    }()

    var bottomGradientView: UIView =  {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    @IBOutlet weak var musclesLabelContainerView: UIView!
    var stackView: UIStackView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    func commonInit() {
        stackView = UIStackView(arrangedSubviews: [frontImageView, backImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0

        addSubview(stackView)
        frontImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1).isActive = true
        frontImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.45).isActive = true

        backImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1).isActive = true
        backImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.45).isActive = true

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75).isActive = true
        //stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        //stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: musclesLabelContainerView.topAnchor).isActive = true

        backgroundColor = .clear//UIColor(red: 246/255.0, green: 246/255.0, blue: 248/255.0, alpha: 1.0)
        musclesLabelContainerView.backgroundColor = .clear

        musclesLabelContainerView.addSubview(musclesInvolvedView)
        musclesInvolvedView.topAnchor.constraint(equalTo: musclesLabelContainerView.topAnchor, constant: 0).isActive = true
        musclesInvolvedView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        musclesInvolvedView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true

        
        layoutMuscleViews()

        musclesInvolvedHeight = musclesInvolvedView.heightAnchor.constraint(equalToConstant: 0)
        musclesInvolvedHeight.isActive = true

        let multiLineSpacing: CGFloat = (CGFloat(muscleOrder.count) - 1) * 10
        let labelHeight: CGFloat = CGFloat(muscleOrder.count) * 38
        musclesInvolvedHeight.constant = multiLineSpacing + labelHeight + 16 + 16 /* to bottom*/
        musclesLabelContainerView.heightAnchor.constraint(equalToConstant: multiLineSpacing + labelHeight + 16 + 16 /* to bottom*/).isActive = true

        addSubview(bottomGradientView)
        bottomGradientView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0).isActive = true
        bottomGradientView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0).isActive = true
        bottomGradientView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0).isActive = true
        bottomGradientView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 0.19).isActive = true
        bottomGradientView.layer.insertSublayer(bottomGradientLayer, at: 0)

        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 233/255.0, green: 234/255.0, blue: 242/255.0, alpha: 1.0)
        addSubview(line)
        line.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    var muscleOrder = [[String]]()
    var musclesInvolvedHeight: NSLayoutConstraint!
    var muscleViews = [PaddingLabel]()
    var muscles: [String] = {
        var s = [String]()
        s.append("Chest")
        s.append("Triceps")
        s.append("Deltoids")
        s.append("Abs")
        s.append("Neck")
        s.append("Quad")
        s.append("Calves")
        s.append("Lower Back")
        return s
    }()

    private func layoutMuscleViews() {
        var newLineWidth: CGFloat = UIScreen.main.bounds.width - 24 - 24 // left and right padding
        var stringWidths = [String : CGFloat]()

        func createMuscleViews() {
            for m in muscles {
                let l = PaddingLabel()
                l.topInset = 10.0
                l.bottomInset = 10.0
                l.leftInset = 20.0
                l.rightInset = 20.0
                l.font = Fonts.getScaledFont(textStyle: .body, mode: .light)
                l.backgroundColor = UIColor(red: 112/255.0, green: 129/255.0, blue: 255/255.0, alpha: 1.0)
                l.layer.cornerRadius = 2.0
                l.clipsToBounds = true
                l.adjustsFontForContentSizeCategory = true
                l.textAlignment = NSTextAlignment.center
                l.textColor = .white
                l.translatesAutoresizingMaskIntoConstraints = false
                l.text = m
                musclesInvolvedView.addSubview(l)
                muscleViews.append(l)
            }
        }

        func createMuscleOrder() {
            var muscleTemp = [String]()
            for m in muscles {
                var width: CGFloat = 0
                if let mWidth = stringWidths[m] {
                    width = mWidth + 20.0 + 20.0
                }

                if newLineWidth - width < 0 {
                    muscleOrder.append(muscleTemp)
                    newLineWidth = UIScreen.main.bounds.width - 24 - 24
                    muscleTemp = [String]()
                    muscleTemp.append(m)
                } else {
                    muscleTemp.append(m)
                }
                newLineWidth -= width
                newLineWidth -= 10
            }
            muscleOrder.append(muscleTemp)
        }

        func calculateMuscleViewWidths() {
            for m in muscles {
                let s = NSString(string: m)
                let bounds = s.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Fonts.attributes(for: Fonts.getScaledFont(textStyle: .body, mode: .light)), context: nil)
                stringWidths[s as String] = bounds.width + 5
            }
        }

        func createConstraints() {
            var musclesLabelIdx: Int = 0
            var leftAlignedViews = [PaddingLabel]()
            for (row, muscles) in muscleOrder.enumerated() {
                for (idx, string) in muscles.enumerated() {
                    let currView = muscleViews[musclesLabelIdx]

                    if row == 0 && idx == 0 {
                        // First line, first item
                        currView.topAnchor.constraint(equalTo: musclesLabelContainerView.topAnchor, constant: 16).isActive = true
                        currView.leftAnchor.constraint(equalTo: musclesLabelContainerView.leftAnchor, constant: 24).isActive = true
                        currView.widthAnchor.constraint(equalToConstant: stringWidths[string]! + 20 + 20).isActive = true
                        currView.heightAnchor.constraint(equalToConstant: 38).isActive = true
                    } else if row > 0 && idx == 0, let lastAlignedLeftView = leftAlignedViews.last {
                        // all other lines, first item
                        currView.topAnchor.constraint(equalTo: lastAlignedLeftView.bottomAnchor, constant: 10).isActive = true
                        currView.leftAnchor.constraint(equalTo: lastAlignedLeftView.leftAnchor, constant: 0).isActive = true
                        currView.widthAnchor.constraint(equalToConstant: stringWidths[string]! + 20 + 20).isActive = true
                        currView.heightAnchor.constraint(equalToConstant: 38).isActive = true
                    } else if musclesLabelIdx > 0 {
                        let prevView = muscleViews[musclesLabelIdx - 1]

                        // Same line, not first
                        currView.leftAnchor.constraint(equalTo: prevView.rightAnchor, constant: 10).isActive = true
                        currView.bottomAnchor.constraint(equalTo: prevView.bottomAnchor, constant: 0).isActive = true
                        currView.heightAnchor.constraint(equalToConstant: 38).isActive = true
                        currView.widthAnchor.constraint(equalToConstant: stringWidths[string]! + 20 + 20).isActive = true
                    }

                    if idx == 0 {
                        leftAlignedViews.append(currView)
                    }

                    musclesLabelIdx += 1

                    if musclesLabelIdx >= self.muscles.count {
                        return
                    }
                }
            }
        }

        createMuscleViews()
        calculateMuscleViewWidths()
        createMuscleOrder()
        createConstraints()
    }
}

protocol MusclesInvolvedLayout: class {
    var muscleOrder: [[String]] { get set }
    var musclesInvolvedHeight: NSLayoutConstraint { get set }
    var muscleViews: [PaddingLabel]  { get set }
    var muscles: [String] { get set }
    var leftInset: CGFloat { get set }
    var rightInset: CGFloat { get set }
    var musclesInvolvedView: UIView { get set }
    var stringWidths: [String : CGFloat] { get set }
}

protocol MusclesInvolvedCalculate: class {
    var muscleOrder: [[String]] { get set }
    var muscles: [String] { get set }
    var leftInset: CGFloat { get set }
    var rightInset: CGFloat { get set }
    var stringWidths: [String : CGFloat] { get set }
    var newLineWidth: CGFloat { get set }
}

extension MusclesInvolvedCalculate {
    func createMuscleOrder() {
        var muscleTemp = [String]()
        for m in muscles {
            var width: CGFloat = 0
            if let mWidth = stringWidths[m] {
                width = mWidth + 20.0 + 20.0
            }

            if newLineWidth - width < 0 {
                muscleOrder.append(muscleTemp)
                newLineWidth = UIScreen.main.bounds.width - leftInset - rightInset
                muscleTemp = [String]()
                muscleTemp.append(m)
            } else {
                muscleTemp.append(m)
            }
            newLineWidth -= width
            newLineWidth -= 10
        }
        muscleOrder.append(muscleTemp)
    }

    func calculateMuscleViewWidths() {
        for m in muscles {
            let s = NSString(string: m)
            let bounds = s.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Fonts.attributes(for: Fonts.getScaledFont(textStyle: .body, mode: .light)), context: nil)
            stringWidths[s as String] = bounds.width + 5
        }
    }
}

extension MusclesInvolvedLayout {
    func createMuscleViews() {
        for m in muscles {
            let l = PaddingLabel()
            l.topInset = 10.0
            l.bottomInset = 10.0
            l.leftInset = 20.0
            l.rightInset = 20.0
            l.font = Fonts.getScaledFont(textStyle: .body, mode: .light)
            l.backgroundColor = UIColor(red: 112/255.0, green: 129/255.0, blue: 255/255.0, alpha: 1.0)
            l.layer.cornerRadius = 2.0
            l.clipsToBounds = true
            l.adjustsFontForContentSizeCategory = true
            l.textAlignment = NSTextAlignment.center
            l.textColor = .white
            l.translatesAutoresizingMaskIntoConstraints = false
            l.text = m
            musclesInvolvedView.addSubview(l)
            muscleViews.append(l)
        }
    }

    func createConstraints(with anchorView: UIView) {
        var musclesLabelIdx: Int = 0
        var leftAlignedViews = [PaddingLabel]()
        for (row, muscles) in muscleOrder.enumerated() {
            for (idx, string) in muscles.enumerated() {
                let currView = muscleViews[musclesLabelIdx]

                if row == 0 && idx == 0 {
                    // First line, first item
                    currView.topAnchor.constraint(equalTo: anchorView.topAnchor, constant: 16).isActive = true
                    currView.leftAnchor.constraint(equalTo: anchorView.leftAnchor, constant: 24).isActive = true
                    currView.widthAnchor.constraint(equalToConstant: stringWidths[string]! + 20 + 20).isActive = true
                    currView.heightAnchor.constraint(equalToConstant: 38).isActive = true
                } else if row > 0 && idx == 0, let lastAlignedLeftView = leftAlignedViews.last {
                    // all other lines, first item
                    currView.topAnchor.constraint(equalTo: lastAlignedLeftView.bottomAnchor, constant: 10).isActive = true
                    currView.leftAnchor.constraint(equalTo: lastAlignedLeftView.leftAnchor, constant: 0).isActive = true
                    currView.widthAnchor.constraint(equalToConstant: stringWidths[string]! + 20 + 20).isActive = true
                    currView.heightAnchor.constraint(equalToConstant: 38).isActive = true
                } else if musclesLabelIdx > 0 {
                    let prevView = muscleViews[musclesLabelIdx - 1]

                    // Same line, not first
                    currView.leftAnchor.constraint(equalTo: prevView.rightAnchor, constant: 10).isActive = true
                    currView.bottomAnchor.constraint(equalTo: prevView.bottomAnchor, constant: 0).isActive = true
                    currView.heightAnchor.constraint(equalToConstant: 38).isActive = true
                    currView.widthAnchor.constraint(equalToConstant: stringWidths[string]! + 20 + 20).isActive = true
                }

                if idx == 0 {
                    leftAlignedViews.append(currView)
                }

                musclesLabelIdx += 1

                if musclesLabelIdx >= self.muscles.count {
                    return
                }
            }
        }
    }
}

class MuscleHistoryTopTableViewCell: UITableViewCell {

}

class MuscleHistoryTableViewCell: UITableViewCell {
    static let TopPadding: CGFloat = 20.0
    static let BottomPadding: CGFloat = 10.0

    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
}
