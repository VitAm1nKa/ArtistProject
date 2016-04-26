//
//  TmpViewController.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 20.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import UIKit

class TmpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBOutlet var viewView: UIView! {
        didSet {
            UIGraphicsBeginImageContext(viewView.frame.size)
            UIImage(named: "bgIOS")?.drawInRect(viewView.bounds)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            viewView.backgroundColor = UIColorFromRGB(0x34aadc, alpha: 0.7)
            
            let viewTest = UIView(frame: viewView.bounds)
            viewTest.backgroundColor = UIColor(patternImage: image)
            viewView.addSubview(viewTest)
            
//            viewView.backgroundColor = UIColor(patternImage: image)
//            let viewTest = UIView(frame: viewView.bounds)
//            viewView.addSubview(viewTest)
            
            let blurEffect = UIBlurEffect(style: .Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = viewTest.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            viewTest.addSubview(blurEffectView)
        }
    }

}
