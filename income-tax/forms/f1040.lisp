; Form 1040 (2025), U.S. Individual Income Tax Return.
;
; Lines for income, deductions, credits and payments not yet modeled are
; left out of the totals below, which name them in a comment.

; ---- Income ----

(def line1a :label "Wages from Forms W-2" :line 1a (sum w2s wages))
(def line1e :label "Taxable dependent care benefits" :line 1e f2441/line26)
(def line1z :label "Total wages" :line 1z (+ line1a line1e))     ; + 1b–1d 1f–1h
(def line2a :label "Tax-exempt interest" :line 2a
  (+ (sum f1099-ints tax-exempt-interest) (sum f1099-divs exempt-interest)))
(def line2b :label "Taxable interest" :line 2b
  (sum f1099-ints (+ interest treasury-interest)))
(def line3a :label "Qualified dividends" :line 3a (sum f1099-divs qualified))
(def line3b :label "Ordinary dividends" :line 3b (sum f1099-divs ordinary))
; The form leaves 4a and 5a blank when all of a distribution is taxable.
(def line4a :label "IRA distributions" :line 4a (sum f1099-rs (if ira gross $0)))
(def line4b :label "Taxable IRA distributions" :line 4b (sum f1099-rs (if ira taxable-part $0)))
(def line5a :label "Pensions and annuities" :line 5a (sum f1099-rs (if ira $0 gross)))
(def line5b :label "Taxable pensions and annuities" :line 5b
  (sum f1099-rs (if ira $0 taxable-part)))
(def line6a :label "Social security benefits" :line 6a f1040-ssb/line1)
; With no benefits, or repayments over them, none are taxable.
(def line6b :label "Taxable social security benefits" :line 6b :cite "IRC §86"
  (if (> line6a $0) f1040-ssb/line18 $0))
; Schedule D's net gain, or its net loss up to the limit.
(def line7a :label "Capital gain or loss" :line 7a
  (if (>= f1040sd/line16 $0) f1040sd/line16 f1040sd/line21))
(def line8 :label "Additional income from Schedule 1" :line 8 f1040s1/line10)
(def line9 :label "Total income" :line 9
  (+ line1z line2b line3b line4b line5b line6b line7a line8))
(def line10 :label "Adjustments to income from Schedule 1" :line 10 f1040s1/line26)
(def line11a :label "Adjusted gross income" :line 11a :cite "IRC §62"
  (- line9 line10))
(def line11b :label "Adjusted gross income" :line 11b line11a)  ; carried to page 2

; ---- Deductions ----

(def line12d :label "Boxes checked for age 65 or blindness" :line 12d
  (+ you/boxes (if joint spouse/boxes 0)))
; Standard Deduction Worksheet for Dependents, when someone can claim you.
(def basic-std-deduction :cite "IRC §63(c)(2), (5)"
  (if claimed-as-dependent
      (min law/std-deduction
           (max law/dependent-std-minimum (+ line1z law/dependent-std-addition)))
      law/std-deduction))
; None at all when a spouse filing separately itemizes.
(def standard-deduction :label "Standard deduction" :cite "IRC §63(c)"
  (if (and (= filing-status 'married-separate) spouse-itemizes)
      $0
      (+ basic-std-deduction (* line12d law/aged-blind-addition))))
; The larger, unless you choose to itemize anyway (Schedule A line 18).
(def itemizes :label "Itemizes deductions" :cite "IRC §63(b), (e)"
  (or f1040sa/elect-itemize (> f1040sa/line17 standard-deduction)))
(def line12e :label "Standard deduction or itemized deductions" :line 12e
  (if itemizes f1040sa/line17 standard-deduction))
(def line13b :label "Additional deductions from Schedule 1-A" :line 13b f1040s1a/line38)
(def line14 :label "Total deductions" :line 14 (+ line12e line13b))  ; + 13a
(def line15 :label "Taxable income" :line 15 :cite "IRC §63"
  (excess line11a line14))

; ---- Tax and credits ----

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
  (if (= f1040-qdcg/line4 $0) (tax-on line15) f1040-qdcg/line25))  ; any qualified dividends or net capital gain
(def line17 :label "Amount from Schedule 2, Part I" :line 17 f1040s2/line3)
(def line18 :line 18 (+ line16 line17))
(def line19 :label "Child tax credit or credit for other dependents" :line 19
  f1040s8/line14)
(def line20 :label "Amount from Schedule 3" :line 20 f1040s3/line8)
(def line21 :line 21 (+ line19 line20))
(def line22 :line 22 (excess line18 line21))
(def line23 :label "Other taxes from Schedule 2" :line 23 f1040s2/line21)
(def line24 :label "Total tax" :line 24 (+ line22 line23))

; ---- Payments ----

(def line25a :label "Withholding from Forms W-2" :line 25a (sum w2s withheld))
(def line25b :label "Withholding from Forms 1099" :line 25b
  (+ (sum f1099-ints withheld) (sum f1099-divs withheld) (sum f1099-gs withheld)
     (sum f1099-bs withheld) (sum f1099-rs withheld) (sum ssa1099s withheld)))
(def line25c :label "Withholding from other forms" :line 25c f8959/line24)
(def line25d :label "Total withholding" :line 25d (+ line25a line25b line25c))
; A credit of zero settles it without asking who can take it, as Worksheet
; A stops when line 2 is zero.
(def line27a :label "Earned income credit" :line 27a :cite "IRC §32"
  (if (and (> f1040-eic/line6 $0) f1040-eic/eligible) f1040-eic/line6 $0))
(def line28 :label "Additional child tax credit" :line 28 f1040s8/line27)
(def line29 :label "American opportunity credit" :line 29 f8863/line8)
(def line31 :label "Amount from Schedule 3, Part II" :line 31 f1040s3/line15)
(def line32 :label "Other payments and refundable credits" :line 32
  (+ line27a line28 line29 line31))                               ; + 30
(def line33 :label "Total payments" :line 33 (+ line25d line32))  ; + 26
(def line34 :label "Overpaid" :line 34 (excess line33 line24))
(def line37 :label "Amount you owe" :line 37 (excess line24 line33))
