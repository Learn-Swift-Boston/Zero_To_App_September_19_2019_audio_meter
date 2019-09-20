//
//  ViewController.swift
//  ShhhutUp
//
//  Created by Zev Eisenberg on 9/19/19.
//  Copyright © 2019 Zev Eisenberg. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dBLabel: UILabel!

    private let session = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            do {
                try self.session.setCategory(.record, mode: .default)
                try self.session.setActive(true)
            }
            catch {
                print("error: \(error)")
            }

            let settings: [String: NSNumber] = [
                AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
            ]

            do {
                let audioFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("myFile")
                self.audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
                self.audioRecorder?.record()
                self.audioRecorder?.isMeteringEnabled = true
            }
            catch {
                print("Error creating audio recorder: \(error)")
            }

            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 4.0, repeats: true, block: { [weak self] (timer) in
                self?.audioRecorder?.updateMeters()
                if let power = self?.audioRecorder?.averagePower(forChannel: 0) {
                    let powerInt = Int(power)
                    self?.dBLabel.text = String(powerInt)

                    let color: UIColor
                    switch powerInt {
                    case ...(-20):
                        color = .green
                    case ...(-10):
                        color = .orange
                    default:
                        color = .red
                    }

                    self?.dBLabel.textColor = color
                }
            })

        }
    }

}
