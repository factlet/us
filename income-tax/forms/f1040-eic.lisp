; Earned Income Credit Worksheet A (Form 1040 instructions, line 27a), and
; the steps before it that decide who can take the credit. IRC §32.

(def children :label "Qualifying children with a valid SSN" (count people eic-child))
(def column (min children 3))                 ; the table's last is three or more

; The EIC Table figures the credit at the middle of each $50 row, to the
; dollar. The last row stops where the credit runs out, so its middle moves
; in: at least $50,400 but less than $50,434, with one child, is $3.
(defn credit-on [income : usd]
  (let [end (nth law/eic-phaseout-end column)
        low (floor $50 income)
        middle (/ (+ low (min (+ low $50) end)) 2)]
    (if (or (< income $1) (>= income end))
        $0
        (round $1 (excess (min (* (nth law/eic-rate column) middle) (nth law/eic-max column))
                          (* (nth law/eic-phaseout-rate column)
                             (excess middle (nth law/eic-phaseout-start column))))))))

; ---- Steps 1–4: who can take it ----

(def filers-have-ssns :label "A valid SSN for each filer" :cite "IRC §32(c)(1)(E), (m)"
  (and you/valid-ssn (or (not joint) spouse/valid-ssn)))
(def investment-income :label "Investment income" :cite "IRC §32(i)(2)"
  (+ f1040/line2a f1040/line2b f1040/line3b (max $0 f1040/line7a)))  ; + Schedule E, 8814, passive
; Having one skips the rules for filers without, even if the child doesn't
; count for want of an SSN.
(def has-qualifying-child :cite "IRC §32(c)(1)(A)(i)"
  (any people eic-qualifying-child))

; 25 to 64 at the end of the year. Turning 25 counts a day early, as
; turning 65 does for the standard deduction, but turning 65 here doesn't:
; the instructions take anyone born after 1960-12-31 and before 2001-01-02.
(defn working-age [birth : date]
  (and (>= (age-on birth law/day-after-year-end) 25)
       (< (age-on birth law/year-end) 65)))
(def without-child :label "Can take the EIC without a qualifying child"
  :cite "IRC §32(c)(1)(A)(ii)"
  (and (or (working-age you/birth-date) (and joint (working-age spouse/birth-date)))
       (not home-abroad)
       (or joint (not claimed-as-dependent))))

; A married couple files jointly, unless they've separated and the one
; filing has a qualifying child. A nonresident alien for any part of the
; year can only file jointly, as a resident by choice.
(def eligible :label "Can take the EIC" :cite "IRC §32(c)(1), (d), (i), (k)(1)"
  (and filers-have-ssns
       (or joint (not you/nonresident-alien))
       (not files-f2555)
       (not eic-barred)
       (<= investment-income law/eic-investment-limit)
       (or joint (not qualifying-child-of-another))
       (or (!= filing-status 'married-separate) (and has-qualifying-child separated-spouse))
       (or has-qualifying-child without-child)))

; ---- Worksheet A ----

(def line1 :label "Earned income" f1040-eic-b/line4b)
(def line2 (credit-on line1))
(def line3 :label "Adjusted gross income" f1040/line11a)
; Line 4 only spares looking up line 5 when it would repeat line 2.
(def line5 (credit-on line3))
(def line6 :label "Earned income credit"
  (if (< line3 (nth law/eic-phaseout-start column)) line2 (min line2 line5)))
