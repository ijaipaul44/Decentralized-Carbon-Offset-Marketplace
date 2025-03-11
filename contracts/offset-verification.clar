;; Offset Verification Contract
;; Validates the effectiveness of carbon reduction projects

(define-map verifications
{ verification-id: uint }
{
  project-id: uint,
  verifier: principal,
  verified-reduction: uint,
  verification-date: uint,
  status: (string-ascii 20),
  report-url: (string-ascii 256)
}
)

(define-data-var verification-nonce uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-verification (verification-id uint))
(map-get? verifications { verification-id: verification-id })
)

(define-public (submit-verification
  (project-id uint)
  (verified-reduction uint)
  (report-url (string-ascii 256))
)
(let
  (
    (new-verification-id (+ (var-get verification-nonce) u1))
  )
  (var-set verification-nonce new-verification-id)
  (ok (map-set verifications
    { verification-id: new-verification-id }
    {
      project-id: project-id,
      verifier: tx-sender,
      verified-reduction: verified-reduction,
      verification-date: block-height,
      status: "pending",
      report-url: report-url
    }
  ))
)
)

(define-public (approve-verification (verification-id uint))
(let
  (
    (verification (unwrap! (get-verification verification-id) (err u404)))
  )
  (asserts! (is-eq tx-sender contract-owner) (err u403))
  (ok (map-set verifications
    { verification-id: verification-id }
    (merge verification { status: "approved" })
  ))
)
)

(define-public (reject-verification (verification-id uint))
(let
  (
    (verification (unwrap! (get-verification verification-id) (err u404)))
  )
  (asserts! (is-eq tx-sender contract-owner) (err u403))
  (ok (map-set verifications
    { verification-id: verification-id }
    (merge verification { status: "rejected" })
  ))
)
)

;; Instead of trying to filter and return all verifications, we'll provide a function
;; to check if a specific verification belongs to a project
(define-read-only (is-project-verification (verification-id uint) (project-id uint))
(match (get-verification verification-id)
  verification (is-eq (get project-id verification) project-id)
  false
)
)

