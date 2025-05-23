;; Capital Allocation Contract
;; Manages asset distribution

;; Asset allocation map
(define-map allocations
  { user: principal, pool: principal }
  { amount: uint })

;; Total capital per user
(define-map user-capital principal uint)

;; Allocate capital to a pool
(define-public (allocate-capital
                (user principal)
                (pool principal)
                (amount uint))
  (begin
    (asserts! (or (is-eq tx-sender user) (is-eq tx-sender (var-get contract-owner))) (err u100))

    ;; Update user's total capital if needed
    (let ((current-capital (default-to u0 (map-get? user-capital user))))
      (map-set user-capital user (+ current-capital amount)))

    ;; Update allocation
    (let ((current-allocation (default-to { amount: u0 }
                               (map-get? allocations { user: user, pool: pool }))))
      (map-set allocations
               { user: user, pool: pool }
               { amount: (+ (get amount current-allocation) amount) }))

    (ok true)))

;; Get allocation for a user in a specific pool
(define-read-only (get-allocation (user principal) (pool principal))
  (default-to { amount: u0 } (map-get? allocations { user: user, pool: pool })))

;; Get total capital for a user
(define-read-only (get-user-capital (user principal))
  (default-to u0 (map-get? user-capital user)))

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Transfer ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u100))
    (var-set contract-owner new-owner)
    (ok true)))
