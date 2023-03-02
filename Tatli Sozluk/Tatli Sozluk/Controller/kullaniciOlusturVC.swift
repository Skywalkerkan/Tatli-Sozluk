//
//  kullaniciOlusturVC.swift
//  Tatli Sozluk
//
//  Created by Erkan on 30.01.2023.
//

import UIKit
import Firebase
import FirebaseAuth


class kullaniciOlusturVC: UIViewController {

    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var parolaText: UITextField!
    @IBOutlet weak var kullaniciAdiText: UITextField!
    @IBOutlet weak var hesabiOlustur: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hesabiOlustur.layer.cornerRadius = 15

 
    }
    

    @IBAction func hesabiOlusturTiklandi(_ sender: Any) {
        
        guard let emailAdresi = emailText.text,
              let parola = parolaText.text,
              let kullaniciAdi = kullaniciAdiText.text else{return}
            
        //print(emailAdresi, parola)
            Auth.auth().createUser(withEmail: emailAdresi, password: parola){ (kullaniciBilgileri, hata) in
            if let hata = hata{
                debugPrint("Hata meydana geldi \(hata.localizedDescription)")
            }
            // hata meydana gelmedi kullanıcı başarılı bir şekilde oluşturuldu
            
            let changeRequest = kullaniciBilgileri?.user.createProfileChangeRequest()
            changeRequest?.displayName = kullaniciAdi
                changeRequest?.commitChanges(completion: { (hata) in
                if let hata = hata{
                    debugPrint("Kullanıcı Adı güncellenirken hata meydana geldi: \(hata.localizedDescription)")
                }
                
            })
                
                guard let kullaniciId = kullaniciBilgileri?.user.uid else { return }    //her kullanıcının IDsini alıyoruz
                
                Firestore.firestore().collection(KULLANICILAR_REF).document(kullaniciId).setData([
                    KULLANICI_ADI : kullaniciAdi,
                    KULLANICI_OLUSTURMA_TARIHI : FieldValue.serverTimestamp()
                ], completion: { (hata) in
                    
                    if let hata = hata{
                        debugPrint("Kullanıcı Eklenirken Hata meydana geldi \(hata.localizedDescription)")
                    } else{
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    
                })
                
        }
        
    }
}
