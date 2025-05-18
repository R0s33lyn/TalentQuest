;; TalentQuest Protocol
;; A decentralized skill development and professional certification system

;; Constants
(define-constant MAX_TALENT_POINTS u1000000)
(define-constant BASE_SKILL_REWARD u10)
(define-constant MASTERY_BONUS u2)
(define-constant MAX_MASTERY_TIER u7)
(define-constant ERR_INVALID_SKILL u1)
(define-constant ERR_NO_POINTS u2)
(define-constant ERR_RESERVE_EMPTY u3)
(define-constant BLOCKS_PER_DAY u144)
(define-constant DEDICATION_BONUS u2)
(define-constant MIN_DEDICATION_PERIOD u288)
(define-constant EARLY_ABANDONMENT_PENALTY u10)

;; Data Variables
(define-data-var total-points-issued uint u0)
(define-data-var total-skills-mastered uint u0)
(define-data-var platform-administrator principal tx-sender)
(define-data-var last-credential-id uint u0)

;; Data Maps
(define-map professional-skills principal uint)
(define-map talent-points principal uint)
(define-map skill-practice-block principal uint)
(define-map mastery-streak principal uint)
(define-map last-practice-block principal uint)
(define-map committed-points principal uint)
(define-map commitment-start-block principal uint)

;; NFT Data Maps
(define-map credential-ownership {id: uint} {owner: principal})
(define-map credential-metadata {id: uint} {skill-complexity: uint, completion-block: uint, mastery-level: uint})
(define-map user-credentials principal (list 100 uint))

;; Public Functions

(define-public (begin-skill-practice (complexity uint))
  (begin
    (asserts! (> complexity u0) (err ERR_INVALID_SKILL))
    (map-set skill-practice-block tx-sender burn-block-height)
    (ok true)
  )
)

(define-public (master-skill (complexity uint))
  (let ((practice-block (default-to u0 (map-get? skill-practice-block tx-sender))))
    (asserts! (> practice-block u0) (err ERR_INVALID_SKILL))
    (asserts! (>= (- burn-block-height practice-block) complexity) (err ERR_INVALID_SKILL))
    
    (let ((previous-practice-block (default-to u0 (map-get? last-practice-block tx-sender)))
          (streak (default-to u0 (map-get? mastery-streak tx-sender)))
          (new-streak (if (< (- burn-block-height previous-practice-block) BLOCKS_PER_DAY)
                        (+ streak u1)
                        u1))
          (capped-streak (if (<= streak MAX_MASTERY_TIER) streak MAX_MASTERY_TIER))
          (point-amount (+ BASE_SKILL_REWARD (* capped-streak MASTERY_BONUS)))
          (credential-id (+ (var-get last-credential-id) u1)))
      
      ;; Update professional records
      (map-set professional-skills tx-sender (+ (default-to u0 (map-get? professional-skills tx-sender)) u1))
      (map-set talent-points tx-sender (+ (default-to u0 (map-get? talent-points tx-sender)) point-amount))
      (map-set mastery-streak tx-sender new-streak)
      (map-set last-practice-block tx-sender burn-block-height)
      
      ;; Update platform stats
      (var-set total-skills-mastered (+ (var-get total-skills-mastered) u1))
      (var-set total-points-issued (+ (var-get total-points-issued) point-amount))
      (asserts! (<= (var-get total-points-issued) MAX_TALENT_POINTS) (err ERR_RESERVE_EMPTY))
      
      ;; Mint NFT professional credential
      (var-set last-credential-id credential-id)
      (map-set credential-ownership {id: credential-id} {owner: tx-sender})
      (map-set credential-metadata {id: credential-id} {skill-complexity: complexity, completion-block: burn-block-height, mastery-level: capped-streak})
      
      ;; Add credential to user's portfolio
      (let ((user-credential-list (default-to (list) (map-get? user-credentials tx-sender))))
        (map-set user-credentials tx-sender (unwrap-panic (as-max-len? (append user-credential-list credential-id) u100)))
        (ok point-amount)
      )
    )
  )
)

(define-public (claim-talent-points)
  (let ((point-balance (default-to u0 (map-get? talent-points tx-sender))))
    (asserts! (> point-balance u0) (err ERR_NO_POINTS))
    (map-set talent-points tx-sender u0)
    (ok point-balance)
  )
)

;; Commitment Features

(define-public (commit-to-skill (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_SKILL))
    (asserts! (>= (var-get total-points-issued) amount) (err ERR_RESERVE_EMPTY))
    (map-set committed-points tx-sender amount)
    (map-set commitment-start-block tx-sender burn-block-height)
    (var-set total-points-issued (- (var-get total-points-issued) amount))
    (ok amount)
  )
)

(define-public (end-commitment)
  (let ((committed-amount (default-to u0 (map-get? committed-points tx-sender)))
        (commitment-block (default-to u0 (map-get? commitment-start-block tx-sender))))
    
    (asserts! (> committed-amount u0) (err ERR_NO_POINTS))
    
    (let ((blocks-committed (- burn-block-height commitment-block))
          (penalty (if (< blocks-committed MIN_DEDICATION_PERIOD) 
                     (/ (* committed-amount EARLY_ABANDONMENT_PENALTY) u100) 
                     u0))
          (final-amount (- committed-amount penalty)))
      
      (map-set committed-points tx-sender u0)
      (map-set commitment-start-block tx-sender u0)
      (var-set total-points-issued (+ (var-get total-points-issued) final-amount))
      (ok final-amount)
    )
  )
)

;; Read-Only Functions

(define-read-only (get-mastered-skills (user principal))
  (default-to u0 (map-get? professional-skills user))
)

(define-read-only (get-point-balance (user principal))
  (default-to u0 (map-get? talent-points user))
)

(define-read-only (get-mastery-streak (user principal))
  (default-to u0 (map-get? mastery-streak user))
)

(define-read-only (get-platform-stats)
  {
    total-skills-mastered: (var-get total-skills-mastered),
    total-points-issued: (var-get total-points-issued),
    total-credentials-issued: (var-get last-credential-id)
  }
)

;; NFT Read-Only Functions

(define-read-only (get-credential-owner (credential-id uint))
  (let ((credential-data (map-get? credential-ownership {id: credential-id})))
    (if (is-some credential-data)
        (some (get owner (unwrap-panic credential-data)))
        none
    )
  )
)

(define-read-only (get-credential-metadata (credential-id uint))
  (map-get? credential-metadata {id: credential-id})
)

(define-read-only (get-user-credentials (user principal))
  (default-to (list) (map-get? user-credentials user))
)

(define-read-only (get-credential-count)
  (var-get last-credential-id)
)

;; Private Functions

(define-private (is-platform-administrator)
  (is-eq tx-sender (var-get platform-administrator))
)