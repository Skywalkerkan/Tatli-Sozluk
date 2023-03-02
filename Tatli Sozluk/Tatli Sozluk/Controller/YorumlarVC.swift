//
//  YorumlarVC.swift
//  Tatli Sozluk
//
//  Created by Erkan on 31.01.2023.
//

import UIKit
import Firebase
import FirebaseAuth

class YorumlarVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var secilenFilir: Fikir!
    var yorumlar = [Yorum]()
    var fikirRef : DocumentReference!
    
    let fireStore = Firestore.firestore()
    var kullaniciAdi : String!
    
    var yorumlarListener : ListenerRegistration!
    
    
    @IBOutlet weak var txtYorum: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // HANGİ FİKİRE YORUM YAPIALCAKSA TÜM YAPACAĞIMIZ İŞLEMLERİ ONUN ÜZERİNDEN YAPACAĞIMIZ İÇİN REFERANSINA İHTİYAÇ DUYACAĞIZ
        fikirRef = fireStore.collection(Fikirler_Ref).document(secilenFilir.documentOd)
        if let adi = Auth.auth().currentUser?.displayName{
            kullaniciAdi = adi
            
        }
        
        self.view.klavyeAyarla()
    }
    
    
    /*override func viewWillAppear(_ animated: Bool) {
        <#code#>
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        yorumlarListener = fireStore.collection(Fikirler_Ref).document(secilenFilir.documentOd).collection(Yorumlar_REF)
            .order(by: Eklenme_Tarihi, descending: true)
            .addSnapshotListener({(snapshot, hata) in
                
                guard let snapshot = snapshot else{
                    debugPrint("Getirilirken hata yorum \(hata?.localizedDescription)")
                    return
                }
                
                self.yorumlar.removeAll()
                self.yorumlar = Yorum.yorumlariGetir(snapshot: snapshot)
                self.tableView.reloadData()
            })
    }
    
    
    @IBAction func btnYorumEkleTapped(_ sender: Any) {
        guard let yorumText = txtYorum.text, txtYorum.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != true else {return}
        if yorumText.isEmpty{
            return
        }
        fireStore.runTransaction({(transaction, errorPointer) -> Any? in
            
            let secilenFikirKayit : DocumentSnapshot
            do{
                try secilenFikirKayit = transaction.getDocument(self.fikirRef)
                
            }catch let hata as NSError{
                debugPrint("Hata Meydana Geldi: \(hata.localizedDescription)")
                return nil
            }
            
            //seçilen fikrin yorum sayısını ele almamız gerekiyor şimdi
            
            
            guard let eskiYorumSayisi = (secilenFikirKayit.data()?[Yorum_Sayisi] as? Int) else {return nil}
            
            transaction.updateData([Yorum_Sayisi: eskiYorumSayisi+1], forDocument: self.fikirRef) //yıldız sayısını güncelliyorum
            
            
            //kolleksiyonun içindeki dokumana yeni bri yorum koleksiyonu atıyoruz
            let yeniYorumRef = self.fireStore.collection(Fikirler_Ref).document(self.secilenFilir.documentOd).collection(Yorumlar_REF).document()
            
            transaction.setData([
                YORUM_TEXT : yorumText,
                Eklenme_Tarihi : FieldValue.serverTimestamp(),
                KULLANICI_ADI : self.kullaniciAdi,
                KULLANICI_ID : Auth.auth().currentUser?.uid 
            
            
            ], forDocument: yeniYorumRef)
            
            
            return nil
            
        }){ (nesne, hata) in
            
            if let hata = hata {
                debugPrint("Hata Meydana geldi Transaction : \(hata.localizedDescription)")
            }else{
                self.txtYorum.text
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "yorumDuzenleSegue"{
            if let hedefVC = segue.destination as? YorumDuzenleVC{
                if let yorumVeri = sender as? (secilenYorum: Yorum, secilenFikir: Fikir){
                    hedefVC.yorumVerisi = yorumVeri
                }
            }
        }
    }
    
}



extension YorumlarVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "yorumCell", for: indexPath) as? YorumCell{
            cell.configure(yorum: yorumlar[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yorumlar.count
    }
}



extension YorumlarVC : YorumDelegate{
    func seceneklerYorumPressed(yorum: Yorum) {
        let alert = UIAlertController(title: "Yorumu Düzenle", message: "Düzenleyebilir Ya da Silebilirsiniz", preferredStyle: .actionSheet)
        
        let silAction = UIAlertAction(title: "Yorumu Sil", style: .default) {(action) in
            // yorum silinecek
            /*self.fireStore.collection(Fikirler_Ref).document(self.secilenFilir.documentOd)
                .collection(Yorumlar_REF).document(yorum.documentId).delete(completion: { (hata) in
                    if let hata = hata{
                        debugPrint("Yorum siliniriken hata meydana geldi: \(hata.localizedDescription)")
                    }else{
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                })*/
            
            
            self.fireStore.runTransaction({(transection, hata) -> Any? in
                
                let secilenFikirKayit : DocumentSnapshot  // transection islemlerde önce okuma işlemleri yapılır sonra yazma yapılır
                
                do{
                    try secilenFikirKayit = transection.getDocument(self.fireStore.collection(Fikirler_Ref).document(self.secilenFilir.documentOd))
                }catch let hata as NSError{
                    debugPrint("Fikir Bulunmaadı \(hata.localizedDescription)")
                    return nil
                }
                
                guard let eskiYorumSayisi = (secilenFikirKayit.data()?[Yorum_Sayisi] as? Int) else{return nil}
                transection.updateData([Yorum_Sayisi : eskiYorumSayisi-1], forDocument: self.fikirRef)
                let silinecekYorumRef = self.fireStore.collection(Fikirler_Ref).document(self.secilenFilir.documentOd).collection(Yorumlar_REF).document(yorum.documentId)
                
                transection.deleteDocument(silinecekYorumRef)
                return nil
            }) {(nesne, hata) in
                if let hata = hata{
                    debugPrint("Yorum Silerken Hata Meydana Geldi: \(hata.localizedDescription)")
                }else{
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            
            
            
        }
        
        let duzenleAction = UIAlertAction(title: "Yorumu Düzenle", style: .default){(action) in
            // yorum düzenlenecek
            
            self.performSegue(withIdentifier: "yorumDuzenleSegue", sender: (yorum,self.secilenFilir))
            self.dismiss(animated: true, completion: nil)
        }
        
        let iptalAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        alert.addAction(silAction)
        alert.addAction(duzenleAction)
        alert.addAction(iptalAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
