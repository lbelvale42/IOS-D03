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
    
    let qos = DispatchQoS.QoSClass.background
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var threadDone: Int = 0
    var errorStack : [String] = []
    
    func displayAlert () {
        if let error = errorStack.first {
            let alertController = UIAlertController(title: "Error", message: "Cannot access to : \(error)", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in
                self.errorStack.removeFirst()
                self.displayAlert()
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goImage" {
            if let vc = segue.destination as? SecondViewController {
                vc.image = (sender as AnyObject).imageView!!.image
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Images.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
            if cell.imageView.image != nil && cell.name != "error" {
                performSegue(withIdentifier: "goImage", sender: cell)
            }

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? CollectionViewCell
        cell?.imageView.image = nil
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.frame = CGRect(x: cell!.frame.size.width/2, y: cell!.frame.size.height/2, width: 0, height: 0)
        cell?.contentView.layer.borderColor = UIColor.black.cgColor
        cell?.contentView.layer.borderWidth = 2.0
        cell?.addSubview(activityView)
        let queue = DispatchQueue.global(qos: qos)
        queue.async {
            activityView.isHidden = false
            activityView.startAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if let url = URL(string: Images.images[indexPath.row]) {
                if let data = try? Data(contentsOf: url) {

                    DispatchQueue.main.async {
                        cell?.imageView.image = UIImage(data: data)
                        cell?.name = Images.images[indexPath.row]
                        activityView.isHidden = true
                        activityView.stopAnimating()
                        self.threadDone += 1
                        if self.threadDone >= Images.images.count {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        cell?.imageView.image = UIImage(named: "error")
                        cell?.name = "error"
                        activityView.isHidden = true
                        activityView.stopAnimating()
                        self.threadDone += 1
                        if self.threadDone >= Images.images.count {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                        self.errorStack.append(String(describing: url))
                        if self.presentedViewController == nil {
                            self.displayAlert()
                        }
                    }
                }
            }
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

}

