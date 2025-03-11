;; Trading Contract
;; Facilitates buying and selling of carbon offset credits

(define-fungible-token carbon-credit)

(define-constant contract-owner tx-sender)

(define-map credit-balances
  { owner: principal }
  { balance: uint }
)

(define-map listings
{ listing-id: uint }
{
  seller: principal,
  project-id: uint,
  amount: uint,
  price-per-credit: uint,
  status: (string-ascii 20)
}
)

(define-data-var listing-nonce uint u0)

(define-read-only (get-listing (listing-id uint))
(map-get? listings { listing-id: listing-id })
)

(define-read-only (get-balance (account principal))
(default-to { balance: u0 } (map-get? credit-balances { owner: account }))
)

(define-public (create-listing (project-id uint) (amount uint) (price-per-credit uint))
(let
  (
    (new-listing-id (+ (var-get listing-nonce) u1))
    (seller-balance (get balance (get-balance tx-sender)))
  )
  (asserts! (>= seller-balance amount) (err u401))
  (var-set listing-nonce new-listing-id)
  (map-set credit-balances
    { owner: tx-sender }
    { balance: (- seller-balance amount) }
  )
  (ok (map-set listings
    { listing-id: new-listing-id }
    {
      seller: tx-sender,
      project-id: project-id,
      amount: amount,
      price-per-credit: price-per-credit,
      status: "active"
    }
  ))
)
)

(define-public (cancel-listing (listing-id uint))
(let
  (
    (listing (unwrap! (get-listing listing-id) (err u404)))
    (seller-balance (get balance (get-balance (get seller listing))))
  )
  (asserts! (is-eq tx-sender (get seller listing)) (err u403))
  (asserts! (is-eq (get status listing) "active") (err u400))
  (map-set credit-balances
    { owner: (get seller listing) }
    { balance: (+ seller-balance (get amount listing)) }
  )
  (ok (map-set listings
    { listing-id: listing-id }
    (merge listing { status: "cancelled" })
  ))
)
)

(define-public (buy-credits (listing-id uint) (amount uint))
(let
  (
    (listing (unwrap! (get-listing listing-id) (err u404)))
    (total-cost (* amount (get price-per-credit listing)))
    (buyer-balance (get balance (get-balance tx-sender)))
  )
  (asserts! (is-eq (get status listing) "active") (err u400))
  (asserts! (<= amount (get amount listing)) (err u401))
  (asserts! (>= (stx-get-balance tx-sender) total-cost) (err u402))
  (try! (stx-transfer? total-cost tx-sender (get seller listing)))
  (map-set credit-balances
    { owner: tx-sender }
    { balance: (+ buyer-balance amount) }
  )
  (if (< amount (get amount listing))
    (map-set listings
      { listing-id: listing-id }
      (merge listing { amount: (- (get amount listing) amount) })
    )
    (map-set listings
      { listing-id: listing-id }
      (merge listing { status: "completed", amount: u0 })
    )
  )
  (ok true)
)
)

;; Administrative function to mint initial credits (for demonstration purposes)
(define-public (mint-initial-credits (recipient principal) (amount uint))
(begin
  (asserts! (is-eq tx-sender contract-owner) (err u403))
  (ft-mint? carbon-credit amount recipient)
)
)

