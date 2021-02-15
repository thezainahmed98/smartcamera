//
//  ListViewController.swift
//  Smart Camera
//
//  Created by Zain Ahmed on 8/24/20.
//  Copyright © 2020 Zain Ahmed. All rights reserved.
//

import UIKit

// This VC will display a list of all the identified objects with confidence level >50%
class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Receive lists of identified objects and cinfidence levels
    var objectListReceiver:[String:Float] = [:]
    var objects:[String] = []       // Will hold all the onjects from the dictionary above
    var confidence:[Float] = []     // Will hold all the ratings from the dictionary above
    
    
    override func viewDidLoad() {
        
        /* Takes out object name and confidence levels and appends them in
           two different paralell darrays */
        for (obj, confid) in objectListReceiver {
            objects.append(obj)
            confidence.append(confid)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectListReceiver.count
    }
    
    // Makes a table of all the identofied objects with >50% confidence
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objectConfidenceCell", for: indexPath) as! TableViewCell
        cell.objectLabel?.text = objects[indexPath.row]
        let confidenceLevel = confidence[indexPath.row]*100
        cell.confidenceLabel?.text = String(format: "%.0f%%", confidenceLevel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }


}


