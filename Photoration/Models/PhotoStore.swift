//
//  PhotoStore.swift
//  Photoration
//
//  Created by Lixiang Zhang on 3/14/21.
//

import UIKit
import CoreData

enum PhotoError: Error {
    case imageCreationError
    case missingImageURL
}

enum PhotoCategory: String {
    case mostRecent = "recent"
    case interesting = "interesting"
}

class PhotoStore {
    
    private let imageStore = ImageStore()
    private let alert = Alert()
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photoration")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error).")
            }
        }
        return container
    }()
    
    func fetchAllTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard let photoURL = photo.remoteURL else {
            completion(.failure(PhotoError.missingImageURL))
            return
        }
        
        let request = URLRequest(url: photoURL)
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    /**
     Fetch photos from Core Data
     */
    func fetchFavoritePhotos(completion: @escaping (Result<[Photo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.isFavorite)) == \(true)")
        fetchRequest.predicate = predicate
        viewContext.perform {
            do {
                let allPhotos = try self.viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /**
     Fetch photos from Core Data
     */
    func fetchPhotosLocally(category: PhotoCategory, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        let predicate = NSPredicate(format: "\(#keyPath(Photo.category)) == %@", category.rawValue)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        fetchRequest.predicate = predicate
        viewContext.perform {
            do {
                let allPhotos = try self.viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /**
     Fetch photos from web service
     */
    func fetchPhotosRemotely(category: PhotoCategory, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let url: URL
        switch category {
        case .interesting:
            url = FlickrAPI.interestingPhotosURL
        case .mostRecent:
            url = FlickrAPI.mostRecentPhotosURL
        }
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                OperationQueue.main.addOperation {
                    completion(.failure(error!))
                }
                return
            }
            
            self.persistPhotos(data: data, error: error, category: category) { (result) in
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
        }
        
        task.resume()
    }
    
    /**
     Save photos into Core Data
     */
    private func persistPhotos(data: Data?, error: Error?, category: PhotoCategory, completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard let jsonData = data else {
            completion(.failure(error!))
            return
        }
        
        persistentContainer.performBackgroundTask { (context) in
            switch FlickrAPI.photos(fromJSON: jsonData) {
            case let .success(flickrPhotos):
                let photos = flickrPhotos.map { (flickrPhoto) -> Photo in
                    
                    let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
                    let predicate = NSPredicate(
                        format: "\(#keyPath(Photo.photoID)) == %@", flickrPhoto.photoID)
                    fetchRequest.predicate = predicate
                    var fetchedPhotos: [Photo]?
                    context.performAndWait {
                        fetchedPhotos = try? fetchRequest.execute()
                    }
                    if let existingPhoto = fetchedPhotos?.first {
                        return existingPhoto
                    }
                    
                    var photo: Photo!
                    context.performAndWait {
                        photo = Photo(context: context)
                        photo.title = flickrPhoto.title
                        photo.photoID = flickrPhoto.photoID
                        photo.remoteURL = flickrPhoto.remoteURL
                        photo.dateTaken = flickrPhoto.dateTaken
                        photo.category = category.rawValue
                    }
                    return photo
                }
                
                do {
                    try context.save()
                } catch {
                    completion(.failure(error))
                    return
                }
                completion(.success(photos))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> Result<UIImage, Error> {
        guard let imageData = data,
              let image = UIImage(data: imageData) else {
            
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }
        
        return .success(image)
    }
}
