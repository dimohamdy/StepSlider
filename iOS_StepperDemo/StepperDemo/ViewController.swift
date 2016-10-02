//
//  ViewController.swift
//  StepperDemo
//
//  Created by BinaryBoy on 10/2/16.
//  Copyright © 2016 BinaryBoy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//    @property (nonatomic, strong) IBOutlet StepSlider *sliderView;
//    @property (nonatomic, strong) IBOutlet UILabel *label;
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var sliderView: StepSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

