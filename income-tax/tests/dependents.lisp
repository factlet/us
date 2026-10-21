; Dependents (IRC §152): qualifying children and qualifying relatives,
; children of divorced or separated parents (Form 8332), and qualifying
; children who aren't dependents.

(test "a qualifying child is under 19, or a student under 24, and younger than you"
  (given you/birth-date 2004-01-01)
  (member people teen (given birth-date 2007-01-01 relationship 'child tin 'ssn)
    (expect age-test true qualifying-child true))
  ; 19 on 2025-12-31
  (member people adult (given birth-date 2006-12-31 relationship 'child tin 'ssn)
    (expect age-test false qualifying-child false))
  (member people sister
    (given birth-date 2005-01-01 relationship 'sibling full-time-student true tin 'ssn)
    (expect age-test true))
  (member people brother
    (given birth-date 2003-06-01 relationship 'sibling full-time-student true tin 'ssn)
    (expect age-test false))                         ; older than you
  (member people disabled
    (given birth-date 1980-01-01 relationship 'sibling permanently-disabled true tin 'ssn)
    (expect age-test true qualifying-child true)))

(test "not one who supports themselves or files jointly, though the EIC takes the first"
  (given you/birth-date 1970-01-01 you/tin 'ssn)
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member people a
    (given birth-date 2005-01-01 relationship 'child full-time-student true own-support true
           tin 'ssn)
    (expect qualifying-child false dependent false eic-qualifying-child true))
  (member people b
    (given birth-date 2005-01-01 relationship 'child full-time-student true tin 'ssn
           married true joint-return true)
    (expect qualifying-child false eic-qualifying-child false))
  ; Married and not your dependent, so not for the EIC either.
  (member people c
    (given birth-date 2005-01-01 relationship 'child full-time-student true tin 'ssn
           married true own-support true)
    (expect eic-qualifying-child false))
  (expect f1040-eic/children 1))

(test "a qualifying relative has gross income under $5,200, and over half their support from you"
  (given you/birth-date 1990-05-01 you/tin 'ssn)
  ; Not a qualifying child, so asked about income and support.
  (member people grandma
    (given birth-date 1940-01-01 relationship 'other-relative tin 'ssn lived-apart true)
    (expect qualifying-child false dependent ?))
  (member people mom
    (given birth-date 1955-01-01 relationship 'parent tin 'ssn lived-apart true
           gross-income $5,199 supported true)
    (expect dependent true odc-dependent true))
  (member people dad
    (given birth-date 1955-01-01 relationship 'parent tin 'ssn lived-apart true
           gross-income $5,200 supported true)
    (expect dependent false))
  (member people aunt
    (given birth-date 1960-01-01 relationship 'other-relative tin 'ssn lived-apart true
           gross-income $0 supported false)
    (expect dependent false))
  ; Anyone else, only by living with you all year.
  (member people friend
    (given birth-date 1960-01-01 relationship 'unrelated tin 'ssn gross-income $0 supported true)
    (expect dependent ?))
  (member people roommate
    (given birth-date 1960-01-01 relationship 'unrelated tin 'ssn gross-income $0 supported true
           household-all-year true)
    (expect dependent true)))

(test "nobody is your dependent if someone can claim you, unless you file jointly"
  (given you/birth-date 2003-01-01 you/tin 'ssn claimed-as-dependent true)
  (member people kid (given birth-date 2024-01-01 relationship 'child tin 'ssn)
    (expect qualifying-child true dependent false))
  (expect f1040s8/line4 0)
  (given married true spouse/birth-date 2003-01-01 spouse/tin 'ssn)
  (expect f1040s8/line4 1))

(test "the custodial parent who released the claim keeps the EIC and the care credit"
  (given kept-up-home true you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member people kid
    (given birth-date 2017-01-01 relationship 'child tin 'ssn released true care-expenses $2,000)
    (expect dependent false))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f1040s8/line4 0
          f1040-eic/children 1
          ; row middle $40,025: $4,328 − 15.98% × ($40,025 − $23,350)
          f1040/line27a $1,663
          f2441/persons 1
          f2441/line8 22%                            ; 35% − 13 × 1%
          ; row middle $16,375: tax $1,638
          f2441/line11 $440))

(test "the noncustodial parent gets the child tax credit, but not the EIC or the care credit"
  (given you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member people kid
    (given birth-date 2017-01-01 relationship 'child lived-apart true tin 'ssn released-to-you true
           care-expenses $2,000)
    (expect dependent true))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f1040s8/line4 1
          ; row middle $24,275: tax $2,675, more than the credit
          f1040/line19 $2,200
          f1040-eic/children 0
          f1040-eic/has-qualifying-child false
          f1040/line27a $0                           ; too much income without one
          f2441/persons 0
          f2441/line11 $0))

(test "a child who provided over half their own support counts for the EIC only"
  (given you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member people brother
    (given birth-date 2008-06-01 relationship 'sibling own-support true tin 'ssn disabled true
           care-expenses $2,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f1040s8/line4 0
          f1040-eic/children 1
          f1040/line27a $1,663
          f2441/persons 0))

(test "an EIC child counts only living in the United States, with an SSN"
  (given you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member people a
    (given birth-date 2015-01-01 relationship 'child tin 'ssn lived-abroad true released true))
  (expect f1040-eic/has-qualifying-child false)
  (member people b (given birth-date 2016-01-01 relationship 'child tin 'itin released true))
  (expect f1040-eic/children 0
          f1040-eic/has-qualifying-child true))
