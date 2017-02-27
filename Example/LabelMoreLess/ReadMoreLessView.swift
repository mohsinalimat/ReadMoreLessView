//
//  ReadMoreLessView.swift
//
//  Created by Stefano Frosoni on 26/02/16.
//  Copyright © 2016 Stefano Frosoni. All rights reserved.
//

import Foundation
import UIKit

protocol ReadMoreLessViewDelegate: class {
    func didChangeState(_ readMoreLessView: ReadMoreLessView)
}

@IBDesignable class ReadMoreLessView : UIView {
    
    @IBInspectable var maxNumberOfLinesCollapsed: Int = 5
    fileprivate var kvoContext = 0
    
    @IBInspectable var titleColor: UIColor = .black {
        didSet{
            titleLabel.textColor = titleColor
        }
    }
    
    @IBInspectable var bodyColor: UIColor = .darkGray {
        didSet{
            bodyLabel.textColor = bodyColor
        }
    }
    
    @IBInspectable var buttonColor: UIColor = .orange {
        didSet{
            moreLessButton.setTitleColor(buttonColor, for: UIControlState())
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet{
             layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var titleLabelFont: UIFont = .systemFont(ofSize: 15) {
        didSet{
            titleLabel.font = titleLabelFont
        }
    }
    
    @IBInspectable var bodyLabelFont: UIFont = .systemFont(ofSize: 14) {
        didSet{
            bodyLabel.font = bodyLabelFont
        }
    }
    
    @IBInspectable var moreLessButtonFont: UIFont = .systemFont(ofSize: 12) {
        didSet{
            moreLessButton.titleLabel!.font = moreLessButtonFont as UIFont
        }
    }
    
    var moreText = NSLocalizedString("SHOW MORE", comment: "Show More")
    var lessText = NSLocalizedString("SHOW LESS", comment: "Show Less")

    fileprivate enum ReadMoreLessViewState {
        case collapsed
        case expanded
        
        mutating func toggle() {
            switch self {
            case .collapsed:
                self = .expanded
            case .expanded:
                self = .collapsed
            }
        }
    }
    
    weak var delegate: ReadMoreLessViewDelegate?
    
    fileprivate var state: ReadMoreLessViewState = .collapsed {
        didSet {
            switch state {
            case .collapsed:
                bodyLabel.lineBreakMode = .byTruncatingTail
                bodyLabel.numberOfLines = maxNumberOfLinesCollapsed
                moreLessButton.setTitle(moreText, for: UIControlState())
            case .expanded:
                bodyLabel.lineBreakMode = .byWordWrapping
                bodyLabel.numberOfLines = 0
                moreLessButton.setTitle(lessText, for: UIControlState())
            }
            
            invalidateIntrinsicContentSize()
            delegate?.didChangeState(self)
        }
    }
    
    func buttonTouched(_ sender: UIButton) {
        state.toggle()
    }
    
    lazy fileprivate var moreLessButton: UIButton! = {
        let button = UIButton(frame: CGRect.zero)
        button.backgroundColor = UIColor.clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(ReadMoreLessView.buttonTouched(_:)), for: .touchUpInside)
        button.setTitleColor(.orange, for: UIControlState())
        return button
    }()
    
    lazy fileprivate var titleLabel: UILabel! = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        
        return label
    }()
    
    lazy fileprivate var bodyLabel: UILabel! = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .black
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
    
    
    fileprivate func initComponents() {
        titleLabel.font = titleLabelFont
        titleLabel.textColor = titleColor
        
        bodyLabel.font = bodyLabelFont
        bodyLabel.textColor = bodyColor
        
        moreLessButton.titleLabel!.font = moreLessButtonFont
        moreLessButton.setTitleColor(buttonColor, for: UIControlState())
        bodyLabel.layer.addObserver(self, forKeyPath: "bounds", options: [], context: &kvoContext)
    }
    
    // MARK: Private
    
    fileprivate func configureViews() {
        state = .collapsed
        
        addSubview(titleLabel)
        addSubview(bodyLabel)
        addSubview(moreLessButton)
        
        let views = ["titleLabel": titleLabel, "bodyLabel": bodyLabel, "moreLessButton": moreLessButton] as [String : Any]
        let horizontalConstraintsTitle = NSLayoutConstraint.constraints(withVisualFormat: "H:|-6-[titleLabel]-6-|", options: .alignAllLastBaseline, metrics: nil, views: views)
        let horizontalConstraintsBody = NSLayoutConstraint.constraints(withVisualFormat: "H:|-6-[bodyLabel]-6-|", options: .alignAllLastBaseline, metrics: nil, views: views)
        let horizontalConstraintsButton = NSLayoutConstraint.constraints(withVisualFormat: "H:|-6-[moreLessButton]-6-|", options: .alignAllLastBaseline, metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[titleLabel]-4-[bodyLabel]-4-[moreLessButton]-4-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activate(horizontalConstraintsTitle + horizontalConstraintsBody + horizontalConstraintsButton + verticalConstraints )
        
        initComponents()
    }
    
    func setText(_ title: String, body: String) {
        guard let titleLabel = titleLabel, let bodyLabel = bodyLabel else { return }
        titleLabel.text = title
        bodyLabel.text = body
        
        if body.isEmpty {
            titleLabel.text = nil
            moreLessButton.isHidden = true
            moreLessButton.isEnabled = false
        } else {
            moreLessButton.isHidden = false
            moreLessButton.isEnabled = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if let bodyLabel = bodyLabel, let text = bodyLabel.text, !text.isEmpty {
                if countLabelLines(label: bodyLabel) <= maxNumberOfLinesCollapsed {
                    moreLessButton.isHidden = true
                }
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate func countLabelLines(label: UILabel) -> Int {
        layoutIfNeeded()
        let myText = label.text! as NSString
        let attributes = [NSFontAttributeName : label.font as UIFont]
        let labelSize = myText.boundingRect(with: CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
    }
    
    deinit {
        bodyLabel.layer.removeObserver(self, forKeyPath: "bounds", context: &kvoContext)
    }
    
    // MARK: Interface Builder
    
    override func prepareForInterfaceBuilder() {
        self.layoutSubviews()
        let titleText = "Text for Title label"
        let bodytext = "Lorem ipsum dolor sit amet, eam eu veri corpora, eu sit zril eirmod integre, his purto quaestio ut."
        setText(titleText, body: bodytext)
    }

}
