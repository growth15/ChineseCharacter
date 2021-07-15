//
//  HeroListController.swift
//  ChineseCharacter
//
//  Created by i on 2021/7/15.
//

import CoreData
import UIKit

let kSelectedTabDefaultKey = "Selected Tab"

enum tabBarKeys: Int {
    case ByName
    case BySecretIdentity
}

class HeroListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!

    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Hero", in: context!)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        let items: Array = heroTabBar.items!
        var tabIndex = items.firstIndex(of: heroTabBar.selectedItem!)

        if tabIndex == NSNotFound {
            let defaults = UserDefaults.standard
            tabIndex = defaults.integer(forKey: kSelectedTabDefaultKey)
        }

        var sectionKey: String!
        switch tabIndex {
        case tabBarKeys.ByName.rawValue:
            let sortDescriptor1 = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptor2 = NSSortDescriptor(key: "secretIdentity", ascending: true)
            let sortDescriptors = NSArray(objects: sortDescriptor1, sortDescriptor2)
            fetchRequest.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
            sectionKey = "name"
        case tabBarKeys.BySecretIdentity.rawValue:
            let sortDescriptor2 = NSSortDescriptor(key: "name", ascending: true)
            let sortDescriptor1 = NSSortDescriptor(key: "secretIdentity", ascending: true)
            let sortDescriptors = NSArray(objects: sortDescriptor1, sortDescriptor2)
            fetchRequest.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
            sectionKey = "secretIdentity"
        default:
            ()
        }

        let aFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: sectionKey, cacheName: "Hero")
        aFetchResultsController.delegate = self
        _fetchedResultsController = aFetchResultsController
        return _fetchedResultsController
    }

    @IBOutlet var heroTableView: UITableView!
    @IBOutlet var heroTabBar: UITabBar!

    @IBAction func addHero(_ sender: Any) {
        let managedObjectContext = fetchedResultsController.managedObjectContext as NSManagedObjectContext
        let entity: NSEntityDescription = fetchedResultsController.fetchRequest.entity!
        NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: managedObjectContext)

        do {
            try managedObjectContext.save()
        } catch let error {
            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
            let message = NSLocalizedString("Error was : \(error), quitting", comment: "Error was : \(error), quitting")

            showAlertWithCompletion(title: title, message: message, buttonTitle: "Aw nuts", completion: { _ in exit(-1) })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem

        let defaults = UserDefaults.standard
        let selectedTab = defaults.integer(forKey: kSelectedTabDefaultKey)

        let item = heroTabBar.items?[selectedTab]
        heroTabBar.selectedItem = item

        // Fetch any existing entities
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
            let message = NSLocalizedString("Error was : \(error), quitting",
                                            comment: "Error was : \(error), quitting")
            showAlertWithCompletion(title: title, message: message,
                                    buttonTitle: "Aw nuts", completion: { _ in exit(-1) })
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroListCell", for: indexPath)

        let hero = fetchedResultsController.object(at: indexPath) as! NSManagedObject
        let tabArray = heroTabBar.items
        let tab = tabArray?.firstIndex(of: heroTabBar.selectedItem!)

        switch tab {
        case tabBarKeys.ByName.rawValue:
            cell.textLabel?.text = hero.value(forKey: "name") as? String
            cell.detailTextLabel?.text = hero.value(forKey: "secretIdentity") as? String
        case tabBarKeys.BySecretIdentity.rawValue:
            cell.textLabel?.text = hero.value(forKey: "secretIdentity") as? String
            cell.detailTextLabel?.text = hero.value(forKey: "name") as? String
        default:
            ()
        }

        return cell
    }

    /*
     // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
     */

    func showAlertWithCompletion(title: String, message: String, buttonTitle: String = "OK", completion: ((UIAlertAction?) -> Void)!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: completion)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let managedObjectContext = fetchedResultsController.managedObjectContext as NSManagedObjectContext?
        if editingStyle == .delete {
            managedObjectContext!.delete(fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            do {
                try managedObjectContext?.save()
            } catch let error {
                let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
                let message = NSLocalizedString("Error was : \(String(describing: error)), quitting", comment: "Error was : \(String(describing: error)), quitting")
                showAlertWithCompletion(title: title, message: message, buttonTitle: "Aw Nuts",
                                        completion: { _ in exit(-1) })
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    /*
     // Override to support rearranging the table view.
     func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension HeroListController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let defaults = UserDefaults.standard
        let items: Array = heroTabBar.items!
        let tabIndex = items.firstIndex(of: item)
        defaults.setValue(tabIndex, forKey: kSelectedTabDefaultKey)

        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "Hero")
        _fetchedResultsController = nil

        do {
            try fetchedResultsController.performFetch()
            heroTableView.reloadData()
        } catch let error {
            let title = NSLocalizedString("Error Saving Entity", comment: "Error Saving Entity")
            let message = NSLocalizedString("Error was : \(error), quitting",
                                            comment: "Error was : \(error), quitting")
            showAlertWithCompletion(title: title, message: message, buttonTitle: "Aw nuts",
                                    completion: { _ in exit(-1) })
        }
    }
}

extension HeroListController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        heroTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        heroTableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            heroTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            heroTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            ()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            heroTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            heroTableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            ()
        }
    }
}
