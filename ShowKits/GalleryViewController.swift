//
//  GalleryViewController.swift
//  ShowKits
//
//  Created by anatoliy.kant on 10.02.16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {

    var userID:String = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
        
    var photos = [Photo]()
    
    private var apiClient = APIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        assert(userID.characters.count > 0)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        apiClient.findAllPhotosOfUser(userID) { (success:[Photo]?, failure) -> Void in
            if let photosToShow = success {
                //print(photosToShow)
                self.photos.removeAll()
                self.photos.appendContentsOf(photosToShow)
                self.collectionView.reloadData()
            }
        }
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let aPhoto = photoAt(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.updateImageWith(aPhoto)
        cell.textLabel.text = aPhoto.name
        
        return cell
    }
    
    private func photoAt(index:NSIndexPath) -> Photo {
        return photos[index.row]
    }
    
}

