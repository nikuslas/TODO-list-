//
//  ViewController.swift
//  TODOlist
//
//  Created by Nicolas Markus on 05/12/2015.
//  Copyright © 2015 Nicolas Markus. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Creat tableView for TODO list
    @IBOutlet weak var TODOList: UITableView!
    
    //item is an array to hold objects for the table view TODOList to display
    var item = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change the title of ViewController
        title = "TODO"
        //Registers Item class for use in creating new table cells
        TODOList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Return the number of item in the table view TODOList
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.count
    }
    
    //Affect each row with the name of the cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
            let todoitem = item[indexPath.row]
            cell!.textLabel!.text = todoitem.valueForKey("itemtodo") as? String
            return cell!
    }
    
    //Save each added name
    func saveName(itemname: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Item", inManagedObjectContext:managedContext)
        
        //Insert new item
        let iitem = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        iitem.setValue(itemname, forKey: "itemtodo")
        
        //Save the table view TODOList
        do {
            try managedContext.save()
            item.append(iitem)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //Delete each item from the persistent store
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            //Find which cell has been selected
            let itemToDelete = item[indexPath.row]
            managedContext.deleteObject(itemToDelete)
            item.removeAtIndex(indexPath.row)
            
            //Save the table view TODOList
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        
            //Animation to delete rows from table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //Get data from persistent store and into the managed object context
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //Get data from Item
        let fetchRequest = NSFetchRequest(entityName: "Item")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            item = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    //Creat button action to save items in CoreData
    @IBAction func AddItemTODO(sender: AnyObject) {
        
        //Alert to add a new item
        let alert = UIAlertController(title: "New TODO Item",
            message: "Add a new item",
            preferredStyle: .Alert)
        
        //By clicking on save you will save items
        let saveAction = UIAlertAction(title: "Save",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                
                let textField = alert.textFields!.first
                self.saveName(textField!.text!)
                self.TODOList.reloadData()
        })
        
        //Cancel button
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
}

