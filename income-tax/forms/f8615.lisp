; Form 8615 (2025), Tax for Certain Children Who Have Unearned Income: the
; kiddie tax, for you as the child, taxing net unearned income at the
; parent's rate. IRC §1(g).

; Under 18 at the end of the year, or 18, or a full-time student under 24,
; with earned income no more than half their support; with a parent alive,
; and not filing jointly. A birthday counts a day early, so one born on
; 2008-01-01 is 18 at the end of 2025.
(def age (age-on you/birth-date law/day-after-year-end))
(def child :label "A child the kiddie tax applies to" :cite "IRC §1(g)(2)"
  (and (not joint) (not parents-deceased)
       (or (< age 18)
           (and supported (or (= age 18) (and you/full-time-student (< age 24)))))))

; ---- Part I: Child's net unearned income ----

; AGI without earned income; with it, total income less earned income,
; counting all of a business's profit as earned (Child's Unearned Income
; Worksheet, or the Alternate Worksheet for a business loss).
(def earned :label "Earned income" (+ f1040/line1z f1040s1/line3))
(def line1 :label "Child's unearned income" :cite "IRC §1(g)(4)(A)(i)"
  (if (= earned $0) f1040/line11b (- f1040/line9 earned)))
; Twice the dependent's minimum standard deduction, $2,700; more only for
; a child itemizing deductions directly connected with the income.
(def line2 :cite "IRC §1(g)(4)(A)(ii)" (* 2 law/dependent-std-minimum))
(def line3 (excess line1 line2))
(def line4 :label "Child's taxable income" f1040/line15)
(def line5 :label "Net unearned income" :cite "IRC §1(g)(4)" (min line3 line4))
(def applies :label "Taxed on Form 8615" :cite "IRC §1(g)(1)" (and (> line5 $0) child))
; The qualified dividends and net capital gain in it, by Line 5 Worksheet
; #1, or #3 when taxable income is the smaller.
(def line5-dividends (if (= line5 line3) f8615-ws1/line8 f8615-ws3/line18))
(def line5-gain (if (= line5 line3) f8615-ws1/line9 f8615-ws3/line19))

; ---- Part II: Tentative tax based on the tax rate of the parent ----

(def line6 :label "Parent's taxable income" (max $0 parent-taxable-income))
(def line7 :label "Other children's net unearned income" other-children-unearned)
(def line8 (+ line5 line6 line7))
(def line9 :label "Tax at the parent's rate" f8615-qdcg9/line25)
(def line10 :label "Parent's tax" parent-tax)
(def line11 :label "Tentative tax" (- line9 line10))
; Shared among the children by their net unearned income.
(def line12a (+ line5 line7))
(def line12b (/ line5 line12a))
(def line13 :label "Child's share of the tentative tax"
  (if (= line7 $0) line11 (* line11 line12b)))

; ---- Part III: Child's tax ----

(def line14 (- line4 line5))
(def line15 :label "Tax on the rest, at the child's rate" f8615-qdcg15/line25)
(def line16 (+ line13 line15))
(def line17 :label "Tax at the child's rate" f1040/tax)
(def line18 :label "Child's tax" (max line16 line17))
