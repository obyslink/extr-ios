//
//  ReportPagerListViewController.swift
//  Extr
//
//  Created by Zekun Wang on 12/6/16.
//  Copyright © 2016 Expense Manager. All rights reserved.
//

import UIKit

class ReportPagerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var averageLabel: UILabel!
    
    let reportPagerCellString = "ReportPagerCell"
    
    var requestCode: Int = 0
    var rawDatesList: [[Date]] = []
    var datesList: [[Date]] = []
    var expensesList: [[RExpense]] = []
    var categoryDictionaryList: [[String : Double]] = []
    var total: Double = 0
    
    var userId: String!
    var groupId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 62
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: reportPagerCellString, bundle: nil), forCellReuseIdentifier: reportPagerCellString)
        
        let userDefaults = UserDefaults.standard
        userId = userDefaults.string(forKey: RMember.JsonKey.userId)
        groupId = userDefaults.string(forKey: RMember.JsonKey.groupId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if groupId == nil {
            print("No group saved")
            return
        }
        
        loadData()
    }
    
    func loadData() {
        rawDatesList = []
        datesList = []
        expensesList = []
        total = 0
        
        switch requestCode {
        case ReportViewController.WEEKLY: rawDatesList = Helpers.getAllWeeks(groupId: groupId)
        case ReportViewController.MONTHLY: rawDatesList = Helpers.getAllMonths(groupId: groupId)
        case ReportViewController.YEARLY: rawDatesList = Helpers.getAllYears(groupId: groupId)
        default: break;
        }
        
        datesList = Helpers.getAllValidDates(groupId: groupId, rawDates: rawDatesList)
        for dates in datesList {
            let expenses = Array(RExpense.getExpensesByFiltersAndGroupId(groupId: groupId, member: nil, category: nil, startDate: dates[0], endDate: dates[1]))
            var categoryDictionary: [String : Double] = [:]
            for expense in expenses {
                total += expense.amount
                
                if categoryDictionary[expense.categoryId] == nil {
                    categoryDictionary[expense.categoryId] = 0
                }
                
                categoryDictionary[expense.categoryId]! += expense.amount
            }
            expensesList.append(expenses)
            categoryDictionaryList.append(categoryDictionary)
        }
        
        let average = rawDatesList.count > 0 ? total / Double(rawDatesList.count) : 0
        averageLabel.text = "Average: $\(Helpers.getFormattedAmount(amount: average))"
        
        invalidateViews()
    }
    
    func invalidateViews() {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reportPagerCellString, for: indexPath) as! ReportPagerCell
        
        cell.requestCode = requestCode
        cell.dates = datesList[indexPath.row]
        cell.categoryDictionary = categoryDictionaryList[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: perform detail segue
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}