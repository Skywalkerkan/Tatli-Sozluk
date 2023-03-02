//
//  YorumCell.swift
//  Tatli Sozluk
//
//  Created by Erkan on 31.01.2023.
//

import UIKit
import FirebaseAuth

class YorumCell: UITableViewCell {

    
    @IBOutlet weak var lblKullaniciAdi: UILabel!
    
    
    @IBOutlet weak var lblTarih: UILabel!
    
    @IBOutlet weak var imgSecenekler: UIImageView!
    @IBOutlet weak var lblYorum: UILabel!
    
    var delegate : YorumDelegate?
    var secilenYorum : Yorum!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(yorum : Yorum,delegate : YorumDelegate?){
        let tarihFormat = DateFormatter()
        tarihFormat.dateFormat = "dd MM YYYY, hh:mm"
        let eklenmeTarihi = tarihFormat.string(from: yorum.eklenmeTarihi)
        lblTarih.text = eklenmeTarihi
        
        
        secilenYorum = yorum
        self.delegate = delegate
        
        
        
        lblKullaniciAdi.text = yorum.kullaniciAdi
        lblYorum.text = yorum.yorumText
        imgSecenekler.isHidden = true
        
        
        if yorum.kullaniciId == Auth.auth().currentUser?.uid{
            imgSecenekler.isHidden = false
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(imgYorumSeceneklerTapped))
            imgSecenekler.isUserInteractionEnabled = true
            imgSecenekler.addGestureRecognizer(tap)
        }
        
    }
    
    @objc func imgYorumSeceneklerTapped(){
        delegate?.seceneklerYorumPressed(yorum: secilenYorum)
    }
    

}


protocol YorumDelegate{
    func seceneklerYorumPressed(yorum : Yorum)
}
