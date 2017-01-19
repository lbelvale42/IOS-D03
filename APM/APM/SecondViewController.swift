//
//  SecondViewController.swift
//  APM
//
//  Created by Lucas BELVALETTE on 10/6/16.
//  Copyright © 2016 Lucas BELVALETTE. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView?
    var image: UIImage?
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView!.bounds.width
        scrollView.minimumZoomScale = widthScale
    }
    
    override func viewDidLayoutSubviews() {
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(image: image)
        scrollView.addSubview(imageView!)
        scrollView.contentSize = (imageView?.frame.size)!
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
