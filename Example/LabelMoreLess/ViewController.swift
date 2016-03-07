//
//  ViewController.swift
//  LabelMoreLess
//
//  Created by Stefano Frosoni on 26/02/16.
//  Copyright © 2016 Stefano Frosoni. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var readMoreLessView: ReadMoreLessView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleText = "Title"
        let bodytext = "Lorem ipsum dolor sit amet, eam eu veri corpora, eu sit zril eirmod integre, his purto quaestio ut. Et omnesque postulant definiebas nam, diam option ne nec, eos ea hinc veniam cotidieque. No erant blandit accusata quo, at ullum sensibus definitionem qui, in dicta essent intellegat eam. Alii simul tritani in eam, his elitr sapientem cu."
        
        readMoreLessView.setText(titleText, body: bodytext)
        
    }
}

