//
//  ViewController.swift
//  ArtBook
//
//  Created by Cihat Tascı on 22.07.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tabelView: UITableView!
    
    var artItems = [String]()
    var idArray = [UUID]()
    var selectedItemId : UUID?
    var selectedItem = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tabelView.dataSource = self
        tabelView.delegate = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(goToDetail))
        
        getData()
    }
    
    @objc func getData() {
        
        artItems.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "artist") as? String {
                        self.artItems.append(name)
                    }
                    
                    if let newId = result.value(forKey: "id") as? UUID {
                        self.idArray.append(newId)
                    }
                    
                    self.tabelView.reloadData()
                }
            }
        } catch {
            print("failed")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func goToDetail() {
        selectedItem = ""
        performSegue(withIdentifier: "detailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = artItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = artItems[indexPath.row]
        selectedItemId = idArray[indexPath.row]
        performSegue(withIdentifier: "detailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailVC" {
            let targetVC = segue.destination as! detailVC
            targetVC.chosenPictureName = selectedItem
            targetVC.chosenId = selectedItemId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
        fetchRequest.returnsObjectsAsFaults = false
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? UUID {
                        if id == idArray[indexPath.row] {
                            context.delete(result)
                            artItems.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            self.tabelView.reloadData()
                            do {
                                try context.save()
                            } catch {
                                print("error delete")
                            }
                            
                            break
                            
                        }
                    }
                }
            }
        } catch {
            print("failed to remove")
        }
    }


}

