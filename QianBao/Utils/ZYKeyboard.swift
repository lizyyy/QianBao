//
//  ZYKeyboard.swift
//  keyboard
//
//  Created by leeey on 14/8/26.
//  Copyright (c) 2014年 leeey. All rights reserved.
//

import Foundation
import UIKit

protocol ZYKeyboardDelegate {
    func closekeyboard()
    
}

class ZYKeyboard : UIView {
    var delegate : ZYKeyboardDelegate?
    var txtResult : UITextField?
    var result: Double = 0
    var decimals: Bool = false
    var decimalPos: Double = 1
    var operand: Operand?
    var argument: Double = 0
    var start: Bool = true
    var shape:[String:CGFloat] = ["w":ScreenW/4-1,"h":62.00]
    var isAlert =  false
    
    enum Operand {
        case add //+
        case sub //-
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateResult()
        keyboardView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func output(_ value: Double) {
        if !check(value){
            btnClear()
            txtResult?.text = "￥0.00"
            return
        }
        txtResult?.text = String(format: "￥%.12g", value)
    }
    
    func updateResult() {
        output(operand == nil ? result : argument)
    }
    
    func append(_ value: Double, to: Double) -> Double {
        var result: Double = to
        let diff = to >= 0 ? value : -value
        if decimals {
            result += diff / pow(10.0, Double(decimalPos))
            decimalPos += 1
        } else {
            result = result * 10 + diff
        }
        return result
    }
    
    func calc(_ arg1: Double, withOp op: Operand, andArg arg2: Double) -> Double {
        switch op {
        case .add: return arg1 + arg2
        case .sub: return arg1 - arg2
        }
    }
    
    func btnNumber(_ sender: UIButton!){
        let inputInt = Int((sender.titleLabel?.text)!) //(sender.titleLabel?.text?.toInt()!)
        let input = Double(inputInt!)
        if start {
            result = input
            start = false
        } else {
            if operand == nil {
                result = append(input, to: result)
            } else {
                argument = append(input, to: argument)
            }
        }
        updateResult()
    }
    
    func btnClear() {
        result = 0
        argument = 0
        decimalPos = 1
        decimals = false
        operand = nil
        updateResult()
    }
    
    func check(_ number:Double)->Bool{
        if number >= 100000000 || number < 0 {
            shine()
            return false
        }
        return true
    }
    
    func btnOperand(_ sender: UIButton) {
        if operand != nil {
            result = calc(result, withOp: operand!, andArg: argument)
            output(result)
            
        }
        decimalPos = 1
        decimals = false
        argument = 0
        start = false
        if sender.titleLabel?.text == "+" {
            operand = .add
        } else if sender.titleLabel?.text == "-" {
            operand = .sub
        }else {
            operand = nil
            argument = 0
            start = true
        }
    }
    
    func btnPercent(_ sender : UIButton ){
        decimals = true
    }
    
    func keyboardView(){
        let w = ScreenW
        let h = 252
        let borderH = 1
        let borderW = 1
        let btnW =  ( Float(w) - Float( borderW * 5) ) / Float(4)
        let btnH =  ( Float(h) - Float( borderH * 5) ) / Float(4)
        for i in 1 ... 16 {
            let line  = ( i - 1 ) % 4
            let row = ( i - 1 ) / 4
            let xx = Double(btnW) * Double(line) + Double(borderW) * ( Double(line) + 1)
            let yy = Double(btnH) * Double(row) + Double(borderH) * ( Double(row) + 1 )
            let btn = UIButton( frame: CGRect(x: CGFloat(xx), y: CGFloat(yy) , width: CGFloat(btnW), height: CGFloat(btnH)) )
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            btn.setTitle("\(xx),\(yy)",for:UIControlState());
            switch i {
            case 4:
                btn.setTitle("☒",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.closekeyboard(_:)),for:.touchUpInside)
            case 8:
                btn.setTitle("+",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnOperand(_:)),for:.touchUpInside)
            case 12:
                btn.setTitle("-",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnOperand(_:)),for:.touchUpInside)
            case 16:
                btn.setTitle("=",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnOperand(_:)),for:.touchUpInside)
            case 13:
                btn.setTitle("C",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnClear),for:.touchUpInside)
            case 14:
                btn.setTitle("0",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnNumber(_:)),for:.touchUpInside)
            case 15:
                btn.setTitle(".",for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnPercent(_:)),for:.touchUpInside)
            default:
                btn.setTitle(String((row)*3+line+1),for:UIControlState())
                btn.addTarget(self,action:#selector(ZYKeyboard.btnNumber(_:)),for:.touchUpInside)
            }
            btnColor(btn)
            self.addSubview(btn)
        }
    }
    
    
    func btnColor(_ button:UIButton){
        button.setTitleColor(UIColor.darkGray, for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        button.setBackgroundImage(createImageWithColor(color: UIColor.white), for: UIControlState())
        button.setBackgroundImage(createImageWithColor(color: UIColor.gray), for: UIControlState.highlighted)
    }
    
    func shine() {
        UIView.animate(withDuration: 0.2, animations: { self.alphaup()
        }, completion: {
            (completion) in
            if completion {
                self.alphaDown()
                UIView.animate(withDuration: 0.1, animations: { self.alphaup()
                }, completion: {
                    (completion) in
                    if completion {
                        self.alphaDown()
                    }
                })
            }
        })
    }
    
    func alphaup(){
        self.txtResult?.alpha = 0
    }
    
    func alphaDown(){
        self.txtResult?.alpha = 1
    }
    
    func closekeyboard( _ sender: UIButton ){
        delegate?.closekeyboard()
    }
}
