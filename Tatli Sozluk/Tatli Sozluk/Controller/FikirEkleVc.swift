//
//  FikirEkleVc.swift
//  Tatli Sozluk
//
//  Created by Erkan on 30.01.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FikirEkleVc: UIViewController {

    
    @IBOutlet weak var segmentKategoriler: UISegmentedControl!
    
    @IBOutlet weak var txtKullaniciAdi: UITextField!
    
    @IBOutlet weak var btnPaylas: UIButton!
    @IBOutlet weak var txtFikirPostu: UITextView!
    
    let placeHolderText = "Fikrinizi Belirtin.."
    
    var secilenKatergori = "Eğlence"
    var kullaniciAdi : String = "Misafir"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPaylas.layer.cornerRadius = 20
        txtFikirPostu.layer.cornerRadius = 10
        
        txtFikirPostu.text = placeHolderText
        txtFikirPostu.textColor = .lightGray
        txtFikirPostu.delegate = self
        
        txtKullaniciAdi.isEnabled = false
        
        if let adi = Auth.auth().currentUser?.displayName{
            kullaniciAdi = adi
            txtKullaniciAdi.text = kullaniciAdi
        }
    }
    
    @IBAction func segmentDegisti(_ sender: Any) {
        
        switch segmentKategoriler.selectedSegmentIndex{
        case 0:
            secilenKatergori = Kategoriler.Eglence.rawValue
        case 1:
            secilenKatergori = Kategoriler.Absurt.rawValue
        case 2:
            secilenKatergori = Kategoriler.Gundem.rawValue
        default:
            secilenKatergori = Kategoriler.Eglence.rawValue
        }
        
    }
    
    @IBAction func btnBasildi(_ sender: Any) {
        guard /*let kullaniciAdi = txtKullaniciAdi.text,*/ txtFikirPostu.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else{return}
        
        Firestore.firestore().collection(Fikirler_Ref).addDocument(data: [
             Kategori : secilenKatergori,
             Begeni_Sayisi: 0,
             Yorum_Sayisi: 0,
             Fikir_Tex : txtFikirPostu.text!,
             Eklenme_Tarihi: FieldValue.serverTimestamp(),
             Kullanici_Adi : kullaniciAdi,
             KULLANICI_ID : Auth.auth().currentUser?.uid ?? ""
        ]){ (hata) in
            
            if let hata = hata{
                print("Document Hatası: \(hata.localizedDescription)")
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    

}


extension FikirEkleVc : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeHolderText{
            textView.text = ""
            textView.textColor = .darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            txtFikirPostu.text = placeHolderText
            txtFikirPostu.textColor = .lightGray
        }
    }
    
    
}
