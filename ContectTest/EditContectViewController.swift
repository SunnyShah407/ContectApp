//
//  EditContectViewController.swift
//  ContectTest
//
//  Created by Samir  on 27/12/16.
//  Copyright © 2016 STL. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



protocol EditContectDelegate {
    func didAddPerson(_ person : NSManagedObject)
    func didUpdatePerson()

}
public enum PickUserImage : Int {
    
    case photo
    case camera
    
}

class EditContectViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var lblAddPhoto: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtSname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtMobileNumnber: UITextField!
    var delegate : EditContectDelegate?
    var objPerson : NSManagedObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = 100/2;
        
        if (self.objPerson != nil) {
            self.title = "Edit Contect";
            
            txtFname.text =
                objPerson!.value(forKey: "fname") as? String
            txtSname.text =
                objPerson!.value(forKey: "sname") as? String
            txtLname.text =
                objPerson!.value(forKey: "lname") as? String
            txtMobileNumnber.text =
                objPerson!.value(forKey: "mobileNumber") as? String
            
            
            let imageData = objPerson!.value(forKey: "userImage") as? Data
            
            if imageData != nil {
                userImageView.image = UIImage(data:imageData!);
                lblAddPhoto.isHidden = true;
            }

            
        }else{
            self.title = "New Contect";
        }
        userImageView.layer.borderColor = UIColor.gray.cgColor
        userImageView.layer.borderWidth = 1.5;
        // Do any additional setup after loading the view.
    }

    @IBAction func didTapOnImage(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (action:UIAlertAction!) in
            self.goforImagePicking(PickUserImage.camera);
        }
        alertController.addAction(cameraAction)
        
        let photoAction = UIAlertAction(title: "Choose Photo", style: .default) { (action:UIAlertAction!) in
            self.goforImagePicking(PickUserImage.photo);
        }
        alertController.addAction(photoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)

        
    }
    
    func goforImagePicking( _ cameraType : PickUserImage){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if cameraType == PickUserImage.photo {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }else{
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        }
        
        present(imagePicker, animated: true, completion: nil)


    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismiss(animated: true, completion: nil)
        let image = self.resizeImage(image, newWidth: 400)
        self.userImageView.image = image;
        lblAddPhoto.isHidden = true;
    }
    
    @IBAction func btnDoneClicked(_ sender: AnyObject) {
        if txtFname.text?.characters.count>0 && txtSname.text?.characters.count>0 {
            if (self.objPerson != nil) {
                self.saveUserValue(self.objPerson!);
                self.delegate?.didUpdatePerson()
            }else{
                self.saveUser();
            }
            
        }
    }
   
    
    
    @IBAction func btnCancelClicked(_ sender: AnyObject) {
        self.navigationController?.isNavigationBarHidden = false;
        self.navigationController?.popViewController(animated: true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveUserValue(_ person : NSManagedObject){
        person.setValue(txtFname.text, forKey: "fname")
        person.setValue(txtLname.text, forKey: "lname")
        person.setValue(txtSname.text, forKey: "sname")
        person.setValue(txtMobileNumnber.text, forKey: "mobileNumber")
        
        if (userImageView.image != nil) {
            let imageData = UIImageJPEGRepresentation(userImageView.image!, 1.0);
            person.setValue(imageData, forKey: "userImage")

        }
    }

    func saveUser (){
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Person",
                                                        in:managedContext)
        
        let person = NSManagedObject(entity: entity!,
                                     insertInto: managedContext)
        
        self.saveUserValue(person);
        

        do {
            try managedContext.save()
            if self.delegate != nil{
                self.delegate?.didAddPerson(person);
            }
            //5
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
