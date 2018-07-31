//
//  Extensions.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController
{
    func showAlert(title: String, message: String, cancel: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    func showFailureAlert(message: String)
    {
        DispatchQueue.main.async {
            self.showAlert(title: NSLocalizedString("ERROR_OCCURRED", comment: ""), message: message, cancel: NSLocalizedString("ERROR_CANCEL", comment: ""))
        }
    }
    func showSuccessAlert()
    {
        DispatchQueue.main.async {
            self.showAlert(title: NSLocalizedString("SUCCESS_TITLE", comment: ""), message: NSLocalizedString("SUCCESS_MESSAGE", comment: ""), cancel: NSLocalizedString("SUCCESS_CANCEL", comment: ""))
        }
    }
}

extension String {
    func formatPhoneString() -> String {
        do {
            var str = self
            let replaceWith = "[$0]"
            let regex = try NSRegularExpression(pattern: "Х+")
            let range = NSMakeRange(0, self.count)
            str = regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: replaceWith)
            str = str.replacingOccurrences(of: "Х", with: "0")
            print(str)
            return str
        } catch {
            return self
        }
    }
}
