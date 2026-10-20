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
  ; A child turns 17 on their 17th birthday (Rev. Rul. 2003-72), so one
  ; born after 2008-12-31 is under 17 at the end of 2025.
  (def ctc-child :label "Qualifies for the child tax credit" :cite "IRC §24(c), (e), (h)(7)"
    (and qualifying-child (not nonresident-alien) (< (age-on birth-date law/year-end) 17)
         (= tin 'ssn) filer-has-ssn filers-have-tins))
  ; Everyone else with a number, including a child under 17 who misses the
  ; credit only for want of an SSN.
  (def odc-dependent :label "Qualifies for the credit for other dependents"
    :cite "IRC §24(h)(4)"
    (and (not ctc-child) (not nonresident-alien) (!= tin 'no-tin) filers-have-tins)))

(collection w2s :label "Forms W-2"
  (input wages : usd :label "Wages, tips, other compensation" :line 1)
  (input withheld : usd :label "Federal income tax withheld" :line 2))

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

(module law (include "law/2025.lisp"))

(module f1040 (include "forms/f1040.lisp"))
(module f1040-qdcg (include "forms/f1040-qdcg.lisp"))
(module f1040s1a (include "forms/f1040s1a.lisp"))
(module f1040s8 (include "forms/f1040s8.lisp"))
