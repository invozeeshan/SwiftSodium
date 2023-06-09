//
//  ViewController.swift
//  LibSodiumPractice
//
//  Created by Zeeshan Ahmed on 23/05/2023.
//

import UIKit
import Sodium

class ViewController: UIViewController {

    let sodium = Sodium()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        publickeyCryptography(message: "My Test Message")
        anonymousEncryption()
        imageEncryption()
        fileEncryption()
    }
    
    func publickeyCryptography(message: String) {
        
        let senderKeyPair = sodium.box.keyPair()!
        let receiverKeyPair = sodium.box.keyPair()!
        
        let message = message.bytes
        print("Original Message:\(message.utf8String!)")

        let encryptedMessageFromAliceToBob: Bytes =
            sodium.box.seal(
                message: message,
                recipientPublicKey: receiverKeyPair.publicKey,
                senderSecretKey: senderKeyPair.secretKey)!

        print("Encrypted Message:\(encryptedMessageFromAliceToBob)")

        let messageVerifiedAndDecryptedByBob =
            sodium.box.open(
                nonceAndAuthenticatedCipherText: encryptedMessageFromAliceToBob,
                senderPublicKey: senderKeyPair.publicKey,
                recipientSecretKey: receiverKeyPair.secretKey)

        print("Decrypted Message:\(messageVerifiedAndDecryptedByBob!.utf8String!)")
    }

    func anonymousEncryption() {
        let bobKeyPair = sodium.box.keyPair()!
        let message = "My Test Message".bytes

        let encryptedMessageToBob =
            sodium.box.seal(message: message, recipientPublicKey: bobKeyPair.publicKey)!

        let messageDecryptedByBob =
            sodium.box.open(anonymousCipherText: encryptedMessageToBob,
                            recipientPublicKey: bobKeyPair.publicKey,
                            recipientSecretKey: bobKeyPair.secretKey)
        print("Decrypted Message:\(messageDecryptedByBob!.utf8String!)")
    }
    
    func keyExchange() {
        let senderKeyPair = sodium.keyExchange.keyPair()!
        let receiverKeyPair = sodium.keyExchange.keyPair()!

        let sessionKeyPairForAlice = sodium.keyExchange.sessionKeyPair(publicKey: senderKeyPair.publicKey,
            secretKey: senderKeyPair.secretKey, otherPublicKey: receiverKeyPair.publicKey, side: .CLIENT)!
        
        let sessionKeyPairForBob = sodium.keyExchange.sessionKeyPair(publicKey: receiverKeyPair.publicKey,
            secretKey: receiverKeyPair.secretKey, otherPublicKey: senderKeyPair.publicKey, side: .SERVER)!

        let aliceToBobKeyEquality = sodium.utils.equals(sessionKeyPairForAlice.tx, sessionKeyPairForBob.rx) // true
        let bobToAliceKeyEquality = sodium.utils.equals(sessionKeyPairForAlice.rx, sessionKeyPairForBob.tx)
    }
    
    func imageEncryption() {
        guard let filePath = Bundle.main.path(forResource: "response", ofType: "png"),
              let image = UIImage(contentsOfFile: filePath),
              let data = image.pngData() else {
            fatalError("Image not available")
        }
        
        let senderKeyPair = sodium.box.keyPair()!
        let receiverKeyPair = sodium.box.keyPair()!
        
        let bytesImage = getArrayOfBytesFromImage(imageData: data as NSData)
        
        let encryptedMessageFromAliceToBob: Bytes =
            sodium.box.seal(
                message: bytesImage,
                recipientPublicKey: receiverKeyPair.publicKey,
                senderSecretKey: senderKeyPair.secretKey)!

        let messageVerifiedAndDecryptedByBob =
            sodium.box.open(
                nonceAndAuthenticatedCipherText: encryptedMessageFromAliceToBob,
                senderPublicKey: senderKeyPair.publicKey,
                recipientSecretKey: receiverKeyPair.secretKey)
        
        let bytesData = Data(messageVerifiedAndDecryptedByBob!)
        let responseImage = UIImage(data: bytesData)

        print("Decrypted Message:\(String(describing: responseImage))")
    }
    
    func fileEncryption() {

        guard let filePath = Bundle.main.url(forResource: "base64-testing", withExtension: "txt"),
                let data = try? Data(contentsOf: filePath) else {
            fatalError("file not available")
        }
        
        let senderKeyPair = sodium.box.keyPair()!
        let receiverKeyPair = sodium.box.keyPair()!
        
        let bytesImage = getArrayOfBytesFromImage(imageData: data as NSData)
        
        let encryptedMessageFromAliceToBob: Bytes =
            sodium.box.seal(
                message: bytesImage,
                recipientPublicKey: receiverKeyPair.publicKey,
                senderSecretKey: senderKeyPair.secretKey)!

        let messageVerifiedAndDecryptedByBob =
            sodium.box.open(
                nonceAndAuthenticatedCipherText: encryptedMessageFromAliceToBob,
                senderPublicKey: senderKeyPair.publicKey,
                recipientSecretKey: receiverKeyPair.secretKey)
        
        let bytesData = Data(messageVerifiedAndDecryptedByBob!)

        print("Decrypted Message:\(String(describing: bytesData))")
    }
}

func getArrayOfBytesFromImage(imageData: NSData) -> Array<UInt8> {

  // the number of elements:
  let count = imageData.length / MemoryLayout<Int8>.size

  // create array of appropriate length:
  var bytes = [UInt8](repeating: 0, count: count)

  // copy bytes into array
  imageData.getBytes(&bytes, length:count * MemoryLayout<Int8>.size)

  var byteArray:Array = Array<UInt8>()

  for i in 0 ..< count {
    byteArray.append(bytes[i])
  }

  return byteArray
}
