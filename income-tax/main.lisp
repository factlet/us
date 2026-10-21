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

; Coverage under a high-deductible health plan, for an HSA.
(enum hdhp no-hdhp self-only family)

; How someone you may claim is related to you:
;   child           son, daughter, stepchild, or adopted child
;   foster-child    a child placed with you by an agency or a court
;   sibling         brother or sister, half or step
;   descendant      a descendant of any of them, such as a grandchild, niece
;                   or nephew
;   parent          father or mother
;   other-relative  a grandparent or other ancestor, stepparent, aunt, uncle,
;                   or in-law
;   unrelated       anyone else
(enum relationship child foster-child sibling descendant parent other-relative unrelated)

; Where you lived, for the federal poverty line: Alaska's and Hawaii's are
; higher than the rest of the country's.
(enum residence states-dc alaska hawaii)

; The form's "subtract b from a; if zero or less, enter -0-".
(defn excess [a : usd b : usd] (max $0 (- a b)))

; ---- Filing status ----

; Married as of the end of the year, or of a spouse's death during it; a
; divorce or a decree of separate maintenance ends it.
(input married : bool :default false
  :label "Married at the end of the year, or when your spouse died during it"
  :cite "IRC §7703(a)")
(input files-separately : bool :default false
  :label "Married, filing a separate return from your spouse" :cite "IRC §6013(a)")
(input spouse-apart : bool :default false
  :label "Your spouse wasn't a member of your household for the last 6 months of the year"
  :cite "IRC §7703(b)(3)")
(input kept-up-home : bool :default false
  :label "You paid more than half the cost of keeping up your home for the year"
  :cite "IRC §2(c), §7703(b)(2)")
(input kept-up-parents-home : bool :default false
  :label "You paid more than half the cost of keeping up your father's or mother's home for the year"
  :cite "IRC §2(b)(1)(B)")
(input widowed-recently : bool :default false
  :label "Your spouse died in either of the two years before this one, you haven't remarried, and you could have filed jointly for the year they died"
  :cite "IRC §2(a)")

; Married filing separately, but unmarried for the filing status: your
; spouse away for the last 6 months, from a home you kept up that was for
; more than half the year your child's, your dependent or released to the
; other parent.
(def considered-unmarried :label "Considered unmarried" :cite "IRC §7703(b)"
  (and married files-separately spouse-apart kept-up-home
       (any people (and (or (= relationship 'child) (= relationship 'foster-child))
                        (not lived-apart) (or dependent released)))))
; Widowed in either of the last two years, keeping up a home that was all
; year a dependent child's, but not a foster child's.
(def surviving-spouse :label "A qualifying surviving spouse" :cite "IRC §2(a)"
  (and (not married) widowed-recently kept-up-home
       (any people (and (= relationship 'child) dependent household-all-year))))
; Unmarried, or considered so, keeping up a home that was for more than
; half the year a qualifying person's, or a dependent parent's home.
(def head-of-household :label "A head of household" :cite "IRC §2(b)"
  (and (or (not married) considered-unmarried)
       (or (and kept-up-home (any people hoh-person))
           (and kept-up-parents-home (any people (and (= relationship 'parent) dependent))))))
; Joint or separate is the one choice; the rest follows from the facts.
(def joint :label "Filing a joint return" (and married (not files-separately)))
(def filing-status :label "Filing status" :cite "IRC §§1, 2, 6013, 7703"
  (cond (joint 'married-joint)
        ((and married (not considered-unmarried)) 'married-separate)
        (surviving-spouse 'qualifying-surviving-spouse)
        (head-of-household 'head-of-household)
        (else 'single)))

; Each filer's own W-2s and businesses are the ones that match `is-spouse`.
(module you (def is-spouse false) (include "person.lisp"))
(module spouse (def is-spouse true) (include "person.lisp"))   ; read only on a joint return

(input claimed-as-dependent : bool :default false
  :label "Someone can claim you as a dependent" :line 12a)
; For whether you're a child the kiddie tax applies to (Form 8615), and so
; whether your American opportunity credit can be refundable (Form 8863,
; line 7): at 18, or as a full-time student (`you/full-time-student`) under
; 24, only if supported much like a dependent.
(input supported : bool :default false
  :label "Your earned income was no more than half of your own support"
  :cite "IRC §1(g)(2)(A)(ii)(II)")
(input parents-deceased : bool :default false
  :label "Neither of your parents was alive at the end of the year"
  :cite "IRC §1(g)(2)(B)")

(input spouse-itemizes : bool :default false
  :label "Married filing separately, and your spouse itemizes deductions" :line 12b
  :cite "IRC §63(c)(6)(A)")
; Read only on a separate return, for social security benefits and the
; IRA deduction.
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
; A married filer apart from their spouse for the last 6 months, or living
; apart at the end of the year under a separation agreement.
(input separation-agreement : bool :default false
  :label "Separated from your spouse under a written agreement, and living apart at the end of the year"
  :cite "IRC §32(d)(2)")
(def separated-spouse :cite "IRC §32(d)(2)" (or spouse-apart separation-agreement))
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

; Children, relatives and household members you may be able to claim. Each
; is a dependent as a qualifying child or a qualifying relative, by Steps 1
; through 5 of the instructions; some who aren't, such as a child who
; supports themselves, still count for the EIC.
(collection people :label "Children, relatives and household members you may be able to claim"
  (input birth-date : date :label "Date of birth")
  (input relationship : relationship :label "Relationship to you" :cite "IRC §152(c)(2), (d)(2)")
  (input tin : tin :label "Identification number issued by the return's due date")
  ; Time away at school, on vacation, in the hospital or in the military
  ; counts as time with you; so does all of a life that began or ended in
  ; the year, if it was more than half spent with you.
  (input lived-apart : bool :default false
    :label "Lived with you for half the year or less" :cite "IRC §152(c)(1)(B)")
  (input full-time-student : bool :default false
    :label "A full-time student for some part of 5 months of the year"
    :cite "IRC §152(c)(3)(A)(ii), (f)(2)")
  (input permanently-disabled : bool :default false
    :label "Permanently and totally disabled at any time in the year" :cite "IRC §152(c)(3)(B)")
  (input own-support : bool :default false
    :label "Provided over half of their own support" :cite "IRC §152(c)(1)(D)")
  (input married : bool :default false :label "Married at the end of the year")
  (input joint-return : bool :default false
    :label "Files a joint return, other than only to claim a refund"
    :cite "IRC §152(b)(2), (c)(1)(E)")
  ; Someone who isn't can still be a dependent while living in Canada or
  ; Mexico, but gets neither credit.
  (input nonresident-alien : bool :default false
    :label "Not a U.S. citizen, national or resident alien" :cite "IRC §24(c)(2), (h)(4)(B)")
  (input canada-mexico : bool :default false
    :label "Lived in Canada or Mexico" :cite "IRC §152(b)(3)(A)")
  (input lived-abroad : bool :default false
    :label "Lived with you outside the United States for more than half the year"
    :cite "IRC §32(c)(3)(C)")
  ; Children of divorced or separated parents: the custodial parent's
  ; release makes the child the other parent's dependent, but leaves the
  ; EIC and the child and dependent care credit with the custodial parent.
  (input released : bool :default false
    :label "As the custodial parent, you released your claim to them to the other parent (Form 8332)"
    :cite "IRC §152(e)")
  (input released-to-you : bool :default false
    :label "As the noncustodial parent, the custodial parent released their claim to them to you (Form 8332)"
    :cite "IRC §152(e)")

  ; ---- Qualifying child (Step 1) ----

  ; Younger than you (or your spouse on a joint return) and under 19, or a
  ; student under 24, at the end of the year; or permanently and totally
  ; disabled. A child turns 19 on their 19th birthday.
  (def age-test :label "Meets the age test" :cite "IRC §152(c)(3)"
    (or permanently-disabled
        (and (or (< (age-on birth-date law/year-end) 19)
                 (and full-time-student (< (age-on birth-date law/year-end) 24)))
             (or (> birth-date you/birth-date) (and joint (> birth-date spouse/birth-date))))))
  ; Everything but the support test, which the EIC goes without.
  (def child-tests :label "Meets the relationship, residency, age and joint return tests"
    :cite "IRC §152(c)(1)(A)–(C), (E)"
    (and (or (= relationship 'child) (= relationship 'foster-child) (= relationship 'sibling)
             (= relationship 'descendant))
         (not lived-apart) (not joint-return) age-test))
  (def qualifying-child :label "Your qualifying child" :cite "IRC §152(c), (e)"
    (or released-to-you (and child-tests (not own-support) (not released))))

  ; ---- Qualifying relative (Step 4) ----

  ; Anyone else who lived with you all year counts as a household member,
  ; if the relationship doesn't violate local law.
  (input household-all-year : bool
    :label "Lived with you all year as a member of your household"
    :cite "IRC §152(d)(2)(H), (f)(3)")
  ; Such as your partner's child, when your partner has to file.
  (input others-qualifying-child : bool :default false
    :label "Someone else's qualifying child, who has to file a return" :cite "IRC §152(d)(1)(D)")
  (input gross-income : usd
    :label "Their gross income for the year, leaving out tax-exempt income such as most social security"
    :cite "IRC §152(d)(1)(B)")
  (input supported : bool :label "You provided over half of their support"
    :cite "IRC §152(d)(1)(C)")
  (def qualifying-relative :label "Your qualifying relative" :cite "IRC §152(d)"
    (and (not qualifying-child) (not released) (not own-support) (not joint-return)
         (not others-qualifying-child)
         (or (!= relationship 'unrelated) household-all-year)
         (< gross-income law/qualifying-relative-income-limit)
         supported))

  ; ---- Dependent (Steps 2 and 4) ----

  ; Nobody is your dependent if you can be claimed yourself, unless you file
  ; jointly.
  (def dependent :label "Your dependent" :cite "IRC §152(a), (b)"
    (and (or joint (not claimed-as-dependent))
         (or (not nonresident-alien) canada-mexico)
         (or qualifying-child qualifying-relative)))

  ; For head of household: an unmarried qualifying child, even one who
  ; isn't your dependent, or a dependent relative, who lived with you more
  ; than half the year. Not a child who is your dependent only by the other
  ; parent's release, nor someone who is only by living with you all year.
  (def hoh-person :label "A qualifying person for head of household"
    :cite "IRC §2(b)(1)(A), (b)(3)(B)"
    (or (and child-tests (not own-support) (or (not married) dependent))
        (and dependent (not lived-apart) (not released-to-you) (!= relationship 'unrelated))))

  ; For the child and dependent care credit (Form 2441, line 2).
  (input disabled : bool :default false
    :label "Not physically or mentally able to care for themselves" :cite "IRC §21(b)(1)")
  (input care-expenses : usd :default $0
    :label "Care expenses you paid for them so you could work" :cite "IRC §21(b)(2)")
  ; A dependent qualifying child under 13 for some of the year (expenses
  ; only for that part count), or a disabled dependent who lived with you;
  ; a child released to the other parent stays the custodial parent's.
  (def care-person :label "A qualifying person for the child and dependent care credit"
    :cite "IRC §21(b)(1), (e)(5)"
    (and (not released-to-you)
         (or (and (< (age-on birth-date law/year-start) 13)
                  (or released (and dependent qualifying-child)))
             (and disabled (not lived-apart) (or released dependent)))))
  ; As a student, for an education credit (Form 8863, Part III, lines 23
  ; through 31).
  (input education-expenses : usd :default $0
    :label "Adjusted qualified education expenses paid for them" :cite "IRC §25A(f)")
  (input aotc-four-years : bool :default false
    :label "The American opportunity credit was claimed for them for 4 earlier years" :line 23)
  (input less-than-half-time : bool :default false
    :label "Not enrolled at least half-time toward a degree or credential" :line 24)
  (input four-years-done : bool :default false
    :label "Finished the first 4 years of postsecondary education before this year" :line 25)
  (input drug-felony : bool :default false
    :label "Convicted of a felony for a controlled substance" :line 26)
  (def aotc-student :label "Takes the American opportunity credit" :cite "IRC §25A(b)(2)"
    (and (> education-expenses $0) dependent (!= tin 'no-tin) (not aotc-four-years)
         (not less-than-half-time) (not four-years-done) (not drug-felony)))
  ; For the premium tax credit's household income (Form 8962, Worksheet 1-2).
  (input magi : usd :default $0
    :label "Their modified AGI, if their income requires them to file a return"
    :cite "IRC §36B(d)(2)(A)(ii)")
  ; A child turns 17 on their 17th birthday (Rev. Rul. 2003-72), so one
  ; born after 2008-12-31 is under 17 at the end of 2025.
  (def ctc-child :label "Qualifies for the child tax credit" :cite "IRC §24(c), (e), (h)(7)"
    (and dependent qualifying-child (not nonresident-alien) (< (age-on birth-date law/year-end) 17)
         (= tin 'ssn) filer-has-ssn filers-have-tins))
  ; Every other dependent with a number, including a child under 17 who
  ; misses the credit only for want of an SSN.
  (def odc-dependent :label "Qualifies for the credit for other dependents"
    :cite "IRC §24(h)(4)"
    (and dependent (not ctc-child) (not nonresident-alien) (!= tin 'no-tin) filers-have-tins))
  ; The EIC takes a qualifying child without the support test or the
  ; release, a married one only if your dependent (or released), and only
  ; one who lived with you in the United States. A child without a valid
  ; SSN is still your qualifying child, but isn't counted toward the credit.
  (def eic-qualifying-child :label "Your qualifying child for the EIC" :cite "IRC §32(c)(3)"
    (and child-tests (not released-to-you) (not lived-abroad)
         (or (not married) dependent released)))
  (def eic-child :label "Counts toward the EIC" :cite "IRC §32(c)(3)(D), (m)"
    (and eic-qualifying-child (= tin 'ssn))))

; A statutory employee's W-2 goes on Schedule C instead.
(collection w2s :label "Forms W-2"
  (input spouses : bool :default false :label "Your spouse's W-2, on a joint return")
  (input wages : usd :label "Wages, tips, other compensation" :line 1)
  (input withheld : usd :label "Federal income tax withheld" :line 2)
  ; Asked only of someone with self-employment income, for Schedule SE.
  (input ss-wages : usd :label "Social security wages" :line 3)
  (input ss-tips : usd :default $0 :label "Social security tips" :line 7)
  (input ss-withheld : usd :label "Social security tax withheld" :line 4)
  (input medicare-wages : usd :label "Medicare wages and tips" :line 5)
  (input medicare-withheld : usd :label "Medicare tax withheld" :line 6)
  (input dependent-care : usd :default $0 :label "Dependent care benefits" :line 10)
  (input deferrals : usd :default $0
    :label "Elective deferrals to a 401(k) or other plan (box 12, codes D, E, F, G, S, AA, BB, EE)"
    :line 12)
  ; For Schedule 1-A. Tips count if paid by choice, in cash or by card, in
  ; an occupation that customarily received them before 2025. Of overtime
  ; paid at time-and-a-half, a third is the premium.
  (input qualified-tips : usd :default $0
    :label "Of the tips (box 7, or as reported on Forms 4070), those received in an occupation listed at IRS.gov/TippedOccupations"
    :cite "IRC §224(d)")
  (input qualified-overtime : usd :default $0
    :label "Of the wages, overtime pay the Fair Labor Standards Act requires beyond your regular rate: the half of time-and-a-half"
    :cite "IRC §225(c)"))

(collection f1099-ints :label "Forms 1099-INT"
  (input interest : usd :label "Interest income" :line 1)
  (input treasury-interest : usd :default $0
    :label "Interest on U.S. Savings Bonds and Treasury obligations" :line 3)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4)
  (input tax-exempt-interest : usd :default $0 :label "Tax-exempt interest" :line 8)
  ; Taxed by the AMT (Form 6251, line 2g).
  (input private-activity-interest : usd :default $0
    :label "Specified private activity bond interest" :line 9 :cite "IRC §57(a)(5)"))

(collection f1099-divs :label "Forms 1099-DIV"
  (input ordinary : usd :label "Total ordinary dividends" :line 1a)
  (input qualified : usd :default $0 :label "Qualified dividends" :line 1b)
  (input cap-gain : usd :default $0 :label "Total capital gain distributions" :line 2a)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4)
  ; Qualified REIT dividends, for Form 8995, if the shares were held more
  ; than 45 days.
  (input section-199a : usd :default $0 :label "Section 199A dividends" :line 5
    :cite "IRC §199A(e)(3); Treas. Reg. §1.199A-3(c)(2)")
  (input exempt-interest : usd :default $0 :label "Exempt-interest dividends" :line 12)
  (input private-activity-dividends : usd :default $0
    :label "Specified private activity bond interest dividends" :line 13 :cite "IRC §57(a)(5)"))

; Sales of stock and other capital assets, as Forms 1099-B and 1099-DA
; report them (in 1099-B's boxes here), or any sale without one: each a row
; of Form 8949.
(collection f1099-bs :label "Forms 1099-B and 1099-DA"
  (input proceeds : usd :label "Proceeds" :line 1d)
  (input cost : usd :label "Cost or other basis" :line 1e)
  ; Such as a wash sale's disallowed loss (box 1g), added back.
  (input adjustment : usd :default $0
    :label "Adjustment to gain or loss (Form 8949, column (g))" :line 1g)
  (input long-term : bool :label "Long-term: held more than one year" :line 2
    :cite "IRC §1222")
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4)
  (def gain :label "Gain or loss (Form 8949, column (h))" (+ (- proceeds cost) adjustment)))

; From last year's Capital Loss Carryover Worksheet, as positive amounts.
(input st-loss-carryover : usd :default $0
  :label "Short-term capital loss carried over from last year" :cite "IRC §1212(b)")
(input lt-loss-carryover : usd :default $0
  :label "Long-term capital loss carried over from last year" :cite "IRC §1212(b)")

(collection f1099-gs :label "Forms 1099-G"
  (input unemployment : usd :label "Unemployment compensation" :line 1)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4))

; Distributions from IRAs, and from pensions, annuities and employer plans
; such as 401(k)s, told apart by the IRA/SEP/SIMPLE box. Box 2a left blank,
; or box 2b saying the payer didn't figure it, still has an answer: all of
; box 1 for a traditional IRA without nondeductible contributions.
(collection f1099-rs :label "Forms 1099-R"
  (input gross : usd :label "Gross distribution" :line 1)
  (input taxable : usd :label "Taxable amount" :line 2a)
  (input withheld : usd :default $0 :label "Federal income tax withheld" :line 4)
  (input early : bool :default false
    :label "Code 1 in box 7: an early distribution, no known exception" :line 7)
  (input ira : bool :default false :label "IRA/SEP/SIMPLE")
  (input rolled-over : usd :default $0
    :label "Part you rolled over yourself within 60 days" :cite "IRC §402(c), §408(d)(3)")
  (def taxable-part :label "Taxable part" (excess taxable rolled-over)))

; Health coverage bought through a Marketplace, for the premium tax credit.
; Every policy is taken to cover the same months, at the same amounts each
; month.
(input marketplace : bool :default false
  :label "You or someone in your tax family had coverage from a Health Insurance Marketplace"
  :cite "IRC §36B(c)(3)")
(input marketplace-months : number :default 12 :label "Months of Marketplace coverage")
(input residence : residence :default 'states-dc :label "State of residence for the federal poverty line")
; Married filing separately takes the credit only when a victim of domestic
; abuse or abandoned by the spouse (Form 8962, line A).
(input ptc-separate-exception : bool :default false
  :label "Married filing separately, but living apart from a spouse who abused or abandoned you"
  :cite "Treas. Reg. §1.36B-2(b)(2)")
(collection f1095-as :label "Forms 1095-A"
  (input premiums : usd :label "Annual enrollment premiums" :line 33A)
  (input slcsp : usd :label "Annual applicable SLCSP premium" :line 33B)
  (input advance : usd :default $0
    :label "Annual advance payment of premium tax credit" :line 33C))

; Stock bought by exercising an incentive stock option and still held at
; the end of the year: no income for the regular tax, but for the AMT its
; value when first transferable or vested, less what was paid (Form 3921,
; box 4 less box 3, times box 5).
(input iso-adjustment : usd :default $0
  :label "Incentive stock options exercised: the stock's value less what you paid, for shares not sold in the year"
  :cite "IRC §56(b)(3)")

; Railroad retirement benefits treated as social security (Form RRB-1099,
; boxes 5 and 10) go here too.
(collection ssa1099s :label "Forms SSA-1099"
  (input net-benefits : usd :label "Net benefits for the year" :line 5)
  (input withheld : usd :default $0 :label "Voluntary federal income tax withheld" :line 6))

; What the lender received is what you paid, as long as it was on a
; qualified student loan you were legally obligated to pay.
(collection f1098-es :label "Forms 1098-E"
  (input interest : usd :label "Student loan interest received by lender" :line 1))

; Car loan interest, for Schedule 1-A: on a loan taken out after 2024 to buy
; a new car, minivan, van, SUV, pickup or motorcycle under 14,000 pounds,
; assembled in the United States and mostly for personal use, secured by a
; first lien on it. Not a lease, nor a loan from a relative; a refinancing
; counts up to the balance it paid off.
(input vehicle-loan : bool :default false
  :label "You or your spouse paid interest on a loan for a new vehicle bought after 2024 for personal use"
  :cite "IRC §163(h)(4)(B), (D)")
(collection vehicle-loans :label "Loans for new vehicles, each with the vehicle's VIN"
  (input interest : usd :label "Interest paid or accrued for the year")
  (input deducted : usd :default $0 :label "Of that, interest deducted on Schedule C, E or F"))

(include "forms/f1040sc.lisp")

; For the kiddie tax (Form 8615), when you're a child it applies to: from
; the return of the parent whose rate it uses, and the Forms 8615 of the
; parent's other children that use it too.
(input parent-filing-status : filing-status :label "The parent's filing status (Form 8615, line C)")
(input parent-taxable-income : usd :label "The parent's taxable income (Form 1040, line 15)" :line 6)
(input parent-tax : usd
  :label "The parent's tax (Form 1040, line 16), not counting any from Forms 4972 and 8814"
  :line 10)
(input parent-qualified-dividends : usd :default $0
  :label "The parent's qualified dividends (Form 1040, line 3a)")
(input parent-net-capital-gain : usd :default $0
  :label "The parent's net capital gain: the smaller of Schedule D lines 15 and 16, or Form 1040 line 7a")
(input other-children-unearned : usd :default $0
  :label "The parent's other children's net unearned income (their Forms 8615, line 5)" :line 7)
(input other-children-qualified-dividends : usd :default $0
  :label "Of that, qualified dividends")
(input other-children-net-capital-gain : usd :default $0
  :label "Of that, net capital gain")

; For the qualified business income deduction. Last year's Form 8995 lines
; 16 and 17, as positive amounts.
(input qbi-loss-carryforward : usd :default $0
  :label "Qualified business net loss carried forward from last year" :line 3
  :cite "IRC §199A(c)(2)")
(input reit-ptp-loss-carryforward : usd :default $0
  :label "Qualified REIT dividends and PTP loss carried forward from last year" :line 7)
; Above the threshold the deduction takes Form 8995-A, with its limits by
; W-2 wages and property and its phaseout for a specified service
; business, which isn't modeled: its result is asked for instead.
(input f8995a-deduction : usd
  :label "Qualified business income deduction from Form 8995-A"
  :cite "IRC §199A(b)(2), (b)(3), (d)(3)")

(module law (include "law/2025.lisp"))

(module f1040 (include "forms/f1040.lisp"))
(module f1040-qdcg
  (def income f1040/line15)
  (def qualified-dividends f1040/line3a)
  ; Schedule D's net long-term gain, as far as the net gain goes: just the
  ; capital gain distributions when they're all there is.
  (def net-capital-gain (max $0 (min f1040sd/line15 f1040sd/line16)))
  (def status filing-status)
  (include "forms/f1040-qdcg.lisp"))
; Taxable social security benefits after the IRA deduction, and before it
; for figuring the deduction of someone covered by a retirement plan at
; work (Pub. 590-A, Appendix B, Worksheets 3 and 1).
(module f1040-ssb
  (def adjustments (+ f1040s1/line13 f1040s1/line15 f1040s1/line20)) ; + 11 12 14 16–19 23 25
  (include "forms/f1040-ssb.lisp"))
(module p590a-ssb
  (def adjustments (+ f1040s1/line13 f1040s1/line15))             ; + 11 12 14 16–19 23 25
  (include "forms/f1040-ssb.lisp"))
(module f1040-eic (include "forms/f1040-eic.lisp"))
(module f1040-eic-b (include "forms/f1040-eic-b.lisp"))
(module f1040s1 (include "forms/f1040s1.lisp"))
(module f1040s1-ira (include "forms/f1040s1-ira.lisp"))
(module f1040s1-sli (include "forms/f1040s1-sli.lisp"))
(module f1040s1a (include "forms/f1040s1a.lisp"))
(module f1040s2 (include "forms/f1040s2.lisp"))
(module f1040s3 (include "forms/f1040s3.lisp"))
(module f1040s8 (include "forms/f1040s8.lisp"))
(module f2441 (include "forms/f2441.lisp"))
(module f8863 (include "forms/f8863.lisp"))
(module f8880 (include "forms/f8880.lisp"))
(module f8962 (include "forms/f8962.lisp"))
(module f8995 (include "forms/f8995.lisp"))
(module f6251 (include "forms/f6251.lisp"))
(module f8615 (include "forms/f8615.lisp"))
(module f8615-ws1 (include "forms/f8615-ws1.lisp"))
(module f8615-ws3 (include "forms/f8615-ws3.lisp"))
; The tax at the parent's rate on the child's net unearned income added to
; the parent's taxable income (line 9), and at the child's on the rest
; (line 15), each with its share of the qualified dividends and net
; capital gain.
(module f8615-qdcg9
  (def income f8615/line8)
  (def qualified-dividends
    (+ f8615/line5-dividends parent-qualified-dividends other-children-qualified-dividends))
  (def net-capital-gain
    (+ f8615/line5-gain parent-net-capital-gain other-children-net-capital-gain))
  (def status parent-filing-status)
  (include "forms/f1040-qdcg.lisp"))
(module f8615-qdcg15
  (def income f8615/line14)
  (def qualified-dividends (- f1040-qdcg/line2 f8615/line5-dividends))
  (def net-capital-gain (- f1040-qdcg/line3 f8615/line5-gain))
  (def status filing-status)
  (include "forms/f1040-qdcg.lisp"))
(module f1040sd (include "forms/f1040sd.lisp"))
(module f1040sa (include "forms/f1040sa.lisp"))
(module f1040sa-salt (include "forms/f1040sa-salt.lisp"))
(module f8959 (include "forms/f8959.lisp"))
(module f8960 (include "forms/f8960.lisp"))
