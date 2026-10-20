; Form 8889 (2025), Health Savings Accounts, for the person it's included
; in: `you/f8889` and, on a joint return, `spouse/f8889`. IRC §223.

; ---- Part I: HSA contributions and deduction ----

(def married (or joint (= filing-status 'married-separate)))
; Either spouse's family coverage makes it family coverage for both.
(def family :cite "IRC §223(b)(5)"
  (or (= hdhp 'family) (= you/hdhp 'family) (and joint (= spouse/hdhp 'family))))
(def eligible (and (!= hdhp 'no-hdhp) (> hsa-months 0)))
; Spouses with family coverage share its limit, and the $1,000 from age 55
; goes on line 7 instead of line 3.
(def shared (and married family))
(def catch-up :cite "IRC §223(b)(3)"
  (and eligible (>= (age-on birth-date law/year-end) 55)))

(def line1 :label "Coverage" (if family 'family hdhp))
(def line2 :label "Your HSA contributions" hsa-contributions)
; The year's limit for the coverage, for each month eligible: all 12 under
; the last-month rule.
(def line3 :label "Contribution limit" :cite "IRC §223(b)(2), (b)(8)"
  (if eligible
      (* (/ hsa-months 12)
         (+ (if family law/hsa-family-limit law/hsa-self-only-limit)
            (if (and catch-up (not shared)) law/hsa-catch-up $0)))
      $0))
(def line5 line3)                                                ; − 4
(def line7 :label "Additional contribution amount" :cite "IRC §223(b)(3)"
  (if (and shared catch-up) (* (/ hsa-months 12) law/hsa-catch-up) $0))
; What this HSA's contributions need of a shared limit, past line 7.
(def need (excess (+ line2 line9) line7))
; A shared family limit is divided as the spouses agree. On a joint return,
; each gets what their HSA needs, or a proportional part when together they
; need more; on a separate return, half, as the form does by default.
(def line6 :label "Your share of the limit"
  (cond ((not shared) line5)
        ((not joint) (/ line5 2))
        ((<= (+ you/f8889/need spouse/f8889/need) line5) need)
        (else (* line5 (/ need (+ you/f8889/need spouse/f8889/need))))))
(def line8 (+ line6 line7))
(def line9 :label "Employer contributions" hsa-employer)
(def line12 (excess line8 line9))                                ; − 10
(def line13 :label "HSA deduction" :cite "IRC §223(a)" (min line2 line12))

; ---- Part II: HSA distributions ----

(def line14a :label "Distributions" hsa-distributions)
(def line14b :label "Rolled over, or excess contributions withdrawn" hsa-rolled-over)
(def line14c (excess line14a line14b))
(def line15 :label "Spent on qualified medical expenses" hsa-medical)
(def line16 :label "Taxable HSA distributions" :cite "IRC §223(f)(2)"
  (excess line14c line15))
(def line17b :label "Additional 20% tax" :cite "IRC §223(f)(4)"
  (if (or (= line16 $0) hsa-exception) $0 (* law/hsa-distribution-rate line16)))
