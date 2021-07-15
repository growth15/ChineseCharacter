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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem

        let defaults = UserDefaults.standard
        let selectedTab = defaults.integer(forKey: kSelectedTabDefaultKey)

        let item = heroTabBar.items?[selectedTab]
        heroTabBar.selectedItem = item
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeroListCell", for: indexPath)

        // Configure the cell...

        return cell
    }

    /*
     // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
     */

    /*
     // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             // Delete the row from the data source
             tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
             // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
     */

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
