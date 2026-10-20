; US federal individual income tax, tax year 2025.
;
; A form's lines are named after the line they fill: `f1040/line11a` is
; Form 1040, line 11a. A form is named by its IRS identifier (`f1040`,
; `f1040sd`), and a worksheet by its form's plus a short name for it
; (`f1040-qdcg`: the Form 1040 instructions' Qualified Dividends and
; Capital Gain Tax Worksheet).

(unit usd :prefix "$" :places 2)

(enum filing-status
  single married-joint married-separate head-of-household
  qualifying-surviving-spouse)

; The identification number someone had by the return's due date:
;   ssn          a social security number valid for employment
;   nonwork-ssn  one whose card says "not valid for employment"
;   itin         an individual taxpayer identification number
;   atin         an adoption taxpayer identification number (dependents)
;   no-tin       none, or one issued after the due date
(enum tin ssn nonwork-ssn itin atin no-tin)

; The form's "subtract b from a; if zero or less, enter -0-".
(defn excess [a : usd b : usd] (max $0 (- a b)))

(input filing-status : filing-status :label "Filing status")
(def joint (= filing-status 'married-joint))

(module you (include "person.lisp"))
(module spouse (include "person.lisp"))   ; read only on a joint return

(input claimed-as-dependent : bool :default false
  :label "Someone can claim you as a dependent" :line 12a)
; Read only on a separate return, for social security benefits.
(input lived-apart-all-year : bool :default false
  :label "You lived apart from your spouse for all of the year" :line 6d
  :cite "IRC §86(c)(1)(C)")

; Questions for the earned income credit. The form's own box asks whether
; your main home was in the United States (the 50 states and DC; military
; stationed abroad count as at home), so asked this way round the usual
; answer is the default.
(input home-abroad : bool :default false
  :label "Your main home was outside the United States for more than half the year"
  :cite "IRC §32(c)(1)(A)(ii)(I), (c)(4)")
(input qualifying-child-of-another : bool :default false
  :label "You could be someone else's qualifying child" :cite "IRC §32(c)(1)(B)")
(input separated-spouse : bool :default false
  :label "You lived apart from your spouse for the last 6 months of the year, or were legally separated and apart at its end"
  :cite "IRC §32(d)(2)")
(input files-f2555 : bool :default false
  :label "You or your spouse are filing Form 2555, Foreign Earned Income" :cite "IRC §32(c)(1)(C)")
; Counted from the year of the final determination; any other disallowance
; only means attaching Form 8862 to claim it again.
(input eic-barred : bool :default false
  :label "A past EIC claim was found fraudulent within 10 years, or in reckless or intentional disregard of the rules within 2"
  :cite "IRC §32(k)(1)")

; No credit for dependents unless every filer has a number by the due date,
; and none for a child unless a filer has a valid SSN.
(def filers-have-tins :cite "IRC §24(e)(2)"
  (and (!= you/tin 'no-tin) (or (not joint) (!= spouse/tin 'no-tin))))
(def filer-has-ssn :cite "IRC §24(h)(7)(A)(i)"
  (or you/valid-ssn (and joint spouse/valid-ssn)))

(collection dependents :label "Dependents"
  (input birth-date : date :label "Date of birth")
  (input qualifying-child : bool :label "Your qualifying child" :cite "IRC §152(c)")
  (input tin : tin :label "Identification number issued by the return's due date")
  ; Someone who isn't can still be a dependent while living in Canada or
  ; Mexico (IRC §152(b)(3)), but gets neither credit.
  (input nonresident-alien : bool :default false
    :label "Not a U.S. citizen, national or resident alien" :cite "IRC §24(c)(2), (h)(4)(B)")
  (input lived-abroad : bool :default false
    :label "Lived with you outside the United States for more than half the year"
    :cite "IRC §32(c)(3)(C)")
  ; A child turns 17 on their 17th birthday (Rev. Rul. 2003-72), so one
  ; born after 2008-12-31 is under 17 at the end of 2025.
  (def ctc-child :label "Qualifies for the child tax credit" :cite "IRC §24(c), (e), (h)(7)"
    (and qualifying-child (not nonresident-alien) (< (age-on birth-date law/year-end) 17)
         (= tin 'ssn) filer-has-ssn filers-have-tins))
  ; Everyone else with a number, including a child under 17 who misses the
  ; credit only for want of an SSN.
  (def odc-dependent :label "Qualifies for the credit for other dependents"
    :cite "IRC §24(h)(4)"
    (and (not ctc-child) (not nonresident-alien) (!= tin 'no-tin) filers-have-tins))
  ; The EIC also wants the home you shared in the United States. A child
  ; without a valid SSN is still your qualifying child, but isn't counted
  ; toward the credit.
  (def eic-qualifying-child :label "Your qualifying child for the EIC" :cite "IRC §32(c)(3)"
    (and qualifying-child (not lived-abroad)))
  (def eic-child :label "Counts toward the EIC" :cite "IRC §32(c)(3)(D), (m)"
    (and eic-qualifying-child (= tin 'ssn))))

(collection w2s :label "Forms W-2"
  (input wages : usd :label "Wages, tips, other compensation" :line 1)
  (input withheld : usd :label "Federal income tax withheld" :line 2)
  (input ss-withheld : usd :label "Social security tax withheld" :line 4)
  (input medicare-withheld : usd :label "Medicare tax withheld" :line 6))

(collection f1099-ints :label "Forms 1099-INT"
  (input interest : usd :label "Interest income" :line 1)
  (input treasury-interest : usd :default $0
    :label "Interest on U.S. Savings Bonds and Treasury obligations" :line 3)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4)
  (input tax-exempt-interest : usd :default $0 :label "Tax-exempt interest" :line 8))

(collection f1099-divs :label "Forms 1099-DIV"
  (input ordinary : usd :label "Total ordinary dividends" :line 1a)
  (input qualified : usd :default $0 :label "Qualified dividends" :line 1b)
  (input cap-gain : usd :default $0 :label "Total capital gain distributions" :line 2a)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4)
  (input exempt-interest : usd :default $0 :label "Exempt-interest dividends" :line 12))

(collection f1099-gs :label "Forms 1099-G"
  (input unemployment : usd :label "Unemployment compensation" :line 1)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4))

; Railroad retirement benefits treated as social security (Form RRB-1099,
; boxes 5 and 10) go here too.
(collection ssa1099s :label "Forms SSA-1099"
  (input net-benefits : usd :label "Net benefits for the year" :line 5)
  (input withheld : usd :default $0 :label "Voluntary federal income tax withheld" :line 6))

; What the lender received is what you paid, as long as it was on a
; qualified student loan you were legally obligated to pay.
(collection f1098-es :label "Forms 1098-E"
  (input interest : usd :label "Student loan interest received by lender" :line 1))

(module law (include "law/2025.lisp"))

(module f1040 (include "forms/f1040.lisp"))
(module f1040-qdcg (include "forms/f1040-qdcg.lisp"))
(module f1040-ssb (include "forms/f1040-ssb.lisp"))
(module f1040-eic (include "forms/f1040-eic.lisp"))
(module f1040s1 (include "forms/f1040s1.lisp"))
(module f1040s1-sli (include "forms/f1040s1-sli.lisp"))
(module f1040s1a (include "forms/f1040s1a.lisp"))
(module f1040s8 (include "forms/f1040s8.lisp"))
