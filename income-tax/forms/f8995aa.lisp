; Schedule A (Form 8995-A) (2025), Specified Service Trades or Businesses:
; the applicable percentage, 100% at the threshold down to none at the end
; of the phase-in range. Each business's share is on its Schedule C
; (`f8995aa-line11`). IRC §199A(d)(3).

(def line5 :label "Taxable income before qualified business income deduction" f8995/line11)
(def line6 law/qbi-threshold)
(def line7 (- line5 line6))
(def line8 law/qbi-phase-in-range)
(def line9 (/ line7 line8))
(def line10 :label "Applicable percentage" (min 1 (max 0 (- 1 line9))))
