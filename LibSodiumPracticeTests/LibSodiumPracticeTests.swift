//
//  LibSodiumPracticeTests.swift
//  LibSodiumPracticeTests
//
//  Created by Zeeshan Ahmed on 23/05/2023.
//

import XCTest
@testable import LibSodiumPractice
import Sodium

final class LibSodiumPracticeTests: XCTestCase {

    let sodium = Sodium()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testpublickeyCryptography() {
        
        let senderKeyPair = sodium.box.keyPair()!
        let receiverKeyPair = sodium.box.keyPair()!
        
        let message = "My Test Message".bytes
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
        XCTAssertNotNil(messageVerifiedAndDecryptedByBob)
        if let decryptedMessage = messageVerifiedAndDecryptedByBob {
            print(decryptedMessage.utf8String ?? "")
        }
    }
    
    func testImageWithPublickeyCryptography() {
        
        guard let filePath = Bundle(for: type(of: self)).path(forResource: "response", ofType: "png"),
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
        XCTAssertNotNil(responseImage)
        
        print("Decrypted Image:\(String(describing: responseImage))")

    }

}
