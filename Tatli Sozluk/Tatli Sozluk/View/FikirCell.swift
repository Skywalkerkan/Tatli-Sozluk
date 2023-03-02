//
//  FikirCell.swift
//  Tatli Sozluk
//
//  Created by Erkan on 30.01.2023.
//

import UIKit
import Firebase
import FirebaseAuth


class FikirCell: UITableViewCell {

    @IBOutlet weak var lblBegeniSayisi: UILabel!
    @IBOutlet weak var imgBegeni: UIImageView!
    @IBOutlet weak var lblYorum: UILabel!
    @IBOutlet weak var lblTarih: UILabel!
    @IBOutlet weak var lblKullaniciAdi: UILabel!
    
    @IBOutlet weak var imgSecenekler: UIImageView!
    @IBOutlet weak var lblYorumSayisi: UILabel!
    var secilenFikir : Fikir!
    var delegate : FikirDelegate?
    
    let fireStore = Firestore.firestore()
    var begeniler = [Begeni]()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgBegeniTapped))
        imgBegeni.addGestureRecognizer(tap)
        imgBegeni.isUserInteractionEnabled = true
        
        
    }
    // şuan oturum açmış kullanıcı beğenmiş mi beğenmemiş mi
    func begenileriGetir(){                                                             // sadece şuanki kullanıcının IDSİNİ GETİRİYORUM  BEGENMİŞ MİSORGULAMAK                                                                                                                                 İÇİN
        let begeniSorgu = fireStore.collection(Fikirler_Ref).document(self.secilenFikir.documentOd).collection(BEGENİ_REF).whereField(KULLANICI_ID, isEqualTo: Auth.auth().currentUser?.uid ?? "")
        
        begeniSorgu.getDocuments{ (snapshot,hata) in
            self.begeniler = Begeni.begenileriGetir(snapshot: snapshot)
            
            if self.begeniler.count > 0 {
                self.imgBegeni.image = UIImage(named: "yildizRenkli")
            }else{
                self.imgBegeni.image = UIImage(named: "yildizTransparan")
            }
        }
    }
    
    @objc func imgBegeniTapped(){
        
                                                //secilen yorumun yıldızını değiştirmek için dokumanın idsni bulup koyuyoruz
        //Firestore.firestore().collection(Fikirler_Ref).document(secilenFikir.documentOd).setData([
           // Begeni_Sayisi: secilenFikir.begeniSayisi + 1], merge: true) // merge true yapmasaydık sadece beğeniyi yapardı ve diğer verileri keserdi
        
                                                    //document ID optional oldugu icin force unwrap yapmak zorundayız
        /*Firestore.firestore().document("Fikirler/\(secilenFikir.documentOd!)").updateData(
            [Begeni_Sayisi: secilenFikir.begeniSayisi + 1])*/   // Bu yolla mergle ugraşmadan direk olarak dokumantasyonun verisini güncelliyor
        
        fireStore.runTransaction({ (transaction, hata) -> Any? in
            
            let secilenFikirKayit : DocumentSnapshot
            
            do{
                
                try secilenFikirKayit = transaction.getDocument(self.fireStore.collection(Fikirler_Ref).document(self.secilenFikir.documentOd))
            }catch let hata as NSError{
                debugPrint("Begenide hata oluştu\(hata.localizedDescription)")
                return nil
            }
            
            
            guard let eskiBegeniSayisi = (secilenFikirKayit.data()?[Begeni_Sayisi] as? Int) else {return nil}
            
            let secilenFikirRef = self.fireStore.collection(Fikirler_Ref).document(self.secilenFikir.documentOd)
            
            if self.begeniler.count > 0{
                //Kullanici begenmiş ve begeniden çıkmak üzere butona basmış
                
                transaction.updateData([Begeni_Sayisi: eskiBegeniSayisi-1], forDocument: secilenFikirRef)
                let eskiBegeniRef = self.fireStore.collection(Fikirler_Ref).document(self.secilenFikir.documentOd).collection(BEGENİ_REF).document(self.begeniler[0].documentId)
                
                transaction.deleteDocument(eskiBegeniRef)
            }else{
                //Kullanıcı beğenmemiş beğenecek
                
                transaction.updateData([Begeni_Sayisi: eskiBegeniSayisi+1], forDocument: secilenFikirRef)
            
                let yeniBegeniRef = self.fireStore.collection(Fikirler_Ref).document(self.secilenFikir.documentOd).collection(BEGENİ_REF).document()
            
                transaction.setData([KULLANICI_ID: Auth.auth().currentUser?.uid ?? ""], forDocument: yeniBegeniRef)
                
                
            }
            
            return nil
            
        }){ (nesne, hata) in
            
            if let hata = hata{
                debugPrint("Beğenilerde hata oluştu \(hata.localizedDescription)")
            }
            
        }
        
         
        
    }

    
    func configure(fikir : Fikir , delegate : FikirDelegate?){
        
        secilenFikir = fikir
        lblKullaniciAdi.text = fikir.kullaniciAdi
        lblYorum.text = fikir.fikirText
        lblBegeniSayisi.text = "\(fikir.begeniSayisi ?? 0)"
        
        let tarihFormat = DateFormatter()
        tarihFormat.dateFormat = "dd MM YYYY, hh:mm"
        let eklenmeTarihi = tarihFormat.string(from: fikir.eklenmeTarihi)
        lblTarih.text = eklenmeTarihi
        lblYorumSayisi.text = "\(fikir.yorumSayisi ?? 0)"
        
        
        imgSecenekler.isHidden = true
        self.delegate = delegate
        
        if fikir.kullaniciId == Auth.auth().currentUser?.uid{
            imgSecenekler.isHidden = false
            imgSecenekler.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgFikirSeceneklerTapped))
            imgSecenekler.addGestureRecognizer(tap)
        }
        
        begenileriGetir()
    }
    
    
    @objc func imgFikirSeceneklerTapped(){
        delegate?.seceneklerFikirPressed(fikir: secilenFikir)
    }
 

}


protocol FikirDelegate{
    func seceneklerFikirPressed(fikir: Fikir)
    
    
}
