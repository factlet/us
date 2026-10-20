; IRA Deduction Worksheet (Form 1040 instructions, Schedule 1, line 20):
; a column for your traditional IRA, and one for your spouse's on a joint
; return. IRC §219.

; Married filing separately, having lived together at any time in the
; year, you're covered by a plan if your spouse is.
(def together (and (= filing-status 'married-separate) (not lived-apart-all-year)))
(def line1a :label "You were covered by a retirement plan" :cite "IRC §219(g)(1), (4)"
  (or you/retirement-plan (and together spouse/retirement-plan)))
(def line1b :label "Your spouse was covered by a retirement plan"
  (and joint spouse/retirement-plan))
; With no one covered, there's no phaseout: lines 2 through 6 are skipped.
(def phased-out (or line1a line1b))

; $7,000, or $8,000 at 50 or older by the end of the year.
(defn limit [birth : date]
  (if (>= (age-on birth law/year-end) 50) (+ law/ira-limit law/ira-catch-up) law/ira-limit))

; On a joint return, the column of someone not covered phases out from
; higher, over less, than that of someone covered.
(defn phaseout-end [covered : bool]
  (cond (together law/ira-phaseout-end-together)
        (covered law/ira-phaseout-end)
        (else law/ira-phaseout-end-spouse-covered)))
(defn phaseout-range [covered : bool]
  (if covered law/ira-phaseout-range law/ira-phaseout-range-spouse-covered))

; Before the range below line 2, all of the limit; within it, the share
; left (line 7's 70%, 80%, 35% or 40%), rounded up to $10 and at least
; $200; from line 2 on, none.
(defn phased [limit : usd room : usd range : usd]
  (cond ((>= room range) limit)
        ((= room $0) $0)
        (else (max law/ira-min-deduction (ceil $10 (* room (/ limit range)))))))

; Line 9's total income, but with the social security benefits taxable
; before this deduction (Pub. 590-A, Appendix B, Worksheet 1).
(def line3 :label "Total income"
  (+ f1040/line1z f1040/line2b f1040/line3b f1040/line4b f1040/line5b
     (if (> f1040/line6a $0) p590a-ssb/line18 $0) f1040/line7a f1040/line8))
(def line5 :label "Modified adjusted gross income" line3)        ; − 4
(def line2a (phaseout-end line1a))
(def line2b (phaseout-end line1b))
(def line6a (excess line2a line5))
(def line6b (excess line2b line5))
(def line7a :label "Most you can deduct for your IRA"
  (if phased-out
      (phased (limit you/birth-date) line6a (phaseout-range line1a))
      (limit you/birth-date)))
(def line7b :label "Most you can deduct for your spouse's IRA"
  (if phased-out
      (phased (limit spouse/birth-date) line6b (phaseout-range line1b))
      (limit spouse/birth-date)))

(def line8 :label "Wages" f1040/line1z)                          ; + alimony, combat pay
(def line10 :label "Earned income" line8)                        ; + 9
(def line11a :label "Your traditional IRA contributions" you/ira-contributions)
(def line11b :label "Your spouse's traditional IRA contributions"
  (if joint spouse/ira-contributions $0))
; With no contribution, nothing more to ask. Together the two can't take
; more than the couple's earned income (IRC §219(c)), which the worksheet
; leaves to Pub. 590-A.
(def line12a :label "Your IRA deduction"
  (if (> line11a $0) (min line7a line10 line11a) $0))
(def line12b :label "Your spouse's IRA deduction"
  (if (> line11b $0) (min line7b (excess line10 line12a) line11b) $0))
