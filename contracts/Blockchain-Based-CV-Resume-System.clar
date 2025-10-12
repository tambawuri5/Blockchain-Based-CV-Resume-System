(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

(define-map user-profiles principal {
  name: (string-ascii 50),
  title: (string-ascii 100),
  email: (string-ascii 50),
  phone: (string-ascii 20),
  location: (string-ascii 50),
  summary: (string-ascii 500),
  created-at: uint,
  verified: bool
})

(define-map work-experiences principal {
  company: (string-ascii 100),
  position: (string-ascii 100),
  start-date: uint,
  end-date: (optional uint),
  description: (string-ascii 1000),
  verified-by: (optional principal),
  created-at: uint
})

(define-map education-records principal {
  institution: (string-ascii 100),
  degree: (string-ascii 100),
  field: (string-ascii 100),
  start-date: uint,
  end-date: uint,
  gpa: (optional (string-ascii 10)),
  verified-by: (optional principal),
  created-at: uint
})

(define-map skills principal {
  skill-name: (string-ascii 50),
  proficiency: uint,
  endorsed-count: uint,
  verified-by: (list 10 principal),
  created-at: uint
})

(define-map certifications principal {
  cert-name: (string-ascii 100),
  issuer: (string-ascii 100),
  issue-date: uint,
  expiry-date: (optional uint),
  credential-id: (string-ascii 100),
  verified: bool,
  created-at: uint
})

(define-map endorsements {endorser: principal, endorsed: principal, skill: (string-ascii 50)} {
  timestamp: uint,
  active: bool
})

(define-map verifiers principal bool)

(define-data-var total-users uint u0)
(define-data-var total-verifications uint u0)

(define-public (create-profile (name (string-ascii 50)) (title (string-ascii 100)) (email (string-ascii 50)) (phone (string-ascii 20)) (location (string-ascii 50)) (summary (string-ascii 500)))
  (let ((user tx-sender))
    (asserts! (is-none (map-get? user-profiles user)) err-already-exists)
    (map-set user-profiles user {
      name: name,
      title: title,
      email: email,
      phone: phone,
      location: location,
      summary: summary,
      created-at: stacks-block-height,
      verified: false
    })
    (var-set total-users (+ (var-get total-users) u1))
    (ok true)))

(define-public (update-profile (name (string-ascii 50)) (title (string-ascii 100)) (email (string-ascii 50)) (phone (string-ascii 20)) (location (string-ascii 50)) (summary (string-ascii 500)))
  (let ((user tx-sender)
        (existing-profile (unwrap! (map-get? user-profiles user) err-not-found)))
    (map-set user-profiles user (merge existing-profile {
      name: name,
      title: title,
      email: email,
      phone: phone,
      location: location,
      summary: summary
    }))
    (ok true)))

(define-public (add-work-experience (company (string-ascii 100)) (position (string-ascii 100)) (start-date uint) (end-date (optional uint)) (description (string-ascii 1000)))
  (let ((user tx-sender)
        (experience-id stacks-block-height))
    (asserts! (is-some (map-get? user-profiles user)) err-not-found)
    (map-set work-experiences user {
      company: company,
      position: position,
      start-date: start-date,
      end-date: end-date,
      description: description,
      verified-by: none,
      created-at: stacks-block-height
    })
    (ok experience-id)))

(define-public (add-education (institution (string-ascii 100)) (degree (string-ascii 100)) (field (string-ascii 100)) (start-date uint) (end-date uint) (gpa (optional (string-ascii 10))))
  (let ((user tx-sender)
        (education-id stacks-block-height))
    (asserts! (is-some (map-get? user-profiles user)) err-not-found)
    (map-set education-records user {
      institution: institution,
      degree: degree,
      field: field,
      start-date: start-date,
      end-date: end-date,
      gpa: gpa,
      verified-by: none,
      created-at: stacks-block-height
    })
    (ok education-id)))

(define-public (add-skill (skill-name (string-ascii 50)) (proficiency uint))
  (let ((user tx-sender))
    (asserts! (is-some (map-get? user-profiles user)) err-not-found)
    (asserts! (and (>= proficiency u1) (<= proficiency u10)) err-invalid-input)
    (map-set skills user {
      skill-name: skill-name,
      proficiency: proficiency,
      endorsed-count: u0,
      verified-by: (list),
      created-at: stacks-block-height
    })
    (ok true)))

(define-public (add-certification (cert-name (string-ascii 100)) (issuer (string-ascii 100)) (issue-date uint) (expiry-date (optional uint)) (credential-id (string-ascii 100)))
  (let ((user tx-sender)
        (cert-id stacks-block-height))
    (asserts! (is-some (map-get? user-profiles user)) err-not-found)
    (map-set certifications user {
      cert-name: cert-name,
      issuer: issuer,
      issue-date: issue-date,
      expiry-date: expiry-date,
      credential-id: credential-id,
      verified: false,
      created-at: stacks-block-height
    })
    (ok cert-id)))

(define-public (endorse-skill (endorsed principal) (skill (string-ascii 50)))
  (let ((endorser tx-sender)
        (endorsement-key {endorser: endorser, endorsed: endorsed, skill: skill}))
    (asserts! (not (is-eq endorser endorsed)) err-invalid-input)
    (asserts! (is-some (map-get? user-profiles endorsed)) err-not-found)
    (asserts! (is-none (map-get? endorsements endorsement-key)) err-already-exists)
    (map-set endorsements endorsement-key {
      timestamp: stacks-block-height,
      active: true
    })
    (match (map-get? skills endorsed)
      skill-data (map-set skills endorsed (merge skill-data {
        endorsed-count: (+ (get endorsed-count skill-data) u1)
      }))
      false)
    (ok true)))

(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set verifiers verifier true)
    (ok true)))

(define-public (verify-profile (user principal))
  (let ((verifier tx-sender))
    (asserts! (default-to false (map-get? verifiers verifier)) err-unauthorized)
    (match (map-get? user-profiles user)
      profile-data (begin
        (map-set user-profiles user (merge profile-data {verified: true}))
        (var-set total-verifications (+ (var-get total-verifications) u1))
        (ok true))
      err-not-found)))

(define-read-only (get-profile (user principal))
  (map-get? user-profiles user))

(define-read-only (get-work-experience (user principal))
  (map-get? work-experiences user))

(define-read-only (get-education (user principal))
  (map-get? education-records user))

(define-read-only (get-skill (user principal))
  (map-get? skills user))

(define-read-only (get-certification (user principal))
  (map-get? certifications user))

(define-read-only (get-endorsement (endorser principal) (endorsed principal) (skill (string-ascii 50)))
  (map-get? endorsements {endorser: endorser, endorsed: endorsed, skill: skill}))

(define-read-only (is-verifier (user principal))
  (default-to false (map-get? verifiers user)))

(define-read-only (get-total-users)
  (var-get total-users))

(define-read-only (get-total-verifications)
  (var-get total-verifications))


(define-map reference-requests {requester: principal, referee: principal} {
  requested-at: uint,
  message: (string-ascii 200),
  status: (string-ascii 10)
})

(define-map professional-references {user: principal, referee: principal} {
  relationship: (string-ascii 50),
  testimonial: (string-ascii 800),
  rating: uint,
  approved-at: uint,
  active: bool
})

(define-data-var total-references uint u0)

(define-public (request-reference (referee principal) (message (string-ascii 200)))
  (let ((requester tx-sender)
        (request-key {requester: requester, referee: referee}))
    (asserts! (not (is-eq requester referee)) err-invalid-input)
    (asserts! (is-some (map-get? user-profiles requester)) err-not-found)
    (asserts! (is-some (map-get? user-profiles referee)) err-not-found)
    (asserts! (is-none (map-get? reference-requests request-key)) err-already-exists)
    (map-set reference-requests request-key {
      requested-at: stacks-block-height,
      message: message,
      status: "pending"
    })
    (ok true)))

(define-public (approve-reference (requester principal) (relationship (string-ascii 50)) (testimonial (string-ascii 800)) (rating uint))
  (let ((referee tx-sender)
        (request-key {requester: requester, referee: referee})
        (reference-key {user: requester, referee: referee}))
    (asserts! (is-some (map-get? reference-requests request-key)) err-not-found)
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-input)
    (map-set reference-requests request-key (merge 
      (unwrap! (map-get? reference-requests request-key) err-not-found)
      {status: "approved"}))
    (map-set professional-references reference-key {
      relationship: relationship,
      testimonial: testimonial,
      rating: rating,
      approved-at: stacks-block-height,
      active: true
    })
    (var-set total-references (+ (var-get total-references) u1))
    (ok true)))

(define-public (decline-reference (requester principal))
  (let ((referee tx-sender)
        (request-key {requester: requester, referee: referee}))
    (asserts! (is-some (map-get? reference-requests request-key)) err-not-found)
    (map-set reference-requests request-key (merge 
      (unwrap! (map-get? reference-requests request-key) err-not-found)
      {status: "declined"}))
    (ok true)))

(define-read-only (get-reference-request (requester principal) (referee principal))
  (map-get? reference-requests {requester: requester, referee: referee}))

(define-read-only (get-reference (user principal) (referee principal))
  (map-get? professional-references {user: user, referee: referee}))

(define-read-only (get-total-references)
  (var-get total-references))


(define-map achievements {user: principal, achievement-id: uint} {
  title: (string-ascii 100),
  category: (string-ascii 30),
  description: (string-ascii 500),
  metric-value: uint,
  metric-unit: (string-ascii 20),
  date-achieved: uint,
  proof-url: (optional (string-ascii 200)),
  verified-by: (optional principal),
  verification-date: (optional uint),
  created-at: uint,
  visibility: bool
})

(define-map user-achievement-counters principal uint)

(define-data-var total-achievements uint u0)

(define-constant err-achievement-not-found (err u105))
(define-constant err-invalid-metric (err u106))

(define-public (create-achievement (title (string-ascii 100)) (category (string-ascii 30)) (description (string-ascii 500)) (metric-value uint) (metric-unit (string-ascii 20)) (date-achieved uint) (proof-url (optional (string-ascii 200))))
  (let ((user tx-sender)
        (counter (default-to u0 (map-get? user-achievement-counters user)))
        (achievement-id (+ counter u1))
        (achievement-key {user: user, achievement-id: achievement-id}))
    (asserts! (is-some (map-get? user-profiles user)) err-not-found)
    (asserts! (> metric-value u0) err-invalid-metric)
    (map-set achievements achievement-key {
      title: title,
      category: category,
      description: description,
      metric-value: metric-value,
      metric-unit: metric-unit,
      date-achieved: date-achieved,
      proof-url: proof-url,
      verified-by: none,
      verification-date: none,
      created-at: stacks-block-height,
      visibility: true
    })
    (map-set user-achievement-counters user achievement-id)
    (var-set total-achievements (+ (var-get total-achievements) u1))
    (ok achievement-id)))

(define-public (verify-achievement (user principal) (achievement-id uint))
  (let ((verifier tx-sender)
        (achievement-key {user: user, achievement-id: achievement-id})
        (existing-achievement (unwrap! (map-get? achievements achievement-key) err-achievement-not-found)))
    (asserts! (not (is-eq verifier user)) err-invalid-input)
    (asserts! (is-some (map-get? user-profiles verifier)) err-not-found)
    (map-set achievements achievement-key (merge existing-achievement {
      verified-by: (some verifier),
      verification-date: (some stacks-block-height)
    }))
    (ok true)))

(define-public (toggle-achievement-visibility (achievement-id uint))
  (let ((user tx-sender)
        (achievement-key {user: user, achievement-id: achievement-id})
        (existing-achievement (unwrap! (map-get? achievements achievement-key) err-achievement-not-found)))
    (map-set achievements achievement-key (merge existing-achievement {
      visibility: (not (get visibility existing-achievement))
    }))
    (ok true)))

(define-read-only (get-achievement (user principal) (achievement-id uint))
  (map-get? achievements {user: user, achievement-id: achievement-id}))

(define-read-only (get-user-achievement-count (user principal))
  (default-to u0 (map-get? user-achievement-counters user)))

(define-read-only (get-total-achievements)
  (var-get total-achievements))