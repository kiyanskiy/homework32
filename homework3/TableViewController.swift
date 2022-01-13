//
//  TableViewController.swift
//  homework3
//
//  Created by Oleksandr Kiianskyi on 12.01.2022.
//

import UIKit
import RxSwift
import RxCocoa

class TableViewController: UIViewController {
    let disposeBag = DisposeBag()

    @IBOutlet weak var searchBar: UISearchBar!
    var names = BehaviorRelay(value: ["Sasha", "Oleg", "Nikita", "Oleg", "Maria", "John", "Bob", "Vova", "Ann", "Andrew", "Peter", "Maria", "Liza", "John", "Bob", "Vova", "Ann", "Andrew", "Peter", "Maria"])
   
    @IBOutlet weak var namesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // задание с
//        names.asObservable()
//            .bind(to: namesTableView.rx.items) {
//              (tableView: UITableView, index: Int, element: String) in
//              let cell = UITableViewCell(style: .default,
//        reuseIdentifier: "cell")
//              cell.textLabel?.text = element
//        return cell }
//            .disposed(by: disposeBag)
        
        //Задание f
        searchBar.rx.text.orEmpty.debounce(.milliseconds(2000), scheduler: MainScheduler.instance).map({query in
                    self.names.value.filter({name in
                        query.isEmpty || name.lowercased().contains(query.lowercased())})}).bind(to: namesTableView.rx.items) {
                            (tableView: UITableView, index: Int, element: String) in
                            let cell = UITableViewCell(style: .default,
                                                       reuseIdentifier: "cell")
                            cell.textLabel?.text = element
                            return cell }
                        .disposed(by: disposeBag)
        
    }

    @IBAction func addName(_ sender: Any) {
        var newArray = names.value
        let index =  Int.random(in: 0...newArray.count - 1)
        newArray.insert(newArray[index], at: 0)
        names.accept(newArray)
    }
    @IBAction func removeLastName(_ sender: Any) {
        var newArray = names.value
        if newArray.count > 0{
            newArray.removeLast()
            names.accept(newArray)
        }
    }
}
