; Schedule 1-A (2025), Additional Deductions. So far only Part V, the
; enhanced deduction for seniors; tips, overtime and car loan interest
; (Parts II–IV) are to come.

(def line3 :label "Modified adjusted gross income" f1040/line11a)  ; + 2e

; ---- Part V: Enhanced deduction for seniors ----

(def line32 law/senior-phaseout-start)
(def line33 (excess line3 line32))
(def line34 (* law/senior-phaseout-rate line33))
(def line35 (excess law/senior-deduction line34))
; Each filer 65 or older with a valid SSN; a married couple must file jointly.
(def line36a :label "Your senior deduction" :cite "IRC §151(d)(5)(C)(iv), (v)"
  (if (and you/aged you/valid-ssn (!= filing-status 'married-separate)) line35 $0))
(def line36b :label "Your spouse's senior deduction" :cite "IRC §151(d)(5)(C)(iv)"
  (if (and joint spouse/aged spouse/valid-ssn) line35 $0))
(def line37 :label "Enhanced deduction for seniors" (+ line36a line36b))

(def line38 :label "Total additional deductions" line37)        ; + 13 21 30
