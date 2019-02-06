//
//  FormViewController.swift
//  calculadora-irpf
//
//  Created by Victor Franca on 26/09/18.
//  Copyright © 2018 Victor Franca. All rights reserved.
//

import UIKit


class FormViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtRendimentoTributavel: CurrencyTextField!
    @IBOutlet weak var txtPrevidenciaSocial: CurrencyTextField!
    @IBOutlet weak var txtDependente: UITextField!
    @IBOutlet weak var txtPensaoAlimenticia: CurrencyTextField!
    @IBOutlet weak var txtOutrasDeducoes: CurrencyTextField!
    
    @IBOutlet weak var txtValorDependentes: UITextField!
    @IBOutlet weak var txtTotalDeDeducoes: UITextField!
    @IBOutlet weak var txtBaseDeCalculo: UITextField!
    @IBOutlet weak var txtImposto: UITextField!
    @IBOutlet weak var txtAliquota: UITextField!
    
    var vlrDependentes: Double! = 0;
    var vlrTotalDeducoes: Double! = 0;
    var vlrBaseCalculo: Double! = 0;
    var vlrAliquota: Double! = 0;
    var vlrImposto: Double! = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        txtRendimentoTributavel.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtRendimentoTributavel.delegate = self
        
        txtPrevidenciaSocial.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtPrevidenciaSocial.delegate = self
        
        txtDependente.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtDependente.keyboardType = UIKeyboardType.numberPad
        txtDependente.text = Int(0).description
        txtDependente.delegate = self
        
        txtPensaoAlimenticia.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtPensaoAlimenticia.delegate = self
        
        txtOutrasDeducoes.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtOutrasDeducoes.delegate = self
        
        txtValorDependentes.text = vlrTotalDeducoes.currencyFormattedWithSeparator
        txtValorDependentes.isUserInteractionEnabled = false

        txtTotalDeDeducoes.text = vlrTotalDeducoes.currencyFormattedWithSeparator
        txtTotalDeDeducoes.isUserInteractionEnabled = false
        
        txtBaseDeCalculo.text = vlrBaseCalculo.currencyFormattedWithSeparator
        txtBaseDeCalculo.isUserInteractionEnabled = false

        txtAliquota.text = String(vlrAliquota!)
        txtAliquota.isUserInteractionEnabled = false

        txtImposto.text = vlrImposto.currencyFormattedWithSeparator
        txtImposto.isUserInteractionEnabled = false
    }
    
    //Backspace tapped
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == txtDependente){
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 2 // Bool
        }
        
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            (textField as! CurrencyTextField).deleteBackward()
            updateCalculatedFields()
        }
        return true
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField? = nil) {
        if(textField == txtDependente){
            return
        }
        updateCalculatedFields()
    }
    
    func updateCalculatedFields(){
        if(txtDependente.text?.isEmpty)!{
           txtDependente.text = Int(0).description
        }
        
        //removes leading zeros
        txtDependente.text = "\(Int(txtDependente.text!)!)"
        vlrDependentes = (Double(txtDependente.text!)!*189.59)
        txtValorDependentes.text = vlrDependentes.currencyFormattedWithSeparator
        vlrTotalDeducoes = txtPrevidenciaSocial.doubleValue + vlrDependentes + txtPensaoAlimenticia.doubleValue + txtOutrasDeducoes.doubleValue
        txtTotalDeDeducoes.text = vlrTotalDeducoes.currencyFormattedWithSeparator
        
        vlrBaseCalculo = txtRendimentoTributavel.doubleValue - vlrTotalDeducoes
        if(vlrBaseCalculo < 0){
            vlrBaseCalculo = 0
        }
        txtBaseDeCalculo.text = vlrBaseCalculo.currencyFormattedWithSeparator
        
        vlrImposto = calcularImposto()
        txtImposto.text = vlrImposto.currencyFormattedWithSeparator

        vlrAliquota = calcularAliquota()
        txtAliquota.text = String("\(vlrAliquota.decimalFormattedWithSeparator)%")
    }
    
    func calcularImposto() -> Double{
        
        var faixa1 = 0.0
        if(vlrBaseCalculo >= 1903.98){
            faixa1 = 1903.98
        }else{
            faixa1 = 0
        }

        var faixa2 = 0.0
        if(vlrBaseCalculo >= 1903.99 && vlrBaseCalculo <= 2826.65){
            faixa2 = vlrBaseCalculo - 1903.99
        }else if(vlrBaseCalculo > 2826.65){
            faixa2 = 922.67
        }

        var faixa3 = 0.0
        if(vlrBaseCalculo >= 2826.66 && vlrBaseCalculo <= 3751.05){
            faixa3 = vlrBaseCalculo - 2826.66
        }else if(vlrBaseCalculo > 3751.05){
            faixa3 = 924.40
        }
        
        var faixa4 = 0.0
        if(vlrBaseCalculo >= 3751.06 && vlrBaseCalculo <= 4664.68){
            faixa4 = vlrBaseCalculo - 3751.05
        }else if(vlrBaseCalculo > 4664.68){
            faixa4 = 913.63
        }
        
        var faixa5 = 0.0
        if(vlrBaseCalculo > 4664.68){
            faixa5 = vlrBaseCalculo - 4664.68
        }
        
        let aliquota = faixa1 * 0.00/100 + faixa2 * 7.5/100 + faixa3 * 15/100 + faixa4 * 22.5/100 + faixa5 * 27.5/100
        return aliquota
    }

    func calcularAliquota() -> Double{
        return ((vlrImposto / txtRendimentoTributavel.doubleValue) * 100)
    }

}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
    
    var currencyFormattedWithSeparator: String {
        return Formatter.currencyWithSeparator.string(for: self) ?? ""
    }

    var decimalFormattedWithSeparator: String {
        return Formatter.decimalWithSeparator.string(for: self) ?? ""
    }
}

extension Formatter {
    static let currencyWithSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .up
        formatter.locale = Locale(identifier: "pt_BR") // or "en_US", "fr_FR", etc
        return formatter
    }()

    static let decimalWithSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .up
        formatter.locale = Locale(identifier: "pt_BR") // or "en_US", "fr_FR", etc
        return formatter
    }()
}

extension String{
    // Returns true if the string contains only characters found in matchCharacters.
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
}

