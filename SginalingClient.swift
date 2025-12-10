import SwiftUI
import FirebaseFirestore
import WebRTC
import Combine

final class SignalingClient {
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Matchmaking Logic
    func findOrCreateSession(completion: @escaping (_ sessionId: String, _ isCaller: Bool) -> Void) {
        // 1. Look for a 'waiting' session to join
        db.collection("calls")
            .whereField("status", isEqualTo: "waiting")
            .limit(to: 1)
            .getDocuments { (snapshot, error) in
                
                if let document = snapshot?.documents.first {
                    // CASE A: Found a waiting user! JOIN them.
                    let sessionId = document.documentID
                    print("Found waiting room: \(sessionId)")
                    
                    // Update status to 'matched' so no one else joins
                    self.db.collection("calls").document(sessionId).updateData(["status": "matched"])
                    
                    completion(sessionId, false) // false = We are the Callee (Receiver)
                    
                } else {
                    // CASE B: No one waiting. CREATE a new room.
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("calls").addDocument(data: [
                        "status": "waiting",
                        "created": FieldValue.serverTimestamp()
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Created waiting room: \(ref!.documentID)")
                            completion(ref!.documentID, true) // true = We are the Caller
                        }
                    }
                }
            }
    }
    
    // MARK: - Signaling: Send SDP (Offer/Answer)
    func send(sdp: RTCSessionDescription, sessionId: String) {
        let typeStr = (sdp.type == .offer) ? "offer" : "answer"
        let sdpData: [String: Any] = [
            "type": typeStr,
            "sdp": sdp.sdp
        ]
        db.collection("calls").document(sessionId).setData([typeStr: sdpData], merge: true)
    }
    
    // MARK: - Signaling: Send ICE Candidate
    func send(candidate: RTCIceCandidate, sessionId: String, isCaller: Bool) {
        let collection = isCaller ? "callerCandidates" : "calleeCandidates"
        
        let candidateData: [String: Any] = [
            "candidate": candidate.sdp,
            "sdpMid": candidate.sdpMid ?? "",
            "sdpMLineIndex": candidate.sdpMLineIndex
        ]
        
        db.collection("calls").document(sessionId).collection(collection).addDocument(data: candidateData)
    }
    
    // MARK: - Listeners (Receiving Data)
    
    // 1. Listen for Remote SDP (Answer if we are Caller, Offer if we are Callee)
    func listenForRemoteSdp(sessionId: String, completion: @escaping (RTCSessionDescription) -> Void) {
        listener = db.collection("calls").document(sessionId)
            .addSnapshotListener { (documentSnapshot, error) in
                guard let document = documentSnapshot, document.exists,
                      let data = document.data() else { return }
                
                // Check if there is data for the OTHER person
                // (If we check for 'offer' but we created it, we ignore it)
                
                if let offerData = data["offer"] as? [String: Any],
                   let sdp = offerData["sdp"] as? String,
                   let typeStr = offerData["type"] as? String {
                    
                    // We only care if we haven't processed this yet
                    // In a real app, you'd check connection state to avoid resetting
                    let type: RTCSdpType = (typeStr == "offer") ? .offer : .answer
                    completion(RTCSessionDescription(type: type, sdp: sdp))
                }
                
                if let answerData = data["answer"] as? [String: Any],
                   let sdp = answerData["sdp"] as? String {
                    completion(RTCSessionDescription(type: .answer, sdp: sdp))
                }
            }
    }
    
    // 2. Listen for Remote ICE Candidates
    func listenForRemoteCandidates(sessionId: String, isCaller: Bool, completion: @escaping (RTCIceCandidate) -> Void) {
        let collection = isCaller ? "calleeCandidates" : "callerCandidates"
        
        db.collection("calls").document(sessionId).collection(collection)
            .addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else { return }
                
                snapshot.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        if let sdp = data["candidate"] as? String,
                           let sdpMid = data["sdpMid"] as? String,
                           let sdpMLineIndex = data["sdpMLineIndex"] as? Int32 {
                            
                            let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                            completion(candidate)
                        }
                    }
                }
            }
    }
}
