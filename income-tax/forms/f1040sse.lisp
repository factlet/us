; Schedule SE (2025), Self-Employment Tax, for the person it's included
; in: `you/f1040sse` and, on a joint return, `spouse/f1040sse`. IRC §1401.

; ---- Part I: Self-employment tax ----

; This person's own businesses, but not statutory employee income.
(def line2 :label "Net profit or loss from Schedule C"
  (sum f1040scs (if (or statutory-employee (!= spouses is-spouse)) $0 line31)))  ; + K-1s
(def line3 line2)                                                ; + 1a 1b
(def line4a :cite "IRC §1402(a)(12)"
  (if (> line3 $0) (* law/se-earnings-rate line3) line3))
(def line4c :label "Net earnings from self-employment" line4a)   ; + 4b
; Under $400, there's no self-employment tax, and no Schedule SE to file.
(def required :cite "IRC §6017" (>= line4c law/se-minimum))
(def line6 (if required line4c $0))                              ; + 5b
(def line7 :label "Social security wage base" law/ss-wage-base)
(def line8a :label "Social security wages and tips"
  (sum w2s (if (= spouses is-spouse) (+ ss-wages ss-tips) $0)))
(def line8d line8a)                                              ; + 8b 8c
(def line9 (excess line7 line8d))
(def line10 :cite "IRC §1401(a)" (* law/se-ss-rate (min line6 line9)))
(def line11 :cite "IRC §1401(b)" (* law/se-medicare-rate line6))
(def line12 :label "Self-employment tax" (if required (+ line10 line11) $0))
(def line13 :label "Deduction for one-half of self-employment tax" :cite "IRC §164(f)"
  (* 50% line12))
