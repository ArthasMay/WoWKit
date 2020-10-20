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
    }
    
    @IBAction func save(_ sender: Any) {
        if test_IOSegment.selectedSegmentIndex == 0 {
            test_FastKVIO()
        } else {
            test_NSUserDefaults()
        }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
