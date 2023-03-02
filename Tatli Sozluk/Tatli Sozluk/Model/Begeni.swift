//
//  Begeni.swift
//  Tatli Sozluk
//
//  Created by Erkan on 31.01.2023.
//

import Foundation
import Firebase
import FirebaseAuth

class Begeni{
    
    private(set) var kullaniciId : String
    private(set) var documentId : String
    
    init(kullaniciId: String, documentId: String) {
        self.kullaniciId = kullaniciId
        self.documentId = documentId
    }
    
    class func begenileriGetir(snapshot: QuerySnapshot?) -> [Begeni]{
        var begeniler = [Begeni]()
        
        guard let snap = snapshot else { return begeniler}
        
        for kayit in snap.documents{
            let veri = kayit.data()
            let kullaniciId = veri[KULLANICI_ID] as? String ?? ""
            let documentId = kayit.documentID
            
            let yeniBegeni = Begeni(kullaniciId: kullaniciId, documentId: documentId)
            
            begeniler.append(yeniBegeni)
        }
        return begeniler
        
        
        
    }
    
    
}
