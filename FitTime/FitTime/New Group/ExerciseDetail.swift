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
        pageControl.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true

        if let vc = pageViewController {
            pageControl.numberOfPages = vc.orderedViewControllers.count
        }
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
        frontImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
        frontImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true

        backImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
        backImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true

        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
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
