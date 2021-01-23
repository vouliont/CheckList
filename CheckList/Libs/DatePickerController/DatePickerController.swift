//
//  DatePickerViewController.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import UIKit

final class DatePickerController: UIViewController {
    
    static func create() -> DatePickerController {
        let storyboard = UIStoryboard(name: "DatePickerController", bundle: nil)
        let datePickerController = storyboard.instantiateInitialViewController() as! DatePickerController
        return datePickerController
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: DatePickerControllerDelegate?
    
    @IBAction func okAction(_ sender: UIButton) {
        let date = datePicker.date
        delegate?.datePickerController(self, didSelectDate: date)
    }
    
    @IBAction func resetDateAction(_ sender: UIButton) {
        delegate?.datePickerControllerDidResetDate(self)
    }
    
}

protocol DatePickerControllerDelegate: AnyObject {
    func datePickerController(_ datePickerController: DatePickerController, didSelectDate date: Date)
    func datePickerControllerDidResetDate(_ datePickerController: DatePickerController)
}
