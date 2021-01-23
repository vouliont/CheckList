//
//  CheckListViewController.swift
//  CheckList
//
//  Created by Владислав on 21.01.2021.
//

import UIKit
import FirebaseAuth
import CoreData

fileprivate enum Segues {
    static let createTask = "CreateTaskSegue"
    static let editTask = "EditTaskSegue"
}

final class CheckListViewController: UITableViewController {
    
    private enum CellIdentifiers {
        static let taskCell = "TaskCell"
    }
    
    var dataStack: DataStack!
    var unManager: UNManager!
    private lazy var taskStorage = TaskStorage(dataStack: dataStack)
    private var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(tasksChanged(_:)), name: .TaskListDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .TaskListDidChangeNotification, object: nil)
    }
    
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
        } catch {
            showError("Something wend wrong. Try again.")
            print(error.localizedDescription)
        }
    }
    
    @objc private func tasksChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tasks = self.taskStorage.loadAll()
            self.tableView.reloadData()
        }
    }
    
    private func showError(_ error: String) {
        let alertController = AlertFactory()
            .withTitle("Some error happening")
            .withMessage(error)
            .addAction(title: "Ok")
            .create()
        present(alertController, animated: true)
    }
    
    // MARK: - Navigations
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.createTask:
            let taskDetailsVC = segue.destination as! TaskDetailsViewController
            taskDetailsVC.unManager = unManager
        case Segues.editTask:
            let taskDetailsVC = segue.destination as! TaskDetailsViewController
            taskDetailsVC.editableTask = sender as? Task
            taskDetailsVC.unManager = unManager
        default:
            break
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.taskCell, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.textLabel?.textColor = task.completed ? .secondaryLabel : .label
        cell.detailTextLabel?.text = task.taskDescription
        cell.detailTextLabel?.textColor = task.completed ? .secondaryLabel : .label
        cell.contentView.backgroundColor = task.completed ? .secondarySystemBackground : .systemBackground
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        FirebaseStorage.shared.updateTask(with: task.id!, completed: !task.completed)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
            let task = self.tasks[indexPath.row]
            self.performSegue(withIdentifier: Segues.editTask, sender: task)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            let taskId = self.tasks[indexPath.row].id!
            self.unManager.cancelNotification(with: taskId)
            FirebaseStorage.shared.deleteTask(with: taskId)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
