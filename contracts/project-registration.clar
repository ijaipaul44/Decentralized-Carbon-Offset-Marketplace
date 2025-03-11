;; Project Registration Contract
;; Records details of carbon reduction initiatives

(define-map projects
{ project-id: uint }
{
  owner: principal,
  name: (string-ascii 100),
  location: (string-ascii 100),
  project-type: (string-ascii 50),
  estimated-reduction: uint,
  start-date: uint,
  end-date: uint,
  status: (string-ascii 20)
}
)

(define-data-var project-nonce uint u0)

(define-constant contract-owner tx-sender)

(define-read-only (get-project (project-id uint))
(map-get? projects { project-id: project-id })
)

(define-public (register-project
  (name (string-ascii 100))
  (location (string-ascii 100))
  (project-type (string-ascii 50))
  (estimated-reduction uint)
  (start-date uint)
  (end-date uint)
)
(let
  (
    (new-project-id (+ (var-get project-nonce) u1))
  )
  (var-set project-nonce new-project-id)
  (ok (map-set projects
    { project-id: new-project-id }
    {
      owner: tx-sender,
      name: name,
      location: location,
      project-type: project-type,
      estimated-reduction: estimated-reduction,
      start-date: start-date,
      end-date: end-date,
      status: "pending"
    }
  ))
)
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
(let
  (
    (project (unwrap! (get-project project-id) (err u404)))
  )
  (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender (get owner project))) (err u403))
  (ok (map-set projects
    { project-id: project-id }
    (merge project { status: new-status })
  ))
)
)

(define-public (update-project-details
  (project-id uint)
  (name (string-ascii 100))
  (location (string-ascii 100))
  (project-type (string-ascii 50))
  (estimated-reduction uint)
  (start-date uint)
  (end-date uint)
)
(let
  (
    (project (unwrap! (get-project project-id) (err u404)))
  )
  (asserts! (is-eq tx-sender (get owner project)) (err u403))
  (ok (map-set projects
    { project-id: project-id }
    (merge project
      {
        name: name,
        location: location,
        project-type: project-type,
        estimated-reduction: estimated-reduction,
        start-date: start-date,
        end-date: end-date
      }
    )
  ))
)
)

