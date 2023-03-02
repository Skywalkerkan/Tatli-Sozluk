//
//  AnaVC.swift
//  Tatli Sozluk
//
//  Created by Erkan on 30.01.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AnaVC: UIViewController {

    
    @IBOutlet weak var segmenKategoriler: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var fikirler = [Fikir]()
    private var fikirlerCollectionRef : CollectionReference!  //koleksiyon referans olarak tanımlanıyor
    private var fikirlerListener : ListenerRegistration!   // sürekli acık kalmasını engelliyor ki cihazın batarya tasarrufunu yapalım
    private var secilenKategori = Kategoriler.Eglence.rawValue
    
    private var listenerHandle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //tableView.estimatedRowHeight = 80
        //tableView.rowHeight = UITableView.automaticDimension  // otomatik olarak cellin uzunlugunu belirliyor
        fikirlerCollectionRef = Firestore.firestore().collection(Fikirler_Ref)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let girisVC = storyboard.instantiateViewController(withIdentifier: "GirisVC")
                self.present(girisVC, animated: true, completion: nil)
            }else{
                self.setListener()
            }
        })
        


       // fikirlerCollectionRef.getDocuments
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if fikirlerListener != nil{
            fikirlerListener.remove()
        }

    }
    
    func setListener(){
        
        if secilenKategori == Kategoriler.Populer.rawValue{ // populer icin wherefielda gerek yok
            fikirlerListener = fikirlerCollectionRef.yeniWhereSorgu().addSnapshotListener{
                (snapshot, error) in  // snapshot gelen veriler getirir      //eklenme tarihine göre sıraladık
                if let error = error{
                    debugPrint("Kayıtlar getirilirken hata meydana geldi: \(error.localizedDescription)")
                }else{
                    self.fikirler.removeAll()  // aynı verilerin tekrar 2. kez görülmesini önlemek için silmemiz gerekiyor
                    self.fikirler = Fikir.fikirGetir(snapshot: snapshot, begeniyeGore: true)
                    self.tableView.reloadData()
                }
                
            }
        }
        else{                           //wherefield fonksiyonu firebasedek iistenilen verileri çekmemize yardımcı olur.
            fikirlerListener = fikirlerCollectionRef.whereField(Kategori, isEqualTo: secilenKategori).order(by: Eklenme_Tarihi, descending: true).addSnapshotListener{
                (snapshot, error) in  // snapshot gelen veriler getirir      //eklenme tarihine göre sıraladık
                if let error = error{
                    debugPrint("Kayıtlar getirilirken hata meydana geldi: \(error.localizedDescription)")
                }else{
                    self.fikirler.removeAll()  // aynı verilerin tekrar 2. kez görülmesini önlemek için silmemiz gerekiyor
                    self.fikirler = Fikir.fikirGetir(snapshot: snapshot)
                    self.tableView.reloadData()
                }
                
            }
        }
        
        
        
        

    }
    


    
    @IBAction func kategoriChanged(_ sender: Any) {
        switch segmenKategoriler.selectedSegmentIndex{
        case 0:
            secilenKategori = Kategoriler.Eglence.rawValue
        case 1:
            secilenKategori = Kategoriler.Absurt.rawValue
        case 2:
            secilenKategori = Kategoriler.Gundem.rawValue
        case 3:
            secilenKategori = Kategoriler.Populer.rawValue
        default:
            secilenKategori = Kategoriler.Eglence.rawValue
        }
        
        fikirlerListener.remove()
        setListener()
    }
    
    @IBAction func btnOturumKapatPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do{
            try firebaseAuth.signOut()
        }catch let signOurError as NSError{
            print("Error signing out \(signOurError)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "YorumlarSegue"{
            if let hedefVC = segue.destination as? YorumlarVC{
                if let secilenFikir = sender as? Fikir{
                    hedefVC.secilenFilir = secilenFikir
                }
            }
        }
    }
    
}



extension AnaVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fikirler.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "fikirCell", for: indexPath) as? FikirCell{
            cell.configure(fikir: fikirler[indexPath.row],delegate: self)
            return cell
        }else{
            return UITableViewCell()
        }

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "YorumlarSegue", sender: fikirler[indexPath.row])
    }
    
    

}

extension AnaVC: FikirDelegate{
    func seceneklerFikirPressed(fikir: Fikir) {
        // print("Seçilen Fikir: \(fikir.fikirText!)")
        
        
        
        
        
        let alert = UIAlertController(title: "Fikri Düzenle", message: "Düzenleyebilir Ya da Silebilirsiniz", preferredStyle: .actionSheet)
        
        let silAction = UIAlertAction(title: "Paylaşımı Sil", style: .default){ (action) in
            //Fikir silinecek
            
            // delete fonksiyonu sadece collectionları siler altındaki subcollectionları silmez !!!!!!
            let yorumlarCollRef = Firestore.firestore().collection(Fikirler_Ref).document(fikir.documentOd).collection(Yorumlar_REF)
            let begenilerColRef = Firestore.firestore().collection(Fikirler_Ref).document(fikir.documentOd).collection(BEGENİ_REF)
            print(yorumlarCollRef)
            
            self.topluKayitSil(collectionRef: begenilerColRef, completion: {(hata) in
                
                if let hata = hata{
                    debugPrint("Beğenileri Silerken hata meydana geldi: \(hata.localizedDescription)")
                }else{
                    self.topluKayitSil(collectionRef: yorumlarCollRef, completion: { (hata) in
                        print("akaskdfafdsafgds")
                        if let hata = hata{
                            debugPrint("Fikirler silinirken hata oluştuu\(hata.localizedDescription)")
                        }else{
                            Firestore.firestore().collection(Fikirler_Ref).document(fikir.documentOd).delete{ (hata) in
                                if let hata = hata{
                                    debugPrint("Hata meydana geldi fikir silinirken \(hata.localizedDescription)")
                                }else{
                                    print(" afdsgsdagsad")
                                    alert.dismiss(animated: true,completion: nil)
                                }
                                
                            }
                        }
                        
                    })
                }
            })
            

            // delete fonksiyonu sadece collectionları siler altındaki subcollectionları silmez !!!!!!

            
        }
        
        let iptalAction = UIAlertAction(title: "İptal", style: .default)
        
        alert.addAction(silAction)
        alert.addAction(iptalAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // delete fonksiyonu sadece collectionları siler altındaki subcollectionları silmez !!!!!!
    func topluKayitSil(collectionRef : CollectionReference, silinecekKayitSayisi: Int = 100, completion : @escaping(Error?) -> ()) {
        collectionRef.limit(to: silinecekKayitSayisi).getDocuments{ (kayitSetleri,hata) in
            guard let kayitSetleri = kayitSetleri else{
                completion(hata)
                return
            }
            guard kayitSetleri.count > 0 else{   // yorum colelcitonu içinde yorum olduğu sürece çalışmaya devam edecek ve 100 er 100 er silecek
                completion(nil)
                return
            }
                                                            //birden fazla işlem yapmak için batchi kullanıyoruz
            let batch = collectionRef.firestore.batch()   //write işlemi oluşturma düzenleme silme işlemi demek
            kayitSetleri.documents.forEach{ batch.deleteDocument($0.reference)}
                
                batch.commit{ (batchHata) in
                    if let hata = batchHata {
                        completion(hata)
                    }else{
                        self.topluKayitSil(collectionRef: collectionRef, silinecekKayitSayisi: silinecekKayitSayisi, completion: completion)
                    }
                    
                }
            }
            
            
        }
    }



