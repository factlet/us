; Form 1040 (2025), U.S. Individual Income Tax Return.

; ---- Income ----

(def line1a :label "Wages from Forms W-2" :line 1a (sum w2s wages))
(def line2a :label "Tax-exempt interest" :line 2a
  (+ (sum f1099-ints tax-exempt-interest) (sum f1099-divs exempt-interest)))
(def line2b :label "Taxable interest" :line 2b
  (sum f1099-ints (+ interest treasury-interest)))
(def line3a :label "Qualified dividends" :line 3a (sum f1099-divs qualified))
(def line3b :label "Ordinary dividends" :line 3b (sum f1099-divs ordinary))
; Capital gain distributions alone need no Schedule D.
(def line7a :label "Capital gain" :line 7a (sum f1099-divs cap-gain))
(def line9 :label "Total income" :line 9 (+ line1a line2b line3b line7a))
(def line11a :label "Adjusted gross income" :line 11a :cite "IRC §62" line9)

; ---- Deductions ----

(def line12e :label "Standard deduction" :line 12e :cite "IRC §63(c)" law/std-deduction)
(def line15 :label "Taxable income" :line 15 :cite "IRC §63" (excess line11a line12e))

; ---- Tax ----

; Under $100,000 the Tax Table, which taxes the middle of the income's row
; (rows are $25 wide below $3,000, then $50); from $100,000 the Tax
; Computation Worksheet, which is exact. Either way, to the dollar.
(defn tax-table-row-middle [income : usd]
  (cond ((< income $5) $2.50)
        ((< income $15) $10)
        ((< income $25) $20)
        ((< income $3,000) (+ (floor $25 income) $12.50))
        (else (+ (floor $50 income) $25))))
(defn tax-on [income : usd]
  (round $1 (brackets (if (< income $100,000) (tax-table-row-middle income) income)
                      law/brackets)))

(def line16 :label "Tax" :line 16 :cite "IRC §1"
  (if (and (= line3a $0) (= line7a $0)) (tax-on line15) f1040-qdcg/line25))

; ---- Payments ----

(def line25a :label "Withholding from Forms W-2" :line 25a (sum w2s withheld))
(def line25b :label "Withholding from Forms 1099" :line 25b
  (+ (sum f1099-ints withheld) (sum f1099-divs withheld)))
(def line25d :label "Total withholding" :line 25d (+ line25a line25b))
(def line34 :label "Overpaid" :line 34 (excess line25d line16))
(def line37 :label "Amount you owe" :line 37 (excess line16 line25d))
