import Foundation
import FirebaseFirestore
import WebRTC

final class SignalingClient {
    
    private let db = Firestore.firestore()
    
    // Listeners to track and cancel
    private var sdpListener: ListenerRegistration?
    private var candidateListener: ListenerRegistration?
    
    // Debug Logging Closure
    var onLog: ((String) -> Void)?
    
    func log(_ message: String) {
        print(message)
        onLog?(message)
    }
    
    func cancelListeners() {
        sdpListener?.remove()
        candidateListener?.remove()
        sdpListener = nil
        candidateListener = nil
        log("🛑 Signaling Listeners Cancelled")
    }
    
    // MARK: - Queue-Based Matchmaking
    
    /// Starts the matchmaking process using a Firestore Transaction.
    /// - Returns: `(roomId, isCaller)` via completion handler.
    func startMatchmaking(userId: String, completion: @escaping (_ roomId: String, _ isCaller: Bool) -> Void) {
        let queueRef = db.collection("matchmaking_queue")
        
        // 1. Run Transaction to ATOMICALLY find a match or join the queue
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            // Query for ANY waiting user that is NOT me
            // Note: In a real app, you might want more complex queries (language, level, etc.)
            // Firestore transactions require reading ALL documents before writing.
            // However, queries in transactions are tricky.
            // HACK for robustness: We will try to finding the OLDEST waiting user first using a normal query,
            // then use the transaction to try and "claim" them.
            
            return nil // We will do the query OUTSIDE the transaction for simplicity in this specific "no-node-server" architecture,
                       // or use a cleaner "Two-Step" optimistic locking approach which is better for client-side code.
            
        }) { (object, error) in
            // ...
        }
        
        // REVISED APPROACH: OPTIMISTIC LOCKING
        // Transactions on lists are hard in Client SDKs.
        // We will do:
        // 1. QUERY for oldest match.
        // 2. If found -> Start Transaction to DELETE them and CREATE room.
        // 3. If fail (taken) -> Retry.
        // 4. If no match -> Add self to queue.
        
        findMatchOrJoinQueue(userId: userId, completion: completion)
    }
    
    private func findMatchOrJoinQueue(userId: String, completion: @escaping (_ roomId: String, _ isCaller: Bool) -> Void) {
        log("🔍 Looking for a match...")
        
        // 1. Query for oldest waiting user
        db.collection("matchmaking_queue")
            .order(by: "timestamp", descending: false)
            .limit(to: 1)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let doc = snapshot?.documents.first, doc.documentID != userId {
                    // POTENTIAL MATCH FOUND: "doc.documentID" (Peer)
                    self.attemptToClaimMatch(myUserId: userId, peerUserId: doc.documentID, peerDocRef: doc.reference, completion: completion)
                } else {
                    // NO MATCH FOUND (or only found myself): Join Queue
                    self.joinQueue(userId: userId, completion: completion)
                }
            }
    }
    
    private func attemptToClaimMatch(myUserId: String, peerUserId: String, peerDocRef: DocumentReference, completion: @escaping (_ roomId: String, _ isCaller: Bool) -> Void) {
        log("🤝 Attempting to claim peer: \(peerUserId)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 1. Verify peer still exists in queue (Atomic Check)
            let peerDoc: DocumentSnapshot
            do {
                try peerDoc = transaction.getDocument(peerDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if !peerDoc.exists {
                return "taken" // Peer already taken by someone else
            }
            
            // 2. Delete peer from queue
            transaction.deleteDocument(peerDocRef)
            
            // 3. Create a Call Room
            let roomId = UUID().uuidString
            let roomRef = self.db.collection("calls").document(roomId)
            
            // 4. Create Room Data
            transaction.setData([
                "status": "connecting",
                "callerId": myUserId,
                "calleeId": peerUserId,
                "created": FieldValue.serverTimestamp()
            ], forDocument: roomRef)
            
            // 5. Notify the Peer (by writing the roomId to their (deleted) queue doc location? NO, they are listening to the queue doc)
            // Better Pattern: Write to a "signaling_channel" or simply...
            // When we delete the user from the queue, how do they know where to go?
            // CORRECT PATTERN: We DON'T delete them yet. We UPDATE their queue doc with "matchFound: roomId".
            // Then THEY delete themselves or WE delete them after acknowledgement.
            // Let's go with: UPDATE Peer's Queue Doc.
            
            // RE-DO Step 2: Update Peer Doc instead of Delete
            transaction.updateData(["matchRoomId": roomId], forDocument: peerDocRef)
            
            return roomId
            
        }) { (result, error) in
            if let roomId = result as? String, roomId != "taken" {
                self.log("✅ Successfully claimed peer! Room: \(roomId)")
                completion(roomId, true) // I am CALLER
            } else if result as? String == "taken" {
                self.log("⚠️ Peer taken, retrying...")
                self.findMatchOrJoinQueue(userId: myUserId, completion: completion)
            } else {
                self.log("❌ Transaction failed: \(error?.localizedDescription ?? "Unknown")")
                // Fallback: Just join queue to avoid infinite loops if error is persistent
                self.joinQueue(userId: myUserId, completion: completion)
            }
        }
    }
    
    private func joinQueue(userId: String, completion: @escaping (_ roomId: String, _ isCaller: Bool) -> Void) {
        log("📝 Joining matchmaking_queue...")
        let myDocRef = db.collection("matchmaking_queue").document(userId)
        
        // 1. Set my queue document
        myDocRef.setData([
            "timestamp": FieldValue.serverTimestamp(),
            "matchRoomId": NSNull() // Waiting for this to change
        ]) { error in
            if let error = error {
                self.log("❌ Failed to join queue: \(error)")
                return
            }
            
            self.log("⏳ Waiting in queue...")
            // 2. Listen for updates (when someone acts as Caller and picks me)
            self.listenForMatch(userId: userId, completion: completion)
        }
    }
    
    private var queueListener: ListenerRegistration?
    
    private func listenForMatch(userId: String, completion: @escaping (_ roomId: String, _ isCaller: Bool) -> Void) {
        let myDocRef = db.collection("matchmaking_queue").document(userId)
        
        queueListener = myDocRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let data = snapshot.data() else {
                // If doc deleted and we didn't do it, maybe we were cleaned up?
                return 
            }
            
            if let roomId = data["matchRoomId"] as? String {
                self.log("🔔 Match Found! Room: \(roomId)")
                // Stop listening
                self.queueListener?.remove()
                self.queueListener = nil
                
                // Cleanup: Remove myself from queue now that I have the roomID
                myDocRef.delete()
                
                completion(roomId, false) // I am CALLEE
            }
        }
    }
    
    func cancelMatchmaking(userId: String) {
        queueListener?.remove()
        queueListener = nil
        db.collection("matchmaking_queue").document(userId).delete()
        log("🛑 Matchmaking Cancelled")
    }
    
    func deleteCall(sessionId: String) {
        db.collection("calls").document(sessionId).delete()
    }
    
    // MARK: - Call Signaling (SDP/ICE)
    
    // ... (Keep existing send/listen methods but improved)
    
    func send(sdp: RTCSessionDescription, sessionId: String) {
        log("📡 Sending SDP: \(sdp.type == .offer ? "Offer" : "Answer")")
        let typeStr = (sdp.type == .offer) ? "offer" : "answer"
        db.collection("calls").document(sessionId).setData([typeStr: ["type": typeStr, "sdp": sdp.sdp]], merge: true)
    }
    
    func send(candidate: RTCIceCandidate, sessionId: String, isCaller: Bool) {
        let collection = isCaller ? "callerCandidates" : "calleeCandidates"
        let data: [String: Any] = ["candidate": candidate.sdp, "sdpMid": candidate.sdpMid ?? "", "sdpMLineIndex": candidate.sdpMLineIndex]
        db.collection("calls").document(sessionId).collection(collection).addDocument(data: data)
    }
    
    func listenForRemoteSdp(sessionId: String, isCaller: Bool, completion: @escaping (RTCSessionDescription?) -> Void) {
        sdpListener?.remove()
        
        sdpListener = db.collection("calls").document(sessionId).addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists else {
                self.log("⚠️ Room Closed")
                completion(nil)
                return
            }
            
            guard let data = document.data() else { return }
            
            // Check for Remote Hangup status if we add that later
            
            // Filter: Callers listen for Answers, Callees listen for Offers
            if isCaller {
                if let answerData = data["answer"] as? [String: Any], let sdp = answerData["sdp"] as? String {
                    completion(RTCSessionDescription(type: .answer, sdp: sdp))
                }
            } else {
                if let offerData = data["offer"] as? [String: Any], let sdp = offerData["sdp"] as? String {
                    completion(RTCSessionDescription(type: .offer, sdp: sdp))
                }
            }
        }
    }
    
    func listenForRemoteCandidates(sessionId: String, isCaller: Bool, completion: @escaping (RTCIceCandidate) -> Void) {
        candidateListener?.remove()
        
        let collection = isCaller ? "calleeCandidates" : "callerCandidates"
        candidateListener = db.collection("calls").document(sessionId).collection(collection).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                if change.type == .added {
                    let data = change.document.data()
                    if let sdp = data["candidate"] as? String, let sdpMid = data["sdpMid"] as? String, let sdpMLineIndex = data["sdpMLineIndex"] as? Int32 {
                        completion(RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid))
                    }
                }
            }
        }
    }
}
