//
//  YorumDuzenleVC.swift
//  Tatli Sozluk
//
//  Created by Erkan on 31.01.2023.
//

import UIKit
import Firebase
class YorumDuzenleVC: UIViewController {

    @IBOutlet weak var guncelleLabel: UIButton!
    @IBOutlet weak var textView: UITextView!
    var yorumVerisi : (secilenYorum: Yorum, secilenFikir: Fikir)!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guncelleLabel.layer.cornerRadius = 15
        textView.layer.cornerRadius = 10
        
        print("Yorum: \(yorumVerisi.secilenYorum.yorumText!)")
        textView.text = yorumVerisi.secilenYorum.yorumText!
    }
    


    @IBAction func guncelleBasildi(_ sender: Any) {
        
                                                                                // sadece boşluk karakteri varsa
        guard let yorumText = textView.text,textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else{return}
        Firestore.firestore()
            .collection(Fikirler_Ref)
            .document(yorumVerisi.secilenFikir
            .documentOd).collection(Yorumlar_REF).document(yorumVerisi.secilenYorum.documentId)
            .updateData([YORUM_TEXT: yorumText]){ (hata) in
                if let hata = hata {
                    debugPrint("Hata meydana geldi \(hata.localizedDescription)")
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
    
}
