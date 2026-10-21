; One filer, included as `you` and as `spouse`.

(input birth-date : date :label "Date of birth")
(input blind : bool :default false :label "Blind at the end of the year" :line 12d)
(input tin : tin :label "Identification number issued by the return's due date")
; Read only off a joint return: filing jointly with a nonresident alien
; takes choosing to be treated as residents for the whole year.
(input nonresident-alien : bool :default false
  :label "A nonresident alien for any part of the year" :cite "IRC §32(c)(1)(D); §6013(a)(1), (g), (h)")

; Issued to a citizen or someone authorized to work, which is what the child
; tax credit and the senior deduction both mean by an SSN.
(def valid-ssn :label "Has a valid SSN" :cite "IRC §24(h)(7)(B)" (= tin 'ssn))

; 65 by the end of the year. A person turns 65 the day before their 65th
; birthday, so for 2025 that's anyone born before 1961-01-02 (line 12d).
(def aged :label "65 or older" :cite "IRC §63(f)(1)"
  (>= (age-on birth-date law/day-after-year-end) 65))

(def boxes :label "Line 12d boxes checked" (+ (if aged 1 0) (if blind 1 0)))

; For the IRA deduction.
(input retirement-plan : bool :default false
  :label "Covered by a retirement plan at work or through self-employment (Form W-2, box 13)"
  :cite "IRC §219(g)(5)")
(input ira-contributions : usd :default $0
  :label "Traditional IRA contributions for the year, made by the return's due date"
  :cite "IRC §219(f)(3)")

; For an HSA, on this person's own Form 8889.
(input hdhp : hdhp :default 'no-hdhp
  :label "Coverage under a high-deductible health plan, while eligible for an HSA"
  :line 1 :cite "IRC §223(c)(1)")
(input hsa-months : number :default 12
  :label "Months eligible for an HSA on the first of the month: all 12 if eligible on December 1"
  :cite "IRC §223(b)(2), (b)(8)")
(input hsa-contributions : usd :default $0
  :label "Your contributions to your HSA for the year, not through an employer" :line 2)
(input hsa-employer : usd :default $0
  :label "Employer contributions to your HSA (Form W-2, box 12, code W)" :line 9)
(input hsa-distributions : usd :default $0
  :label "Distributions from your HSAs (Form 1099-SA, box 1)" :line 14a)
(input hsa-rolled-over : usd :default $0
  :label "Of those, rolled over to another HSA, or excess contributions withdrawn in time"
  :line 14b)
(input hsa-medical : usd :default $0
  :label "Of those, spent on qualified medical expenses" :line 15)
(input hsa-exception : bool :default false
  :label "Your taxable HSA distributions were all made after you turned 65 or became disabled"
  :line 17a :cite "IRC §223(f)(4)(B), (C)")
(module f8889 (include "forms/f8889.lisp"))

(module f1040sse (include "forms/f1040sse.lisp"))
; The deductible part of self-employment tax per dollar of profit, to share
; among this person's businesses by profit (Schedule 1-A line 5, Form 8995).
(def business-profit :label "Profit from businesses with self-employment income"
  (sum f1040scs (if (or statutory-employee (!= spouses is-spouse)) $0 (max $0 line31))))
(def se-deduction-rate
  (if (= business-profit $0) 0 (/ f1040sse/line13 business-profit)))

; As a student, for an education credit (Form 8863, Part III, lines 23
; through 31), as for a dependent.
(input education-expenses : usd :default $0
  :label "Adjusted qualified education expenses paid for you" :cite "IRC §25A(f)")
(input aotc-four-years : bool :default false
  :label "The American opportunity credit was claimed for you for 4 earlier years" :line 23)
(input less-than-half-time : bool :default false
  :label "Not enrolled at least half-time toward a degree or credential" :line 24)
(input four-years-done : bool :default false
  :label "Finished the first 4 years of postsecondary education before this year" :line 25)
(input drug-felony : bool :default false
  :label "Convicted of a felony for a controlled substance" :line 26)
(def aotc-student :label "Takes the American opportunity credit" :cite "IRC §25A(b)(2)"
  (and (> education-expenses $0) (!= tin 'no-tin) (not aotc-four-years)
       (not less-than-half-time) (not four-years-done) (not drug-felony)))

; A full-time student in some part of 5 months: for the refundable American
; opportunity credit and the saver's credit.
(input full-time-student : bool :default false
  :label "A full-time student for some part of 5 months of the year"
  :cite "IRC §§25A(i)(5)(B), 25B(c)(2)(B)")

; For the saver's credit (Form 8880), besides traditional IRA contributions.
(input roth-contributions : usd :default $0
  :label "Roth IRA and ABLE account contributions for the year" :line 1
  :cite "IRC §25B(d)(1)(A)")
(input retirement-distributions : usd :default $0
  :label "Distributions from IRAs and retirement plans since 2023, through the return's due date, not rolled over"
  :line 4 :cite "IRC §25B(d)(2)")
; Not someone under 18 at the end of the year, someone another taxpayer can
; claim, or a full-time student.
(def saver-eligible :label "Can take the saver's credit" :cite "IRC §25B(c)"
  (and (>= (age-on birth-date law/day-after-year-end) 18)
       (not (and (not is-spouse) claimed-as-dependent))
       (not full-time-student)))

; Earned income for the child and dependent care credit and benefits (Form
; 2441, lines 4, 5, 18 and 19): this person's own wages and statutory
; employee income, and self-employment less the half of its tax deducted.
; A month as a full-time student, or unable to care for oneself, counts as
; at least $250, or $500 with two or more qualifying persons (line B).
(input care-deemed-months : number :default 0
  :label "Months you were a full-time student or unable to care for yourself"
  :cite "IRC §21(d)(2)")
(def earned-income :label "Earned income" :cite "IRC §21(d)"
  (max (+ (sum w2s (if (= spouses is-spouse) wages $0))
          (sum f1040scs (if (and statutory-employee (= spouses is-spouse)) receipts $0))
          (- f1040sse/line3 f1040sse/line13))
       (* care-deemed-months f2441/deemed-income)))
