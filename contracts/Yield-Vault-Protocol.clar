;; Yield Vault Protocol
;; A decentralized vault system for earning yield on STX deposits

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_VAULT_PAUSED (err u103))

(define-data-var vault-paused bool false)
(define-data-var total-deposits uint u0)
(define-data-var yield-rate uint u500) ;; 5% annual yield (500 basis points)

(define-map user-deposits principal uint)
(define-map user-last-claim principal uint)

(define-read-only (get-user-deposit (user principal))
  (default-to u0 (map-get? user-deposits user))
)

(define-read-only (get-total-deposits)
  (var-get total-deposits)
)

(define-read-only (get-yield-rate)
  (var-get yield-rate)
)

(define-read-only (calculate-yield (user principal))
  (let (
    (deposit (get-user-deposit user))
    (last-claim (default-to block-height (map-get? user-last-claim user)))
    (blocks-elapsed (- block-height last-claim))
  )
    (if (> deposit u0)
      (/ (* deposit yield-rate blocks-elapsed) u1000000)
      u0
    )
  )
)

(define-public (deposit (amount uint))
  (begin
    (asserts! (not (var-get vault-paused)) ERR_VAULT_PAUSED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (let (
      (current-deposit (get-user-deposit tx-sender))
      (new-deposit (+ current-deposit amount))
    )
      (map-set user-deposits tx-sender new-deposit)
      (map-set user-last-claim tx-sender block-height)
      (var-set total-deposits (+ (var-get total-deposits) amount))
      (ok new-deposit)
    )
  )
)

(define-public (withdraw (amount uint))
  (let (
    (user-deposit (get-user-deposit tx-sender))
  )
    (asserts! (>= user-deposit amount) ERR_INSUFFICIENT_BALANCE)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    
    (let (
      (new-deposit (- user-deposit amount))
    )
      (if (is-eq new-deposit u0)
        (map-delete user-deposits tx-sender)
        (map-set user-deposits tx-sender new-deposit)
      )
      (var-set total-deposits (- (var-get total-deposits) amount))
      (ok new-deposit)
    )
  )
)

(define-public (claim-yield)
  (let (
    (yield-amount (calculate-yield tx-sender))
  )
    (asserts! (> yield-amount u0) ERR_INVALID_AMOUNT)
    
    (try! (as-contract (stx-transfer? yield-amount tx-sender tx-sender)))
    (map-set user-last-claim tx-sender block-height)
    (ok yield-amount)
  )
)

(define-public (set-yield-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set yield-rate new-rate)
    (ok true)
  )
)

(define-public (toggle-vault)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set vault-paused (not (var-get vault-paused)))
    (ok (var-get vault-paused))
  )
)