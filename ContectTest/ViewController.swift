//
//  ViewController.swift
//  ContectTest
//
//  Created by Samir  on 27/12/16.
//  Copyright © 2016 STL. All rights reserved.
//

import UIKit
import CoreData
import Contacts

class ViewController: UIViewController , EditContectDelegate ,UITableViewDataSource , UITableViewDelegate , UISearchBarDelegate , SearchViewControllerDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
     weak var searchController: SearchViewController!

    var people = [NSManagedObject]()

    var indexArray = [String]()
    var indexPeople = [String]()
    var dictPeople = NSMutableDictionary()
    
    @IBOutlet weak var tableListOfPeople: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableListOfPeople.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        if UserDefaults.standard.bool(forKey: "isContectFetched") ==  false {
            self.getContactsFromAddressBook()
            
        }
        
        self.indexArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J","K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
        
        
        self.getListOfContect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    @IBAction func btnRefreshClicked(_ sender: AnyObject) {
        self.getListOfContect();
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        // Get authorization
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nYou can not use now, please click button below to setting permission. :)"
                        })
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    // Get list of contect from coredata (database)
    func getListOfContect(){
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        
        let firstNameDescriptor = NSSortDescriptor.init(key: "fname", ascending: true)
        let sNameDescriptor = NSSortDescriptor.init(key: "sname", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor,sNameDescriptor];
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            people = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for letter in self.indexArray {
            let arr = self.getContect(letter);
            if arr.count>0 {
                dictPeople.setObject(arr, forKey: letter as NSCopying);
                indexPeople.append(letter);
            }
        }
        tableListOfPeople.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexPeople.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let letter = indexPeople[section];
        return letter;
    }
    // MARK: UITableView Datasource methods
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let letter = indexPeople[section];
        let arrPeople = dictPeople.object(forKey: letter);
        return ((arrPeople as AnyObject).count)!;
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt
        indexPath: IndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let letter = indexPeople[indexPath.section];
        let arrPeople = dictPeople.object(forKey: letter) as! [NSManagedObject];
        
        let person = arrPeople[indexPath.row]
        
        let surName = person.value(forKey: "sname") as? String
        let name = person.value(forKey: "fname") as? String
        
        cell!.textLabel!.text = name! + " " + surName!;
        
        return cell!
    }
    
    func getContect(_ forLetter : String) -> [NSManagedObject]{
        let resultPredicate : NSPredicate = NSPredicate(format: "sname beginswith[c] %@",forLetter)
        let arrIndexPeople = people.filter { resultPredicate.evaluate(with: $0) };
        return arrIndexPeople;
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let letter = self.indexArray[index];
        
        if self.indexPeople.contains(letter) {
            let indexPath = IndexPath.init(row: 0, section: self.indexPeople.index(of: letter)!);
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            return self.indexPeople.index(of: letter)!;
        }
       
        return index;
        
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexArray
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier ?? "");
        if segue.identifier == "addperson" {
            let controller = segue.destination as! EditContectViewController;
            controller.delegate = self;
            
        }else if segue.identifier == "Embed" {
            searchController = segue.destination as! SearchViewController;
            searchController.delegate = self;
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableListOfPeople.deselectRow(at: indexPath, animated: true);
        let letter = indexPeople[indexPath.section];
        let arrPeople = dictPeople.object(forKey: letter) as! [NSManagedObject];
        
        let person = arrPeople[indexPath.row]
        
        
        self.didSelectPerson(person: person)
        
    }
    
    // MARK: EditViewController delegate methods
    
    func didAddPerson(_ person: NSManagedObject) {
        people.append(person);
        let surName = person.value(forKey: "sname") as? String
        let firstChar = surName?.first.uppercased();
        if indexPeople.contains(firstChar!) {
            var arrPeople = dictPeople.object(forKey: firstChar ?? "") as! [NSManagedObject];
            arrPeople.append(person);
            dictPeople.setObject(arrPeople, forKey: firstChar as! NSCopying);
        
        }else{
            indexPeople.append(firstChar!);
            indexPeople = indexPeople.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }

            let arr = self.getContect(firstChar!);
            dictPeople.setObject(arr, forKey: surName?.first as! NSCopying);

        }
        
        
        tableListOfPeople.reloadData()
        
        
        _ = self.navigationController?.popViewController(animated: true);
    }
    
    func didUpdatePerson() {
        tableListOfPeople.reloadData()
        _ = self.navigationController?.popViewController(animated: true);
        
    }
    
    
   
  
    
    // MARK: Get contect from addressbook
    
    func getContactsFromAddressBook() {
        let store = CNContactStore()
        
        self.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                self.retrieveContactsWithStore(store)
            }
        }
        
        
    }
    
    func retrieveContactsWithStore(_ store: CNContactStore) {
        var contacts: [CNContact] = {
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactEmailAddressesKey,
                CNContactPhoneNumbersKey,
                CNContactImageDataAvailableKey,
                CNContactThumbnailImageDataKey,CNContactPhoneNumbersKey] as [Any]
            
            // Get all the containers
            var allContainers: [CNContainer] = []
            do {
                allContainers = try store.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }
            
            var results: [CNContact] = []
            
            // Iterate all containers and append their contacts to our results array
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                do {
                    let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching results for container")
                }
            }
            for item in results{
                self.saveUser(item)
            }
            return results
        }()
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        UIView.animate(withDuration: 0.3, animations:{ () -> Void in
            self.containerTopConstraint.constant = -64;
            self.containerView.isHidden = false;
            self.searchController.isSearching = true;
            self.searchController.searchBar.becomeFirstResponder();
            self.searchController.searchBar.setShowsCancelButton(true, animated: true)
            self.searchController.people = self.people;
            self.navigationController?.isNavigationBarHidden = true;
            self.view.layoutIfNeeded()
        })
        
        
        return false;
    }
    func saveUser (_ contect : CNContact){
        UserDefaults.standard.set(true, forKey: "isContectFetched")
        UserDefaults.standard.synchronize();
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Person",
                                                 in:managedContext)
        
        let person = NSManagedObject(entity: entity!,
                                     insertInto: managedContext)
        
        person.setValue(contect.givenName, forKey: "fname")
        person.setValue(contect.middleName, forKey: "lname")
        person.setValue(contect.familyName, forKey: "sname")
        
        var phoneNumber: String = ""
        for value in contect.phoneNumbers {
            let phone = value.value
            phoneNumber = phone.stringValue
        }
        person.setValue(phoneNumber, forKey: "mobileNumber")
        
        do {
            try managedContext.save()
            
            //5
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func didCancelClick() {
        UIView.animate(withDuration: 0.3, animations:{ () -> Void in
            self.containerTopConstraint.constant = 0;
            self.containerView.isHidden = true;
            self.navigationController?.isNavigationBarHidden = false;
            self.view.layoutIfNeeded()
            self.searchController.isSearching = false;

            

        })
    }
    func didSelectPerson(person: NSManagedObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller =   mainStoryboard.instantiateViewController(withIdentifier: "EditContect") as! EditContectViewController
        controller.delegate = self;
        self.navigationController?.isNavigationBarHidden = false;
        controller.objPerson = person
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
}
