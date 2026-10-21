; Form 8962 (2025), Premium Tax Credit, for Marketplace coverage. IRC §36B.

; ---- Part I: Annual and monthly contribution amount ----

; You, your spouse on a joint return, and your dependents, but not someone
; another taxpayer can claim.
(def line1 :label "Tax family size"
  (+ (if claimed-as-dependent 0 1) (if joint 1 0) (count dependents true)))
; Worksheet 1-1: AGI, with tax-exempt interest and untaxed social security.
(def line2a :label "Modified AGI" :cite "IRC §36B(d)(2)(B)"
  (+ f1040/line11a f1040/line2a (excess f1040/line6a f1040/line6b)))  ; + Form 2555
(def line2b :label "Dependents' modified AGI" (sum dependents magi))
(def line3 :label "Household income" (max $0 (+ line2a line2b)))
(def line4 :label "Federal poverty line" :cite "IRC §36B(d)(3)"
  (+ law/poverty-line (* (- line1 1) law/poverty-line-per-person)))
; Worksheet 2: the percentage, dropping any decimals, or 401 past 400%.
(def line5 :label "Household income as a percentage of the federal poverty line"
  (if (> line3 (* 4 line4)) 401 (floor 1 (* 100 (/ line3 line4)))))
; Table 2: straight lines between the points, to four places.
(defn between [p : number i : number]
  (let [lo (nth law/ptc-percentages i)
        hi (nth law/ptc-percentages (+ i 1))
        from (nth law/ptc-figures i)
        to (nth law/ptc-figures (+ i 1))]
    (round 0.0001 (+ from (* (- to from) (/ (- p lo) (- hi lo)))))))
(def line7 :label "Applicable figure" :cite "IRC §36B(b)(3)(A)"
  (cond ((<= line5 (nth law/ptc-percentages 0)) (nth law/ptc-figures 0))
        ((<= line5 (nth law/ptc-percentages 1)) (between line5 0))
        ((<= line5 (nth law/ptc-percentages 2)) (between line5 1))
        ((<= line5 (nth law/ptc-percentages 3)) (between line5 2))
        ((< line5 (nth law/ptc-percentages 4)) (between line5 3))
        (else (nth law/ptc-figures 4))))
(def line8a :label "Annual contribution amount" (round $1 (* line3 line7)))
(def line8b :label "Monthly contribution amount" (round $1 (/ line8a 12)))

; ---- Part II: Premium tax credit and advance payments ----

; Not for someone another taxpayer can claim, nor separately without the
; exception; under 100% of the poverty line, only after advance payments.
(def applicable :label "An applicable taxpayer" :cite "IRC §36B(c)(1)"
  (and marketplace (not claimed-as-dependent)
       (or (!= filing-status 'married-separate) ptc-separate-exception)
       (or (>= line5 100) (> line25 $0))))
; Line 11 for a whole year; lines 12 through 23 for fewer months, with the
; same amounts in each month covered.
(def line11a :label "Enrollment premiums" (sum f1095-as premiums))
(def line11b :label "Applicable SLCSP premium" (sum f1095-as slcsp))
(def line11c :label "Contribution amount"
  (if (= marketplace-months 12) line8a (* marketplace-months line8b)))
(def line11d :label "Maximum premium assistance" (excess line11b line11c))
(def line11e :label "Premium tax credit allowed" (min line11a line11d))
(def line24 :label "Premium tax credit" (if applicable line11e $0))
(def line25 :label "Advance payment of premium tax credit"
  (if marketplace (sum f1095-as advance) $0))
(def line26 :label "Net premium tax credit" (excess line24 line25))

; ---- Part III: Repayment of excess advance payments ----

(def line27 :label "Excess advance payment" (excess line25 line24))
; Table 5, by household income, unless 400% of the poverty line or more.
(def line28 :label "Repayment limitation" :cite "IRC §36B(f)(2)(B)"
  (cond ((< line5 200) (nth law/aptc-repayment-limits 0))
        ((< line5 300) (nth law/aptc-repayment-limits 1))
        ((< line5 400) (nth law/aptc-repayment-limits 2))
        (else line27)))
(def line29 :label "Excess advance premium tax credit repayment"
  (if (= line27 $0) $0 (min line27 line28)))
