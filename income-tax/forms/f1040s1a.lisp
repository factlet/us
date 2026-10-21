; Schedule 1-A (2025), Additional Deductions: for qualified tips, qualified
; overtime compensation, car loan interest and seniors, 2025 through 2028.

(def line3 :label "Modified adjusted gross income" f1040/line11b)  ; + 2e

; Tips and overtime count only for a filer with a valid SSN, and if married
; only on a joint return.
(def separate (= filing-status 'married-separate))

; ---- Part II: No tax on tips ----

; Each employer's, as the More Than One Employer Worksheet adds them (with
; no Form 4137, its column (b)).
(def line4c :label "Qualified tips received as an employee" :cite "IRC §224(a), (e)"
  (sum w2s (if (and (> qualified-tips $0) (if spouses spouse/valid-ssn you/valid-ssn))
               qualified-tips $0)))
; A business's only up to its net income: its profit less the deductions
; allocable to it, here its share of its owner's deductible self-employment
; tax.
(def line5 :label "Qualified tips received in a trade or business" :cite "IRC §224(c)"
  (sum f1040scs tips-counted))
(def line6 (+ line4c line5))
; The share of the tips counted that's deducted, after the limit and the
; phaseout: a business's deducted tips aren't qualified business income.
(def tips-deducted-rate :cite "IRC §199A(c)(4)(D)"
  (if (= line6 $0) 0 (/ line13 line6)))
(def line7 (min line6 law/tips-limit))
(def line8 line3)
(def line9 law/tips-phaseout-start)
(def line10 (- line8 line9))
(def line11 (if (<= line10 $0) 0 (floor 1 (/ line10 law/phaseout-step))))
(def line12 (* line11 law/tips-phaseout-reduction))
(def line13 :label "Qualified tips deduction" :cite "IRC §224(b), (f)"
  (if separate $0 (excess line7 line12)))

; ---- Part III: No tax on overtime ----

(def line14a :label "Qualified overtime compensation included in Forms W-2, box 1"
  :cite "IRC §225(a), (c)"
  (sum w2s (if (and (> qualified-overtime $0) (if spouses spouse/valid-ssn you/valid-ssn))
               qualified-overtime $0)))
(def line14c line14a)                                            ; + 14b
(def line15 (min line14c law/overtime-limit))
(def line16 line3)
(def line17 law/overtime-phaseout-start)
(def line18 (- line16 line17))
(def line19 (if (<= line18 $0) 0 (floor 1 (/ line18 law/phaseout-step))))
(def line20 (* line19 law/overtime-phaseout-reduction))
(def line21 :label "Qualified overtime compensation deduction" :cite "IRC §225(b)"
  (if separate $0 (excess line15 line20)))

; ---- Part IV: No tax on car loan interest ----

; Each loan's interest less what's deducted on Schedule C, E or F (column
; (iii)), on a separate return too.
(def line23 :label "Qualified passenger vehicle loan interest" :cite "IRC §163(h)(4)(B)"
  (if vehicle-loan (sum vehicle-loans (excess interest deducted)) $0))
(def line24 (min line23 law/car-loan-limit))
(def line25 line3)
(def line26 law/car-loan-phaseout-start)
(def line27 (- line25 line26))
(def line28 (if (<= line27 $0) 0 (ceil 1 (/ line27 law/phaseout-step))))
(def line29 (* line28 law/car-loan-phaseout-reduction))
(def line30 :label "Qualified passenger vehicle loan interest deduction"
  :cite "IRC §163(h)(4)(C)"
  (excess line24 line29))

; ---- Part V: Enhanced deduction for seniors ----

(def line32 law/senior-phaseout-start)
(def line33 (excess line3 line32))
(def line34 (* law/senior-phaseout-rate line33))
(def line35 (excess law/senior-deduction line34))
; Each filer 65 or older with a valid SSN; a married couple must file jointly.
(def line36a :label "Your senior deduction" :cite "IRC §151(d)(5)(C)(iv), (v)"
  (if (and you/aged you/valid-ssn (not separate)) line35 $0))
(def line36b :label "Your spouse's senior deduction" :cite "IRC §151(d)(5)(C)(iv)"
  (if (and joint spouse/aged spouse/valid-ssn) line35 $0))
(def line37 :label "Enhanced deduction for seniors" (+ line36a line36b))

; ---- Part VI: Total additional deductions ----

(def line38 :label "Total additional deductions" (+ line13 line21 line30 line37))
