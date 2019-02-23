//
//  Exercise.swift
//  FitTime
//
//  Created by Francis Bato on 2/20/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//
import UIKit

class ExerciseDetailViewController: UIViewController {
    var navigationView: FitTimeNavigationBar = {
        let nav = FitTimeNavigationBar()
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.backgroundColor = .white
        nav.titleLabel.textColor = .black
        nav.subTitleLabel.isHidden = true
        nav.gradientLayer.removeFromSuperlayer()
        nav.update(type: .basic)
        nav.leftButton.setImage(UIImage(named: "back_button"), for: .normal)
        nav.rightButton.setImage(UIImage(named: "add"), for: .normal)
        nav.rightButton.setTitle(nil, for: .normal)
        return nav
    }()

    var exercise: String? {
        didSet {
            navigationView.titleLabel.text = self.exercise
        }
    }

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

    var pageControl: FitTimePageControl = {
        let pc = FitTimePageControl(frame: .zero)
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = .clear
        pc.pageIndicatorTintColor = .clear
        return pc
    }()

    @IBOutlet weak var containerToTop: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerView: UIView!

    var pageViewController: ExerciseDetailPageViewController?
    var musclesInvolvedView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.borderColor = UIColor(displayP3Red: 233/255.0, green: 234/255.0, blue: 242/255.0, alpha: 1.0).cgColor
        v.layer.borderWidth = 1.0
        return v
    }()

    var musclesTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = Fonts.getScaledFont(textStyle: .subheadline, mode: .dark)
        l.textColor = UIColor(displayP3Red: 38/255.0, green: 38/255.0, blue: 43/255.0, alpha: 1.0)
        l.text = "muscles involved".uppercased()
        return l
    }()

    var musclesInvolvedHeight: NSLayoutConstraint!

    var muscleViews = [PaddingLabel]()
    var muscleOrder = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(navigationView)
        navigationView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigationView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: 140).isActive = true

        navigationView.leftButtonTappedHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        exercise = "Deadlift"
        containerToTop.constant = 140.0

        view.addSubview(pageControl)
        pageControl.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true

        if let vc = pageViewController {
            pageControl.numberOfPages = vc.orderedViewControllers.count
        }

        view.addSubview(musclesInvolvedView)
        musclesInvolvedView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 0).isActive = true
        musclesInvolvedView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.1).isActive = true
        musclesInvolvedView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true

        musclesInvolvedView.addSubview(musclesTitle)

        musclesTitle.topAnchor.constraint(equalTo: musclesInvolvedView.topAnchor, constant: 24).isActive = true
        musclesTitle.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        musclesTitle.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24.0).isActive = true
        musclesTitle.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true

        layoutMuscleViews()

        musclesInvolvedHeight = musclesInvolvedView.heightAnchor.constraint(equalToConstant: 0)
        musclesInvolvedHeight.isActive = true

        let multiLineSpacing: CGFloat = (CGFloat(muscleOrder.count) - 1) * 10
        let labelHeight: CGFloat = CGFloat(muscleOrder.count) * 38
        musclesInvolvedHeight.constant = 25 /*top*/ + 20 /*muscle title height */+ 16 /* to involved */ + multiLineSpacing + labelHeight + 16 /* to bottom*/
    }

    private func layoutMuscleViews() {
        var newLineWidth: CGFloat = view.bounds.width - 24 - 24 // left and right padding
        var stringWidths = [String : CGFloat]()

        func createMuscleViews() {
            for m in muscles {
                let l = PaddingLabel()
                l.topInset = 10.0
                l.bottomInset = 10.0
                l.leftInset = 20.0
                l.rightInset = 20.0
                l.font = Fonts.getScaledFont(textStyle: .body, mode: .light)
                l.backgroundColor = UIColor(displayP3Red: 112/255.0, green: 129/255.0, blue: 255/255.0, alpha: 1.0)
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
                    newLineWidth = view.bounds.width - 24 - 24
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
                        currView.topAnchor.constraint(equalTo: musclesTitle.bottomAnchor, constant: 16).isActive = true
                        currView.leftAnchor.constraint(equalTo: musclesTitle.leftAnchor, constant: 0).isActive = true
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageControl.setPage(index: pageControl.currentPage)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ExerciseDetailPageViewController {
            pageViewController = vc


            pageViewController?.currentIndexUpdated = { [weak self] index in
                self?.pageControl.setPage(index: index)
            }
        }
    }
}

class ExerciseDetailPageViewController: UIPageViewController {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var vcs = [UIViewController]()
        vcs.append(MuscleDiagramViewController(muscle: .bicep_inner))
        vcs.append(ExerciseVideoViewController())
        return vcs
    }()

    var currentIndexUpdated: ((Int) -> Void)? = nil

    var currentIndex: Int {
        get {
            if let vcs = viewControllers, let f = vcs.first, let idx = orderedViewControllers.index(of: f) {
                return idx
            }

            return 0
        }

        set {
            guard newValue >= 0,
                newValue < orderedViewControllers.count else {
                    return
            }

            let vc = orderedViewControllers[newValue]
            let direction:UIPageViewControllerNavigationDirection = newValue > currentIndex ? .forward : .reverse
            self.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let f = orderedViewControllers.first {
            setViewControllers([f], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension ExerciseDetailPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }

        currentIndexUpdated?(currentIndex)
    }
}

extension ExerciseDetailPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}

class ExerciseVideoViewController: UIViewController {
    var videoView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .black
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(videoView)

        videoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        videoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        videoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
    }
}

class MuscleDiagramViewController: UIViewController {
    var frontImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named:"front_muscles")!)
        // bigger
        imgView.contentMode = UIViewContentMode.scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    var backImageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named:"back_muscles")!)
        imgView.contentMode = UIViewContentMode.scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    var stackView: UIStackView!

    init(muscle: MuscleType) {
        super.init(nibName: nil, bundle: nil)
        switch muscle {
        case .bicep_inner:
            break
        default:
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView = UIStackView(arrangedSubviews: [frontImageView, backImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 32.0

        view.addSubview(stackView)
        frontImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true
        frontImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35).isActive = true

        backImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true
        backImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35).isActive = true

        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true


    }
}

class FitTimePageControl: UIPageControl {
    let activeImage:UIImage = UIImage(named: "active_page")!
    let inactiveImage:UIImage = UIImage(named: "inactive_page")!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
    }

    public func setPage(index: Int) {
        super.currentPage = index
        updateDots()
    }

    func updateDots() {
        var i = 0
        var centerYActive: CGFloat = 0.0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
                    imageView.image = self.activeImage
                    imageView.bounds.size = self.activeImage.size
                    centerYActive = imageView.center.y
                } else {
                    imageView.image = self.inactiveImage
                    imageView.bounds.size = self.inactiveImage.size
                }

                i = i + 1
            } else {
                var dotImage = self.inactiveImage
                if i == self.currentPage {
                    dotImage = self.activeImage
                }
                view.clipsToBounds = false
                view.addSubview(UIImageView(image:dotImage))
                i = i + 1
            }
        }

        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i != self.currentPage {
                    imageView.center = CGPoint(x: imageView.center.x, y: centerYActive)
                }
                i = i + 1
            }
        }
    }

    fileprivate func imageForSubview(_ view:UIView) -> UIImageView? {
        var dot:UIImageView?

        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }

        return dot
    }
}
