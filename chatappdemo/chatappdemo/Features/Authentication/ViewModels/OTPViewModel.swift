//
//  OTPViewModel.swift
//  chatappdemo
//
//  Created by Abhishek on 25/04/25.
//

import Foundation

final class OTPViewModel: BaseViewModel {
    @Published var otp: [String?] = Array(repeating: nil, count: 6)
    @Published var resendOtpCount: Int = 30
    
    private var timer: Timer?

    override init() {
        super.init()
        startCountdown()
    }
    
    func startCountdown() {
        resendOtpCount = 30
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.resendOtpCount > 0 {
                    self.resendOtpCount -= 1
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
    
    func resetCountdown() {
        startCountdown()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func validateForm() -> Bool {
        let otpCode = otp.map { String($0 ?? "") }.joined()
        if otpCode.isEmpty {
            showAlertFor(title: "Validation Error", message: "Enter OTP, which has been sent to you mobile number.")
            return false
        } else if otpCode.count != 6 {
            showAlertFor(title: "Validation Error", message: "Enter a valid OTP. OTP should be 6 digits long.")
            return false
        }
        return true
    }
}
