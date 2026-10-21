; Form 8863 (2025), Education Credits, for students who are you, your
; spouse on a joint return, or your dependents. IRC §25A.

; Not on a separate return, for someone another taxpayer can claim, or for
; a nonresident alien filing alone.
(def eligible
  (and (!= filing-status 'married-separate) (not claimed-as-dependent)
       (or joint (not you/nonresident-alien))))

; ---- Part III, a student at a time ----

; The American opportunity credit (lines 27 through 30): all of the first
; $2,000 of expenses and 25% of the next $2,000.
(defn american-opportunity [expenses : usd]
  (let [line27 (min expenses (+ law/aotc-first law/aotc-second))
        line28 (excess line27 law/aotc-first)]
    (if (= line28 $0) line27 (+ law/aotc-first (* law/aotc-second-rate line28)))))
; Lifetime learning credit expenses (line 31), for any student who can't
; take the American opportunity credit.
(defn lifetime-learning [expenses : usd aotc : bool] (if aotc $0 expenses))

; The phaseout's decimal (lines 2 through 6, and 13 through 17), rounded
; to three places.
(def phaseout-room (excess law/education-phaseout-end f1040/line11b))
(def phaseout-share
  (min 1 (round 0.001 (/ phaseout-room law/education-phaseout-range))))

; ---- Part I: Refundable American opportunity credit ----

(def line1 :label "American opportunity credit before the phaseout"
  (if eligible
      (+ (if you/aotc-student (american-opportunity you/education-expenses) $0)
         (if (and joint spouse/aotc-student)
             (american-opportunity spouse/education-expenses)
             $0)
         (sum people (if aotc-student (american-opportunity education-expenses) $0)))
      $0))
(def line4 phaseout-room)
(def line6 phaseout-share)
(def line7 (* line1 line6))
; None of it refundable for someone under 24 who's supported much like a
; dependent, with a parent alive, filing alone.
(def age (age-on you/birth-date law/year-end))
(def young-student :label "Under 24 and supported like a dependent" :cite "IRC §25A(i)(5)(B)"
  (and (not joint) (not parents-deceased) (< age 24)
       (or (< age 18) (and supported (or (= age 18) you/full-time-student)))))
(def line8 :label "Refundable American opportunity credit" :cite "IRC §25A(i)(5)"
  (if (or (= line7 $0) young-student) $0 (* law/aotc-refundable-rate line7)))

; ---- Part II: Nonrefundable education credits ----

(def line9 (- line7 line8))
(def line10 :label "Lifetime learning credit expenses"
  (if eligible
      (+ (lifetime-learning you/education-expenses you/aotc-student)
         (if joint (lifetime-learning spouse/education-expenses spouse/aotc-student) $0)
         (sum people (if (and (> education-expenses $0) dependent)
                         (lifetime-learning education-expenses aotc-student)
                         $0)))
      $0))
(def line11 (min line10 law/llc-expense-limit))
(def line12 (* law/llc-rate line11))
(def line17 phaseout-share)
(def line18 :label "Lifetime learning credit" (if (= line10 $0) $0 (* line12 line17)))
; Credit Limit Worksheet: the tax, less the foreign tax credit and the
; credit for child and dependent care.
(def line19 :label "Nonrefundable education credits"
  (let [credits (+ line18 line9)]
    (if (= credits $0) $0 (min credits (excess f1040/line18 f1040s3/line2)))))  ; − Schedule 3 lines 1 6d 6l
