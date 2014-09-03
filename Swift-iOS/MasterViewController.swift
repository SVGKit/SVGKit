//
//  MasterViewController.swift
//  Swift-iOS
//
//  Created by C.W. Betts on 9/2/14.
//  Copyright (c) 2014 na. All rights reserved.
//

import UIKit
import SVGKit

class SwiftMasterViewController: UITableViewController, UIAlertViewDelegate {

    var sampleNames = ["map-alaska-onlysimple", "g-element-applies-rotation", "groups-and-layers-test", "http://upload.wikimedia.org/wikipedia/commons/f/f9/BlankMap-Africa.svg", "shapes", "strokes", "transformations", "rounded-rects", "gradients","radialGradientTest", "PreserveAspectRatio", "australia_states_blank", "Reinel_compass_rose", "Monkey", "Blank_Map-Africa", "opacity01", "Note", "Note@2x", "imageWithASinglePointPath", "Lion", "lingrad01", "Map", "CurvedDiamond", "Text", "text01", "tspan01", "Location_European_nation_states", "uk-only", "Europe_states_reduced", "Compass_rose_pale", "quad01", "cubic01", "rotated-and-skewed-text", "RainbowWing", "sakamura-default-fill-opacity-test", "StyleAttribute", "voies", "nil-demo-layered-imageview", "svg-with-explicit-width", "svg-with-explicit-width-large", "svg-with-explicit-width-large@160x240", "BlankMap-World6-Equirectangular", "Coins", "imagetag-layered", "ImageAspectRatio", "test-stroke-dash-array"]
	var detailViewController: SwiftDetailViewController? = nil
    var nameOfBrokenSVGToLoad = ""

	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
		    self.clearsSelectionOnViewWillAppear = false
		    self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
		    self.detailViewController = controllers[controllers.count-1].topViewController as? SwiftDetailViewController
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow() {
		        let object = sampleNames[indexPath.row]
		        let controller = (segue.destinationViewController as UINavigationController).topViewController as SwiftDetailViewController
		        controller.detailItem = object
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sampleNames.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

		let object = sampleNames[indexPath.row]
		cell.textLabel?.text = object
		return cell
	}

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if sampleNames[indexPath.row] == "Reinel_compass_rose" {
            NSLog("*****************\n*   WARNING\n*\n* The sample 'Reinel_compass_rose' is currently unsupported;\n* it is included in this build so that people working on it can test it and see if it works yet\n*\n*\n*****************");
            UIAlertView(title: "WARNING", message: "Reinel_compass_rose breaks SVGKit, it uses unsupported SVG commands; until we have added support for those commands, it's here as a test - but it WILL CRASH if you try to view it", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK, crash").show()
            
            self.nameOfBrokenSVGToLoad = sampleNames[indexPath.row];
            
            return;
        }
        
        //self.detailViewController.detailItem = sampleNames[indexPath.row];
    }
    
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}

}

