//
//  ViewController.swift
//  APM
//
//  Created by Lucas BELVALETTE on 10/6/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    let qos = QOS_CLASS_BACKGROUND
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var threadDone: Int = 0
    var errorStack : [String] = []
    
    func displayAlert () {
        if let error = errorStack.first {
            let alertController = UIAlertController(title: "Error", message: "Cannot access to : \(error)", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { action in
                self.errorStack.removeFirst()
                self.displayAlert()
            })
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goImage" {
            if let vc = segue.destinationViewController as? SecondViewController {
                vc.image = sender?.imageView!!.image
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Images.images.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CollectionViewCell {
            if cell.imageView.image != nil && cell.name != "error" {
                performSegueWithIdentifier("goImage", sender: cell)
            }

        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as? CollectionViewCell
        cell?.imageView.image = nil
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.frame = CGRect(x: cell!.frame.size.width/2, y: cell!.frame.size.height/2, width: 0, height: 0)
        cell?.contentView.layer.borderColor = UIColor.blackColor().CGColor
        cell?.contentView.layer.borderWidth = 2.0
        cell?.addSubview(activityView)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue) {
            activityView.hidden = false
            activityView.startAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            if let url = NSURL(string: Images.images[indexPath.row]) {
                if let data = NSData(contentsOfURL: url) {

                    dispatch_async(dispatch_get_main_queue()) {
                        cell?.imageView.image = UIImage(data: data)
                        cell?.name = Images.images[indexPath.row]
                        activityView.hidden = true
                        activityView.stopAnimating()
                        self.threadDone += 1
                        if self.threadDone >= Images.images.count {
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        }
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell?.imageView.image = UIImage(named: "error")
                        cell?.name = "error"
                        activityView.hidden = true
                        activityView.stopAnimating()
                        self.threadDone += 1
                        if self.threadDone >= Images.images.count {
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        }
                        self.errorStack.append(String(url))
                        if self.presentedViewController == nil {
                            self.displayAlert()
                        }
                    }
                }
            }
        }
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return sectionInsets.left
    }

}

