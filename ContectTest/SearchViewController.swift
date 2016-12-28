//
//  SearchViewController.swift
//  ContectTest
//
//  Created by Sunny on 12/28/16.
//  Copyright © 2016 STL. All rights reserved.
//

import UIKit
import CoreData

protocol SearchViewControllerDelegate {
    func didCancelClick()
    func didSelectPerson(person : NSManagedObject)
    
    
}

class SearchViewController: UIViewController , UISearchBarDelegate , UITableViewDelegate , UITableViewDataSource{

    var isSearching : Bool = false;
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate : SearchViewControllerDelegate?
    var people = [NSManagedObject]()
    var peopleNameSearch = [NSManagedObject]()
    @IBOutlet weak var tableListOfPeople: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableListOfPeople.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if self.isSearching == true {
            self.navigationController?.isNavigationBarHidden = true;
            searchBar.becomeFirstResponder()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.delegate?.didCancelClick()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if peopleNameSearch.count>0 {
            return "TOP NAME MATCHES";
        }
        
        return "";
    }
    // MARK: UITableView Datasource methods
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return self.peopleNameSearch.count;
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        
        let person = self.peopleNameSearch[indexPath.row]
        
        let surName = person.value(forKey: "sname") as? String
        let name = person.value(forKey: "fname") as? String
        
        cell!.textLabel!.text = name! + " " + surName!;
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        self.delegate?.didCancelClick()
        self.delegate?.didSelectPerson(person: self.peopleNameSearch[indexPath.row])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        peopleNameSearch.removeAll()
        if searchText.characters.count>0 {
            let resultPredicate : NSPredicate = NSPredicate(format: "fname contains[c] %@ OR sname contains[c] %@",searchText,searchText)
            
            peopleNameSearch = people.filter { resultPredicate.evaluate(with: $0) };
            self.isSearching = true;
            tableListOfPeople.backgroundColor = UIColor.white;
        }else{
            
            tableListOfPeople.backgroundColor = UIColor.clear;
        }
        self.tableListOfPeople.reloadData()
        
    }
}
