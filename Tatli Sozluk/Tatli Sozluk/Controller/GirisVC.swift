//
//  GirisVC.swift
//  Tatli Sozluk
//
//  Created by Erkan on 30.01.2023.
//

import UIKit
import FirebaseAuth
class GirisVC: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var parolaText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    

    @IBAction func girisTiklandi(_ sender: Any) {
        
        guard let emailAdresi = emailText.text,
              let parola = parolaText.text else{return}
        
        
        Auth.auth().signIn(withEmail: emailAdresi, password: parola){ kullanici, hata in
            
            if let hata = hata{
                debugPrint("HATA \(hata.localizedDescription)")
            }else{
                self.dismiss(animated: true, completion: nil)
            }
            
            
        }
        
        
    }
    
    @IBAction func hesapOlusturTiklandi(_ sender: Any) {
    }
    

}
