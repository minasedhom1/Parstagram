//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Mina Sedhom on 10/9/22.
//  Copyright © 2022 Mina Sedhom. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

protocol CameraVCDelegate {
    func onSubmit()
}

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var onSubmit: (() -> Void)? // 1- define a closure
    
    //var delegate: CameraVCDelegate?
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var captionField: UITextField!
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        let post = PFObject(className: "Posts")
        
        post["caption"] = captionField.text
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData() //saving the image as a png
        let file = PFFileObject(data: imageData!)
        post["image"] = file
        
        post.saveInBackground { (success, error) in
            if success {
                print("Saved!")
                self.onSubmit?() //2- call the protocal
                //self.delegate?.onSubmit()
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error!")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    // Image picker callback after picking images
    // images comes inside of a dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 400, height: 400)
        // Use imageAspectScaled instead of imageScaled to scale image to fit within specified size while maintaining aspect ratio
        let scaledImaged = image.af.imageAspectScaled(toFill: size)//.imageScaled(to: size)//.imageAspectScaled(toFit: size) // resizing using alamofire with respect to
        
        imageView.image = scaledImaged
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func cropToSquareImage(sourceImage: UIImage) -> UIImage {
        // The shortest side
        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )

        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        // Center crop the image
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: sourceImage.imageRendererFormat.scale,
            orientation: sourceImage.imageOrientation
        )
        return croppedImage
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
