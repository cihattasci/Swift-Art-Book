//
//  detailVC.swift
//  ArtBook
//
//  Created by Cihat Tascı on 22.07.2021.
//

import UIKit
import CoreData

class detailVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artistName: UITextField!
    @IBOutlet weak var pictureName: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenImage = UIImage()
    var chosenArtistName = ""
    var chosenYear = Int()
    var chosenPictureName = ""
    var chosenId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        if chosenPictureName != "" {
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
            let idString = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let artist = result.value(forKey: "artist") as? String {
                            artistName.text = artist
                        }
                        if let picName = result.value(forKey: "pictureName") as? String {
                            pictureName.text = picName
                        }
                        if let fetchYear = result.value(forKey: "year") as? Int {
                            year.text = String(fetchYear)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                    }
                }
            } catch  {
                print("error fetch")
            }
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            pictureName.text = ""
            artistName.text = ""
            year.text = ""
            imageView.image = UIImage(named: "addImagePic.jpg")
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleKeybord))
        view.addGestureRecognizer(recognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageRecognizer)
    }
    
    @objc func toggleKeybord() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        let picker  = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPicture = NSEntityDescription.insertNewObject(forEntityName: "Pictures", into: context)
        
        newPicture.setValue(artistName.text, forKey: "artist")
        newPicture.setValue(pictureName.text, forKey: "pictureName")
        newPicture.setValue(UUID(), forKey: "id")
        if let newYear = Int(self.year.text!) {
            newPicture.setValue(newYear, forKey: "year")
        }
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        newPicture.setValue(imageData, forKey: "image")
        
        do {
            try context.save()
            print("success save")
        } catch {
            print("failed save")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    
}
