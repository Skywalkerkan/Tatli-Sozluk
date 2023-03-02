//
//  Fikir.swift
//  Tatli Sozluk
//
//  Created by Erkan on 30.01.2023.
//

import Foundation
import Firebase

class Fikir{
    
    private(set) var kullaniciAdi : String!
    private(set) var eklenmeTarihi : Date!
    private(set) var fikirText: String!
    private(set) var yorumSayisi : Int!
    private(set) var begeniSayisi: Int!
    private(set) var documentOd: String!
    private(set) var kullaniciId : String!
    
    init(kullaniciAdi: String!, eklenmeTarihi: Date!, fikirText: String!, yorumSayisi: Int!, begeniSayisi: Int!, documentOd: String!, kullaniciId: String!) {
        self.kullaniciAdi = kullaniciAdi
        self.eklenmeTarihi = eklenmeTarihi
        self.fikirText = fikirText
        self.yorumSayisi = yorumSayisi
        self.begeniSayisi = begeniSayisi
        self.documentOd = documentOd
        self.kullaniciId = kullaniciId 
    }
    
    class func fikirGetir(snapshot: QuerySnapshot?,begeniyeGore : Bool = false, yorumaGore: Bool = false) -> [Fikir]{
        var fikirler = [Fikir]()
        guard let snap = snapshot else{return fikirler}
        for document in snap.documents{
            let data = document.data()   // Bütün dökümanları çağırıyoruz
            
            let kullaniciAdi = data[Kullanici_Adi] as? String ?? "Misafir"
           // let eklenmeTarihi = data[Eklenme_Tarihi] as? Date ?? Date()
            let timeStamp = data[Eklenme_Tarihi] as? Timestamp ?? Timestamp()
            let eklenmeTarihi = timeStamp.dateValue()
            let fikirText = data[Fikir_Tex] as? String ?? ""
            let yorumSayisi = data[Yorum_Sayisi] as? Int ?? 0
            let begeniSayisi = data[Begeni_Sayisi] as? Int
            let documentId = document.documentID
            let kullaniciId = data[KULLANICI_ID] as? String ?? ""
            
            let yeniFikir = Fikir(kullaniciAdi: kullaniciAdi, eklenmeTarihi: eklenmeTarihi, fikirText: fikirText, yorumSayisi: yorumSayisi, begeniSayisi: begeniSayisi, documentOd: documentId, kullaniciId: kullaniciId)
            
            fikirler.append(yeniFikir)
            
        }
        
        if begeniyeGore{
            fikirler.sort{$0.begeniSayisi > $1.begeniSayisi }
        } // beğeni sayısını göre sıralıyoruz
        
        if yorumaGore{
            fikirler.sort{$0.yorumSayisi > $1.yorumSayisi}
        }
        
        return fikirler
    }
    
}
