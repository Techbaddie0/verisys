;; Decentralized KYC Platform Smart Contract
;; Version 2.1 - Enhanced Security

;; Constants
(define-constant contract-owner tx-sender)
(define-constant STATUS-NONE "none")
(define-constant STATUS-PENDING "pending")
(define-constant STATUS-APPROVED "approved")
(define-constant STATUS-REJECTED "rejected")
(define-constant STATUS-EXPIRED "expired")
(define-constant empty-string "")

;; Additional error codes for data validation
(define-constant err-unauthorized (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-expired (err u104))
(define-constant err-invalid-data (err u105))
(define-constant err-blacklisted (err u106))
(define-constant err-invalid-fee (err u107))
(define-constant err-invalid-trust-score (err u108))
(define-constant err-invalid-level (err u109))
(define-constant err-empty-name (err u110))
(define-constant err-empty-requirements (err u111))
(define-constant err-invalid-threshold (err u112))
(define-constant err-zero-address (err u113))
(define-constant err-self-verification (err u114))

;; Validation constants
(define-constant MAX-TRUST-SCORE u100)
(define-constant MIN-TRUST-SCORE u0)
(define-constant MAX-VERIFICATION-THRESHOLD u100)
(define-constant MAX-PLATFORM-FEE u1000000000) ;; 1000 STX
(define-constant MIN-PLATFORM-FEE u100000)     ;; 0.1 STX
(define-constant MAX-KYC-LEVEL u5)             ;; Maximum KYC level allowed

;; Data Maps
(define-map users principal 
  { 
    kyc-status: (string-utf8 20),
    data-hash: (buff 32),
    timestamp: uint,
    expiry: uint,
    verifier: (optional principal),
    level: uint,
    metadata: (optional (string-utf8 256))
  }
)

(define-map approved-verifiers principal 
  {
    active: bool,
    verification-count: uint,
    trust-score: uint,
    added-at: uint
  }
)

(define-map blacklisted-users principal bool)

(define-map kyc-levels uint 
  {
    name: (string-utf8 50),
    requirements: (string-utf8 256),
    verification-threshold: uint
  }
)

;; Data Variables
(define-data-var total-users uint u0)
(define-data-var total-verifiers uint u0)
(define-data-var platform-fee uint u1000000)

;; Validation helper functions
(define-private (is-valid-status (status (string-ascii 20)))
    (or 
        (is-eq status STATUS-NONE)
        (is-eq status STATUS-PENDING)
        (is-eq status STATUS-APPROVED)
        (is-eq status STATUS-REJECTED)
        (is-eq status STATUS-EXPIRED)))

(define-private (is-valid-trust-score (score uint))
    (and 
        (>= score MIN-TRUST-SCORE)
        (<= score MAX-TRUST-SCORE)))

(define-private (is-valid-fee (fee uint))
    (and 
        (>= fee MIN-PLATFORM-FEE)
        (<= fee MAX-PLATFORM-FEE)))

(define-private (is-valid-kyc-level (level uint))
    (<= level MAX-KYC-LEVEL))

(define-private (is-valid-threshold (threshold uint))
    (<= threshold MAX-VERIFICATION-THRESHOLD))

(define-private (is-valid-principal (address principal))
    (and
(not (is-eq address contract-owner))
        (not (is-eq address tx-sender))))

;; Enhanced private functions
(define-private (is-approved-verifier (verifier principal))
    (match (map-get? approved-verifiers verifier)
        verified (and 
                    (get active verified)
                    (not (is-eq verifier tx-sender)))  ;; Prevent self-verification
        false))

(define-private (is-expired (user principal))
    (match (map-get? users user)
        user-data (> block-height (get expiry user-data))
        false))

(define-private (increment-verifier-count (verifier principal))
    (match (map-get? approved-verifiers verifier)
        verifier-data 
            (map-set approved-verifiers 
                verifier
                (merge verifier-data { verification-count: (+ (get verification-count verifier-data) u1) }))
        false))

;; Enhanced admin functions
(define-public (set-platform-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
        (asserts! (is-valid-fee new-fee) err-invalid-fee)
        (ok (var-set platform-fee new-fee))))

(define-public (add-approved-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
        (asserts! (is-valid-principal verifier) err-zero-address)
        (asserts! (not (is-approved-verifier verifier)) err-already-registered)
        (var-set total-verifiers (+ (var-get total-verifiers) u1))
        (ok
            (map-set approved-verifiers verifier
{
                    active: true,
                    verification-count: u0,
                    trust-score: u100,
                    added-at: block-height
                }))))

(define-public (update-verifier-trust-score (verifier principal) (new-score uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
        (asserts! (is-valid-trust-score new-score) err-invalid-trust-score)
        (asserts! (is-approved-verifier verifier) err-not-registered)
        (match (map-get? approved-verifiers verifier)
            verifier-data
                (ok
                    (map-set approved-verifiers verifier
                        (merge verifier-data { trust-score: new-score })))
            err-not-registered)))


;; Add these constants at the top of your contract

(define-private (is-empty-string (str (string-utf8 256)))
    (is-eq (len str) u0))

;; Fixed add-kyc-level function with proper string validation
(define-public (add-kyc-level (level uint) (name (string-utf8 50)) (requirements (string-utf8 256)) (verification-threshold uint))
    (begin
        ;; Validate authorization
        (asserts! (is-eq tx-sender contract-owner) err-unauthorized)

        ;; Validate level
        (asserts! (is-valid-kyc-level level) err-invalid-level)

        ;; Validate strings using length check instead of direct comparison
        (asserts! (not (is-empty-string name)) err-empty-name)
        (asserts! (not (is-empty-string requirements)) err-empty-requirements)

        ;; Validate threshold
 (asserts! (is-valid-threshold verification-threshold) err-invalid-threshold)

        ;; If all validations pass, set the KYC level
        (ok
            (map-set kyc-levels level
                {
                    name: name,
                    requirements: requirements,
                    verification-threshold: verification-threshold
                }))))

;; Optional: Add a read-only function to check if a level already exists
(define-read-only (kyc-level-exists (level uint))
    (is-some (map-get? kyc-levels level)))

