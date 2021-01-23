//
//  TaskDetailsViewController.swift
//  CheckList
//
//  Created by Владислав on 22.01.2021.
//

import UIKit

final class TaskDetailsViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var remindMeLabel: UILabel!
    
    var editableTask: Task?
    var unManager: UNManager!
    private var remindMeDate: Date?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy, HH:mm"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        
        if let task = editableTask {
            title = "Edit Task"
            nameTextField.text = task.name
            descriptionTextView.text = task.taskDescription
            remindMeDate = task.date
        } else {
            title = "Create Task"
        }
        updateRemindMeLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if editableTask == nil {
            nameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        guard let taskName = nameTextField.text,
              !taskName.isEmpty else {
            showWarning("Task must have a name")
            return
        }
        
        let completionHandler = { (taskId: String, finished: Bool) -> Void in
            self.cancelPrevNotification()
            self.scheduleTaskNotification(for: taskId) { error in
                if let _ = error {
                    let alertController = AlertFactory()
                        .withTitle("Something went wrong with scheduling notification")
                        .addAction(title: "Ok")
                        .create()
                    self.present(alertController, animated: true)
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if let task = editableTask {
            FirebaseStorage.shared.updateTask(with: task.id!,
                                              name: taskName,
                                              description: descriptionTextView.text,
                                              date: remindMeDate) { finished in
                completionHandler(task.id!, finished)
            }
        } else {
            FirebaseStorage.shared.createTask(named: taskName,
                                              description: descriptionTextView.text,
                                              date: remindMeDate,
                                              completionHandler: completionHandler)
        }
    }
    
    private func cancelPrevNotification() {
        if let task = self.editableTask,
           let taskRemindDate = task.date,
           self.remindMeDate == nil || taskRemindDate != self.remindMeDate! { // remind me date has been changed
            self.unManager.cancelNotification(with: task.id!)
        }
    }
    
    private func scheduleTaskNotification(for taskId: String,
                                          completionHandler: ((Error?) -> Void)? = nil) {
        let taskName = nameTextField.text
        let taskDescription = descriptionTextView.text
        guard let newRemindMeDate = remindMeDate else {
            completionHandler?(nil)
            return
        }
        self.unManager.scheduleNotification(with: taskId,
                                            title: taskName!,
                                            body: taskDescription ?? "",
                                            date: newRemindMeDate,
                                            completionHandler: completionHandler)
    }
    
    private func showWarning(_ message: String) {
        let alertController = AlertFactory()
            .withTitle("Warning!")
            .withMessage(message)
            .addAction(title: "Ok")
            .create()
        present(alertController, animated: true)
    }
    
    private func updateRemindMeLabel() {
        let remindMeText: String
        if let date = remindMeDate {
            remindMeText = dateFormatter.string(from: date)
        } else {
            remindMeText = "Not set"
        }
        remindMeLabel.text = remindMeText
    }
    
    private func showDatePicker() {
        let datePickerController = DatePickerController.create()
        datePickerController.modalPresentationStyle = .custom
        datePickerController.delegate = self
        present(datePickerController, animated: true) {
            let minDate = Date().addingTimeInterval(5 * 60)
            datePickerController.datePicker.minimumDate = minDate
        }
    }
    
}

// MARK: - Table view delegate
extension TaskDetailsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            nameTextField.becomeFirstResponder()
            return
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
            return
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            unManager.requestPermission { [weak self] granted in
                if granted {
                    self?.showDatePicker()
                } else {
                    let alertFactory = AlertFactory()
                        .withTitle("Notification permission denied")
                        .withMessage("Change it in settings")
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsURL) {
                        alertFactory.addAction(title: "Open Settings", style: .default) { action in
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    alertFactory.addAction(title: "Ok")
                    self?.present(alertFactory.create(), animated: true)
                }
            }
            view.endEditing(true)
            return
        }
    }
}

extension TaskDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension TaskDetailsViewController: DatePickerControllerDelegate {
    func datePickerController(_ datePickerController: DatePickerController, didSelectDate date: Date) {
        guard date > Date() else {
            let alertController = AlertFactory()
                .withTitle("Incorrect date or time")
                .addAction(title: "Ok")
                .create()
            datePickerController.present(alertController, animated: true)
            return
        }
        remindMeDate = date
        updateRemindMeLabel()
        dismiss(animated: true)
    }
    
    func datePickerControllerDidResetDate(_ datePickerController: DatePickerController) {
        remindMeDate = nil
        updateRemindMeLabel()
        dismiss(animated: true)
    }
}
