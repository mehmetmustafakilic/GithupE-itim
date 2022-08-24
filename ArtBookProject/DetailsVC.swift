//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Mehmet Mustafa Kılıç on 2.08.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButtom: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            
            saveButtom.isHidden = true
            
            //Core Darw
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fecthRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fecthRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fecthRequest.returnsObjectsAsFaults = false 
            
            do{
              let results = try context.fetch(fecthRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject] {
                         
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error ")
            }
            
            // id kodunu terminalde görmek için yazdıldı
            let stringUUID = chosenPaintingId!.uuidString
            print(stringUUID)
            
        }else{
            saveButtom.isHidden = false
            saveButtom.isEnabled = false
            nameText.text = ""
            yearText.text = ""
            artistText.text = ""
        }
        
        //Recognizers,
        imageView.isUserInteractionEnabled = true
        let imageTabRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTabRecognizer)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
       
    }
    
    @objc func selectImage(){
        
        let picer = UIImagePickerController()
        picer.delegate = self
        picer.sourceType = .photoLibrary
        picer.allowsEditing = true
        present(picer, animated: true, completion: nil)
        print("test")
        
        
    }
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
       saveButtom.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
  
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
  
    @IBAction func saveButtonCilcked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "Name")
        newPainting.setValue(artistText.text!, forKey: "Artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "Year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
