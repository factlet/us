; Form 2441 (2025), Child and Dependent Care Expenses. IRC §§21, 129.

; Married filing separately takes the credit only when considered
; unmarried for it (line A).
(def eligible (or (!= filing-status 'married-separate) considered-unmarried))
(def persons :label "Qualifying persons" (count dependents care-person))
(def two-or-more (>= persons 2))
(def deemed-income (nth law/care-deemed-income (if two-or-more 1 0)))
(def expense-limit (nth law/care-expense-limit (if two-or-more 1 0)))
(def expenses :label "Qualified expenses" (sum dependents (if care-person care-expenses $0)))

; ---- Part II: Credit for child and dependent care expenses ----

(def line3 :label "Expenses that count" (if (> line12 $0) line31 (min expenses expense-limit)))
(def line4 :label "Your earned income" you/earned-income)
(def line5 :label "Your spouse's earned income" (if joint spouse/earned-income line4))
(def line6 (if (= line3 $0) $0 (max $0 (min line3 line4 line5))))
(def line7 :label "Adjusted gross income" f1040/line11a)
; 35%, less 1% for each $2,000 or part of it over $15,000, down to 20%.
(def line8 :label "Decimal amount" :cite "IRC §21(a)(2)"
  (max law/care-rate-min
       (- law/care-rate-max
          (* 1% (/ (ceil law/care-phaseout-step (excess line7 law/care-phaseout-start))
                   law/care-phaseout-step)))))
(def line9a (* line6 line8))
(def line9c line9a)                                              ; + 9b
; Credit Limit Worksheet: the tax, less the foreign tax credit.
(def line10 :label "Tax liability limit" f1040/line18)           ; − Schedule 3 lines 1 6l
(def line11 :label "Credit for child and dependent care expenses"
  (if eligible (min line9c line10) $0))

; ---- Part III: Dependent care benefits ----

(def line12 :label "Dependent care benefits" (sum w2s dependent-care))
(def line15 line12)                                              ; + 13 − 14
(def line16 :label "Qualified expenses" expenses)
(def line17 (min line15 line16))
(def line18 :label "Your earned income" you/earned-income)
; Married filing separately and not considered unmarried, it's the
; spouse's, which takes the spouse's own return.
(def line19 :label "Your spouse's earned income" (if joint spouse/earned-income line18))
(def line20 (max $0 (min line17 line18 line19)))
(def line21 :label "Exclusion limit" :cite "IRC §129(a)(2)"
  (if (and (= filing-status 'married-separate) (not considered-unmarried))
      law/care-benefits-limit-separate
      law/care-benefits-limit))
(def line23 line15)                                              ; − 22
(def line25 :label "Excluded benefits" (min line20 line21))      ; − 24
(def line26 :label "Taxable benefits"
  (if (= line12 $0) $0 (excess line23 line25)))                  ; none to figure without benefits
(def line27 expense-limit)
(def line28 line25)                                              ; + 24
(def line29 (excess line27 line28))
; Expenses not already paid for with excluded benefits.
(def line30 (excess expenses line28))
(def line31 (min line29 line30))
