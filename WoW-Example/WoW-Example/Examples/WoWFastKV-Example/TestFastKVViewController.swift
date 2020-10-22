//
//  TestFastKVViewController.swift
//  WoW-Example
//
//  Created by Silence on 2020/10/20.
//  Copyright © 2020 Silence. All rights reserved.
//

import UIKit

class TestFastKVViewController: UIViewController {

    @IBOutlet weak var durationL: UILabel!
    @IBOutlet weak var timeCostL: UILabel!
    @IBOutlet weak var test_IOSegment: UISegmentedControl!
    @IBOutlet weak var testTF: UITextView!
    lazy var fastKV: WoWFastKV = WoWFastKV.default
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        durationL.layer.borderWidth = 1
        durationL.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Action
    @IBAction func open(_ sender: Any) {
        timeCostL.text = fastKV.headerInfo
        if let testC: TestKVCodable = fastKV.codable(for: "TestCodable") {
            timeCostL.text = testC.name
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if test_IOSegment.selectedSegmentIndex == 0 {
            test_FastKVIO()
        } else {
            test_NSUserDefaults()
        }
    }
    
    func testCodableEncode() {
        let codableObj = TestKVCodable(name: "你好")
        fastKV.setCodable(obj: codableObj, for: "TestCodable")
    }
    
    func test_FastKVIO() {
        var nums = [Int]()
        var keys = [String]()
        for num in 0...10000 {
            nums.append(num)
            keys.append("test_\(num)")
        }
        let startTime = CFAbsoluteTimeGetCurrent()
        var idx = 0
        nums.forEach {
            fastKV.setInteger(val: $0, for: keys[idx])
            idx = idx + 1
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let benchmark = ((endTime - startTime) * 1000)
        timeCostL.text = "    \(benchmark) ms"
    }
    
    func test_NSUserDefaults() {
        var nums = [Int]()
        var keys = [String]()
        for num in 0...10000 {
            nums.append(num)
            keys.append("test_\(num)")
        }
        let startTime = CFAbsoluteTimeGetCurrent()
        var idx = 0
        nums.forEach {
            UserDefaults.standard.set($0, forKey: keys[idx])
            idx = idx + 1
            UserDefaults.standard.synchronize()
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        let benchmark = ((endTime - startTime) * 1000)
        timeCostL.text = "    \(benchmark) ms"
    }
    
    @IBAction func reset(_ sender: Any) {
        if test_IOSegment.selectedSegmentIndex == 0 {
            fastKV.removeAllKeys()
        } else {
            UserDefaults.resetStandardUserDefaults()
        }
    }
    
    @IBAction func clean(_ sender: Any) {
        if test_IOSegment.selectedSegmentIndex == 0 {
            fastKV.cleanUp()
        } else {
            UserDefaults.resetStandardUserDefaults()
        }
    }
    
    @IBAction func testAllType(_ sender: Any) {
        fastKV.setBool(val: true, for: "test_bool")
        fastKV.setInteger(val: 8888, for: "test_integer")
        fastKV.setFloat(val: 1.888, for: "test_float")
        fastKV.setDouble(val: 1.888888, for: "test_double")
        fastKV.setObject(obj: "Object", for: "test_object")
        fastKV.setCodable(obj: TestKVCodable(name: "Codable"), for: "test_codable")
    }
    
    @IBAction func getAllTypeValues(_ sender: Any) {
        var valuesStr = ""
        if let boolVal = fastKV.bool(for: "test_bool") {
            valuesStr += "Bool: \(boolVal ? "True" : "False")\n"
        }
        
        if let integerVal = fastKV.integer(for: "test_integer") {
            valuesStr += "Integer: \(integerVal)\n"
        }
        
        if let floatVal = fastKV.float(for: "test_float") {
            valuesStr += "Float: \(floatVal)\n"
        }
        
        if let doubleVal = fastKV.double(for: "test_double") {
            valuesStr += "Double: \(doubleVal)\n"
        }
        
        if let objectVal = fastKV.object(for: "test_object") {
            valuesStr += "Object: \(objectVal)\n"
        }
        
        if let codable: TestKVCodable = fastKV.codable(for: "test_codable") {
            valuesStr += "Codable: \(codable.name)"
        }
        
        testTF.text = valuesStr
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
