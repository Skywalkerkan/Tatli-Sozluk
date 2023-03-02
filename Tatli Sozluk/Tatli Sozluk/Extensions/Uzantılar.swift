//
//  Uzantılar.swift
//  Tatli Sozluk
//
//  Created by Erkan on 1.02.2023.
//

import Foundation
import Firebase

extension CollectionReference{
    
    
    func yeniWhereSorgu() -> Query{
        
        let tarihVeriler = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        
        guard let bugun = Calendar.current.date(from: tarihVeriler),
              let bitis = Calendar.current.date(byAdding: .hour, value: 24, to: bugun),
              let baslangic = Calendar.current.date(byAdding: .day, value: -2, to: bugun)else {
            fatalError("Belirtilen Tarih aralıklarında herhangi bir kayıt bulunamadı")
        }
        
        //return whereField(Eklenme_Tarihi, isLessThanOrEqualTo: bitis).whereField(Eklenme_Tarihi, isGreaterThanOrEqualTo:
        //                                                                          baslangic).limit(to: 30)  // tarihsel bir aralık belirtiyoruz
        // 30 tane veri getir
        //orderla begeni sayısına göer sıralayamıyoruz wherefielddayafarklı
        //bir veri olduğu için
        return whereField(Eklenme_Tarihi, isLessThanOrEqualTo: bitis).whereField(Eklenme_Tarihi, isGreaterThan: bugun).limit(to: 30)
    }
}
