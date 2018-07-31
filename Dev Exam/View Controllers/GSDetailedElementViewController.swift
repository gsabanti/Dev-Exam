//
//  GSDetailedElementViewController.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import UIKit

class GSDetailedElementViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    var element: DataElement!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("DETAILED_TITLE", comment: "")
        self.imageView.sd_setImage(with: URL(string: element.image ?? ""), placeholderImage: #imageLiteral(resourceName: "no_photo"), options: .allowInvalidSSLCertificates, progress: nil, completed: nil)
        self.titleLabel.text = element.title
        self.descTextView.text = element.text
    }
    
}
