//
//  ReadMoreLessView.swift
//
//  Created by Stefano Frosoni on 26/02/16.
//  Copyright © 2016 Stefano Frosoni. All rights reserved.
//

import Foundation
import UIKit

protocol ReadMoreLessViewDelegate: class {
    func didChangeState(readMoreLessView: ReadMoreLessView)
}

@IBDesignable class ReadMoreLessView : UIView {
    
    @IBInspectable var maxNumberOfLinesCollapsed: Int = 5
    
    @IBInspectable var titleColor: UIColor = .blackColor() {
        didSet{
            titleLabel.textColor = titleColor
        }
    }
    
    @IBInspectable var bodyColor: UIColor = .darkGrayColor() {
        didSet{
            bodyLabel.textColor = bodyColor
        }
    }
    
    @IBInspectable var buttonColor: UIColor = .orangeColor() {
        didSet{
            moreLessButton.setTitleColor(buttonColor, forState: .Normal)
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet{
             layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var titleLabelFont: UIFont = .systemFontOfSize(15) {
        didSet{
            titleLabel.font = titleLabelFont
        }
    }
    
    @IBInspectable var bodyLabelFont: UIFont = .systemFontOfSize(14) {
        didSet{
            bodyLabel.font = bodyLabelFont
        }
    }
    
    @IBInspectable var moreLessButtonFont: UIFont = .systemFontOfSize(12) {
        didSet{
            moreLessButton.titleLabel!.font = moreLessButtonFont
        }
    }
    
    var moreText = NSLocalizedString("SHOW MORE", comment: "Show More")
    var lessText = NSLocalizedString("SHOW LESS", comment: "Show Less")

    private var previousTopLayoutConstraintConstant: CGFloat = 0
    
    private enum ReadMoreLessViewState {
        case Collapsed
        case Expanded
        
        mutating func toggle() {
            switch self {
            case .Collapsed:
                self = .Expanded
            case .Expanded:
                self = .Collapsed
            }
        }
    }
    
    weak var delegate: ReadMoreLessViewDelegate?
    
    private var state: ReadMoreLessViewState = .Collapsed {
        didSet {
            switch state {
            case .Collapsed:
                bodyLabel.lineBreakMode = .ByTruncatingTail
                bodyLabel.numberOfLines = maxNumberOfLinesCollapsed
                moreLessButton.setTitle(moreText, forState: UIControlState.Normal)
            case .Expanded:
                bodyLabel.lineBreakMode = .ByWordWrapping
                bodyLabel.numberOfLines = 0
                moreLessButton.setTitle(lessText, forState: UIControlState.Normal)
            }
            
            invalidateIntrinsicContentSize()
            delegate?.didChangeState(self)
        }
    }
    
    func buttonTouched(sender: UIButton) {
        state.toggle()
    }
    
    lazy private var moreLessButton: UIButton! = {
        let button = UIButton(frame: CGRectZero)
        button.backgroundColor = UIColor.clearColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "buttonTouched:", forControlEvents: .TouchUpInside)
        button.setTitleColor(.orangeColor(), forState: .Normal)
        return button
    }()
    
    lazy private var titleLabel: UILabel! = {
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        label.textColor = .blackColor()
        
        return label
    }()
    
    lazy private var bodyLabel: UILabel! = {
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .blackColor()
        return label
    }()
    
    
    // MARK: Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    
    func initComponents() {
        titleLabel.font = titleLabelFont
        titleLabel.textColor = titleColor
        
        bodyLabel.font = bodyLabelFont
        bodyLabel.textColor = bodyColor
        
        moreLessButton.titleLabel!.font = moreLessButtonFont
        moreLessButton.setTitleColor(buttonColor, forState: .Normal)
        
    }
    
    // MARK: Private
    
    private func configureViews() {
        state = .Collapsed
        
        addSubview(titleLabel)
        addSubview(bodyLabel)
        addSubview(moreLessButton)
        
        let views = ["titleLabel": titleLabel, "bodyLabel": bodyLabel, "moreLessButton": moreLessButton]
        let horizontalConstraintsTitle = NSLayoutConstraint.constraintsWithVisualFormat("H:|-2-[titleLabel]-2-|", options: .AlignAllBaseline, metrics: nil, views: views)
        let horizontalConstraintsBody = NSLayoutConstraint.constraintsWithVisualFormat("H:|-2-[bodyLabel]-2-|", options: .AlignAllBaseline, metrics: nil, views: views)
        let horizontalConstraintsButton = NSLayoutConstraint.constraintsWithVisualFormat("H:|-2-[moreLessButton]-2-|", options: .AlignAllBaseline, metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-2-[titleLabel]-2-[bodyLabel]-2-[moreLessButton]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(horizontalConstraintsTitle + horizontalConstraintsBody + horizontalConstraintsButton + verticalConstraints )
        
        initComponents()
    }
    
    func setText(title: String, body: String) {
        guard let titleLabel = titleLabel, let bodyLabel = bodyLabel else { return }
        bodyLabel.layoutIfNeeded()
        
        titleLabel.text = title
        bodyLabel.text = body
        
        if (body ?? "").isEmpty {
            titleLabel.text = nil
            moreLessButton.hidden = true
            moreLessButton.enabled = false
        } else {
            moreLessButton.hidden = false
            moreLessButton.enabled = true
        }
        
        bodyLabel.layoutIfNeeded()
        
        if bodyLabel.text!.isEmpty || (countLabelLines(bodyLabel) <= maxNumberOfLinesCollapsed) {
            moreLessButton.hidden = true
            moreLessButton.enabled = false
        }
    }
    
    private func countLabelLines(label: UILabel) -> Int {
        self.layoutIfNeeded()
        let myText = label.text! as NSString
        let attributes = [NSFontAttributeName : label.font]
        let labelSize = myText.boundingRectWithSize(CGSizeMake(label.bounds.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    
    // MARK: Interface Builder
    
    override func prepareForInterfaceBuilder() {
        self.layoutSubviews()
        let titleText = "Text for Title label"
        let bodytext = "Lorem ipsum dolor sit amet, eam eu veri corpora, eu sit zril eirmod integre, his purto quaestio ut."
        setText(titleText, body: bodytext)
    }

}
