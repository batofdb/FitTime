//
//  Filter.swift
//  FitTime
//
//  Created by Francis Bato on 2/15/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//

import UIKit

struct FilterDatasource {
    var title: String
    var datasource: [FilterObject] = [FilterObject]()
}

struct FilterObject {
    var title: String
}

class FilterCollectionViewCell: UICollectionViewCell {
    static let UnselectedColor: UIColor = UIColor(red: 112/255.0, green: 129/255.0, blue: 255/255.0, alpha: 1.0)
    static let SelectedColor: UIColor = UIColor(red: 233/255.0, green: 234/255.0, blue: 242/255.0, alpha: 1.0)
    static let SelectedTextColor: UIColor = UIColor(red: 38/255.0, green: 38/255.0, blue: 43/255.0, alpha: 1.0)
    static let UnselectedTextColor: UIColor = .white

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 2.0
        clipsToBounds = true

        titleLabel.font = Fonts.getScaledFont(textStyle: .body, mode: .light)
        titleLabel.textColor = FilterCollectionViewCell.UnselectedTextColor
        backgroundColor = FilterCollectionViewCell.UnselectedColor
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                titleLabel.textColor = FilterCollectionViewCell.SelectedTextColor
                backgroundColor = FilterCollectionViewCell.SelectedColor
            } else {
                titleLabel.textColor = FilterCollectionViewCell.UnselectedTextColor
                backgroundColor = FilterCollectionViewCell.UnselectedColor
            }
        }
    }
}

class FilterViewController: UIViewController {
    static let Inset: CGFloat = 24

    var backgroundGradientLayer: CAGradientLayer =  {
        let c = CAGradientLayer()
        return c
    }()

    var ctaButtonGradientLayer: CAGradientLayer =  {
        let c = CAGradientLayer()
        return c
    }()

    var collectionView: UICollectionView = {
        let cvl = UICollectionViewFlowLayout()

        let cv = UICollectionView(frame: .zero, collectionViewLayout: cvl)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    var closeButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(named: "close_button"), for: .normal)
        return b
    }()

    var applyButton: UIButton = {
        let b = UIButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Apply".uppercased(), for: .normal)
        b.titleLabel?.textColor = .white
        b.titleLabel?.font = UIFont(name: Fonts.FontFamily.rubikMedium.rawValue, size: 15.0)!
        return b
    }()

    var titleLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Filter"
        l.textColor = .white
        l.font = Fonts.getScaledFont(textStyle: .headline, mode: .light)
        return l
    }()

    var gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor(red: 80/255.0, green: 99/255.0, blue: 238/255.0, alpha: 1.0).cgColor, UIColor(red: 35/255.0, green: 37/255.0, blue: 58/255.0, alpha: 1.0).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1.0, y: 1.0)
        return g
    }()

    var buttonGradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor(red: 80/255.0, green: 99/255.0, blue: 238/255.0, alpha: 1.0).cgColor, UIColor(red: 35/255.0, green: 37/255.0, blue: 58/255.0, alpha: 1.0).cgColor]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1.0, y: 0.5)
        return g
    }()

    var cellSizes: [String : CGSize] = [String : CGSize]()
    var datasource: [FilterDatasource]
    var applyButtonBottomConstraint: NSLayoutConstraint!
    var applyButtonHeightConstraint: NSLayoutConstraint!
    required init(datasource: [FilterDatasource]) {
        self.datasource = datasource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)

        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(applyButton)

        closeButton.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 56).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true

        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 92).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        //titleLabel.heightAnchor.constraint(constant: 35).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 24).isActive = true

        applyButtonHeightConstraint = applyButton.heightAnchor.constraint(equalToConstant: 64.0)
        applyButtonHeightConstraint.isActive = true
        applyButton.widthAnchor.constraint(equalToConstant: 208.0).isActive = true
        applyButtonBottomConstraint = applyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -56)
        applyButtonBottomConstraint.isActive = true
        applyButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true

        collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true

        closeButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)

        collectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")

        let strings: [String] = datasource.flatMap{ $0.datasource.compactMap{ $0.title } }
        for s in strings {
            let s = NSString(string: s)
            let bounds = s.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Fonts.attributes(for: Fonts.getScaledFont(textStyle: .body, mode: .light)), context: nil)
            cellSizes[s as String] = CGSize(width: bounds.width + 20 + 20 + 5/* errors*/, height: bounds.height + 10 + 10)
        }

        let leftLayout = LeftAlignedCollectionViewFlowLayout()
        leftLayout.sectionInset = UIEdgeInsets(top: 0, left: FilterViewController.Inset, bottom:FilterViewController.Inset, right: FilterViewController.Inset)
        collectionView.collectionViewLayout = leftLayout
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, applyButtonHeightConstraint.constant + abs(applyButtonBottomConstraint.constant) + 13, 0)
        collectionView.allowsMultipleSelection = true

        collectionView.register(UINib(nibName: "BasicHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BasicHeaderView")

        view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = view.bounds

        applyButton.layer.insertSublayer(buttonGradientLayer, at: 0)
        buttonGradientLayer.frame = applyButton.bounds
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        buttonGradientLayer.frame = applyButton.bounds
    }

    @objc func closeButtonTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = datasource[section]
        return section.datasource.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datasource.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width - FilterViewController.Inset - FilterViewController.Inset, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BasicHeaderView", for: indexPath) as! BasicHeaderView
        let section = datasource[indexPath.section]
        v.titleLabel.text = section.title.uppercased()
        if v.leadingTitleLabelConstraint.constant != FilterViewController.Inset {
            v.leadingTitleLabelConstraint.constant = FilterViewController.Inset
        }
        return v
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        let section = datasource[indexPath.section]
        cell.titleLabel.text = section.datasource[indexPath.row].title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        if let cell = collectionView.cellForItem(at: indexPath) {
//            cell.isSelected = !cell.isSelected
//        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = datasource[indexPath.section].datasource[indexPath.row]
        if let s = cellSizes[item.title] {
            return s
        }

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

open class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    /// The width of the area inside the collection view that can be filled with cells.
    private var contentWidth: CGFloat? {
        guard let collectionViewWidth = collectionView?.frame.size.width else {
            return nil
        }
        return collectionViewWidth - sectionInset.left - sectionInset.right
    }

    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        layoutAttributes.alignHorizontally(collectionViewLayout: self)
        layoutAttributes.alignVertically(collectionViewLayout: self)
        return layoutAttributes
    }

    fileprivate func originalLayoutAttribute(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }

    fileprivate func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes, inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let lineWidth = contentWidth else {
            return false
        }
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(x: sectionInset.left,
                               y: firstItemFrame.origin.y,
                               width: lineWidth,
                               height: firstItemFrame.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // We may not change the original layout attributes or UICollectionViewFlowLayout might complain.
        let layoutAttributesObjects = copy(super.layoutAttributesForElements(in: rect))
        let headers = layoutAttributesObjects?.filter { $0.representedElementKind == UICollectionElementKindSectionHeader }

        let footers = layoutAttributesObjects?.filter { $0.representedElementKind == UICollectionElementKindSectionFooter }

        let leadingRowYOrigins = layoutAttributesObjects?.filter { $0.indexPath.row == 0 && $0.representedElementCategory == .cell }.map { $0.frame.origin.y }

        layoutAttributesObjects?.forEach({ (layoutAttributes) in
            var header: UICollectionViewLayoutAttributes?
            var footer: UICollectionViewLayoutAttributes?
            var leadingRowY: CGFloat?

            if let h = headers, h.indices.contains(layoutAttributes.indexPath.section) {
                header = headers?[layoutAttributes.indexPath.section]
            }

            if let f = footers, f.indices.contains(layoutAttributes.indexPath.section) {
                footer = footers?[layoutAttributes.indexPath.section]
            }

            if let lr = leadingRowYOrigins, lr.indices.contains(layoutAttributes.indexPath.section) {
                leadingRowY = lr[layoutAttributes.indexPath.section]
            }

            setFrame(forLayoutAttributes: layoutAttributes, header: header, footer: footer, leadingRowOriginY: leadingRowY)
        })
        return layoutAttributesObjects
    }

    fileprivate func layoutAttributes(forItemsInLineWith layoutAttributes: UICollectionViewLayoutAttributes) -> [UICollectionViewLayoutAttributes] {
        guard let lineWidth = contentWidth else {
            return [layoutAttributes]
        }
        var lineFrame = layoutAttributes.frame
        lineFrame.origin.x = sectionInset.left
        lineFrame.size.width = lineWidth
        return super.layoutAttributesForElements(in: lineFrame) ?? []
    }

    /// Sets the frame for the passed layout attributes object by calling the `layoutAttributesForItem(at:)` function.
    private func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes, header: UICollectionViewLayoutAttributes?, footer: UICollectionViewLayoutAttributes?, leadingRowOriginY: CGFloat?) {
        if layoutAttributes.representedElementCategory == .cell { // Do not modify header views etc.
            let indexPath = layoutAttributes.indexPath
            if var newFrame = layoutAttributesForItem(at: indexPath)?.frame {
                if let firstRowY = leadingRowOriginY, let h = header?.frame.height, newFrame.origin.y + h == firstRowY {
                    newFrame.origin.y = newFrame.origin.y + h
                }

                layoutAttributes.frame = newFrame
            }
        }
    }

    private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
    }

    private func verticalAlignmentAxisForLine(with layoutAttributes: [UICollectionViewLayoutAttributes]) -> CGFloat? {

        guard let _ = layoutAttributes.first else {
            return nil
        }

        let minY = layoutAttributes.reduce(CGFloat.greatestFiniteMagnitude) { min($0, $1.frame.minY) }
        return minY

//        switch verticalAlignment {
//        case .top:
//            let minY = layoutAttributes.reduce(CGFloat.greatestFiniteMagnitude) { min($0, $1.frame.minY) }
//            return AlignmentAxis(alignment: .top, position: minY)
//
//        case .bottom:
//            let maxY = layoutAttributes.reduce(0) { max($0, $1.frame.maxY) }
//            return AlignmentAxis(alignment: .bottom, position: maxY)
//
//        default:
//            let centerY = firstAttribute.center.y
//            return AlignmentAxis(alignment: .center, position: centerY)
//        }
    }

    fileprivate func verticalAlignmentAxis(for currentLayoutAttributes: UICollectionViewLayoutAttributes) -> CGFloat {
        let layoutAttributesInLine = layoutAttributes(forItemsInLineWith: currentLayoutAttributes)
        // It's okay to force-unwrap here because we pass a non-empty array.
        return verticalAlignmentAxisForLine(with: layoutAttributesInLine)!
    }
}

fileprivate extension UICollectionViewLayoutAttributes {
    private var currentSection: Int {
        return indexPath.section
    }

    private var currentItem: Int {
        return indexPath.item
    }

    /// The index path for the item preceding the item represented by this layout attributes object.
    private var precedingIndexPath: IndexPath {
        return IndexPath(item: currentItem - 1, section: currentSection)
    }

    /// The index path for the item following the item represented by this layout attributes object.
    private var followingIndexPath: IndexPath {
        return IndexPath(item: currentItem + 1, section: currentSection)
    }

    /// Checks if the item represetend by this layout attributes object is the first item in the line.
    ///
    /// - Parameter collectionViewLayout: The layout for which to perform the check.
    /// - Returns: `true` if the represented item is the first item in the line, else `false`.
    func isRepresentingFirstItemInLine(collectionViewLayout: LeftAlignedCollectionViewFlowLayout) -> Bool {
        if currentItem <= 0 {
            return true
        }
        else {
            if let layoutAttributesForPrecedingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: precedingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForPrecedingItem)
            }
            else {
                return true
            }
        }
    }

    /// Checks if the item represetend by this layout attributes object is the last item in the line.
    ///
    /// - Parameter collectionViewLayout: The layout for which to perform the check.
    /// - Returns: `true` if the represented item is the last item in the line, else `false`.
    func isRepresentingLastItemInLine(collectionViewLayout: LeftAlignedCollectionViewFlowLayout) -> Bool {
        guard let itemCount = collectionViewLayout.collectionView?.numberOfItems(inSection: currentSection) else {
            return false
        }

        if currentItem >= itemCount - 1 {
            return true
        }
        else {
            if let layoutAttributesForFollowingItem = collectionViewLayout.originalLayoutAttribute(forItemAt: followingIndexPath) {
                return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: layoutAttributesForFollowingItem)
            }
            else {
                return true
            }
        }
    }

    /// Moves the layout attributes object's frame so that it is aligned vertically with the alignment axis.
    func alignToHorizontal(posititon: CGFloat) {
        frame.origin.x = posititon
    }

    /// Positions the frame right of the preceding item's frame, leaving a spacing between the frames
    /// as defined by the collection view layout's `minimumInteritemSpacing`.
    ///
    /// - Parameter collectionViewLayout: The layout on which to perfom the calculations.
    private func alignToPrecedingItem(collectionViewLayout: LeftAlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing

        if let precedingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: precedingIndexPath) {
            frame.origin.x = precedingItemAttributes.frame.maxX + itemSpacing
        }
    }

    /// Positions the frame left of the following item's frame, leaving a spacing between the frames
    /// as defined by the collection view layout's `minimumInteritemSpacing`.
    ///
    /// - Parameter collectionViewLayout: The layout on which to perfom the calculations.
    private func alignToFollowingItem(collectionViewLayout: LeftAlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing

        if let followingItemAttributes = collectionViewLayout.layoutAttributesForItem(at: followingIndexPath) {
            frame.origin.x = followingItemAttributes.frame.minX - itemSpacing - frame.size.width
        }
    }

    func alignHorizontally(collectionViewLayout: LeftAlignedCollectionViewFlowLayout) {
        if isRepresentingFirstItemInLine(collectionViewLayout: collectionViewLayout) {
            alignToHorizontal(posititon: collectionViewLayout.sectionInset.left)
        } else {
            alignToPrecedingItem(collectionViewLayout: collectionViewLayout)
        }
    }

    func alignVertically(collectionViewLayout: LeftAlignedCollectionViewFlowLayout) {
        let alignmentAxis = collectionViewLayout.verticalAlignmentAxis(for: self)
        alignToVertical(position: alignmentAxis)
    }

    func alignToVertical(position: CGFloat) {
        frame.origin.y = position
    }
}

class BasicHeaderView: UICollectionReusableView {
    @IBOutlet weak var leadingTitleLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = Fonts.getScaledFont(textStyle: .subheadline, mode: .light)
        titleLabel.textColor = .white
    }
}
