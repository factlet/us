; Children of divorced or separated parents (Form 8332), and other
; qualifying children who aren't dependents.

(test "the custodial parent who released the claim keeps the EIC and the care credit"
  (given filing-status 'head-of-household you/birth-date 1990-05-01 you/tin 'ssn
         nondependent-child true)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member nondependent-children kid
    (given birth-date 2017-01-01 tin 'ssn released true care-expenses $2,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s8/line4 0
          f1040-eic/children 1
          ; row middle $40,025: $4,328 − 15.98% × ($40,025 − $23,350)
          f1040/line27a $1,663
          f2441/persons 1
          f2441/line8 22%                            ; 35% − 13 × 1%
          ; row middle $16,375: tax $1,638
          f2441/line11 $440))

(test "the noncustodial parent gets the child tax credit, but not the EIC or the care credit"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member dependents kid
    (given birth-date 2017-01-01 qualifying-child true tin 'ssn released-to-you true
           care-expenses $2,000))
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
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn nondependent-child true)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member nondependent-children brother
    (given birth-date 2008-06-01 tin 'ssn disabled true care-expenses $2,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s8/line4 0
          f1040-eic/children 1
          f1040/line27a $1,663
          f2441/persons 0))

(test "a qualifying child who isn't a dependent counts only living in the United States, with an SSN"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn nondependent-child true)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (member nondependent-children a (given birth-date 2015-01-01 tin 'ssn lived-abroad true))
  (expect f1040-eic/has-qualifying-child false)
  (member nondependent-children b (given birth-date 2016-01-01 tin 'itin))
  (expect f1040-eic/children 0
          f1040-eic/has-qualifying-child true))
