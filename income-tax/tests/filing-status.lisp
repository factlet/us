; Filing status (IRC §2, §7703), from the facts of the year.

(test "single unless married; married files jointly unless filing separately"
  (given you/birth-date 1990-05-01)
  (expect filing-status 'single joint false)
  (given married true)
  (expect filing-status 'married-joint joint true)
  (given files-separately true)
  (expect filing-status 'married-separate joint false))

(test "head of household, keeping up a home for a qualifying child"
  (given you/birth-date 1990-05-01)
  (member people kid (given birth-date 2018-01-01 relationship 'child tin 'ssn)
    (expect hoh-person true))
  (expect filing-status 'single)                     ; not without paying for the home
  (given kept-up-home true)
  (expect filing-status 'head-of-household))

(test "or for a dependent relative who lived there, or a dependent parent's own home"
  (given you/birth-date 1980-01-01 kept-up-home true)
  ; Your dependent only by living with you all year.
  (member people roommate
    (given birth-date 1960-01-01 relationship 'unrelated tin 'ssn gross-income $0 supported true
           household-all-year true)
    (expect dependent true hoh-person false))
  ; Your dependent only by the custodial parent's release.
  (member people son
    (given birth-date 2015-01-01 relationship 'child lived-apart true tin 'ssn released-to-you true)
    (expect dependent true hoh-person false))
  (member people mom
    (given birth-date 1950-01-01 relationship 'parent lived-apart true tin 'ssn gross-income $0
           supported true)
    (expect dependent true hoh-person false))
  (expect filing-status 'single)
  (given kept-up-parents-home true)
  (expect filing-status 'head-of-household))

(test "a dependent relative living with you counts, but not a married child who isn't your dependent"
  (given you/birth-date 1970-01-01 kept-up-home true)
  (member people uncle
    (given birth-date 1950-01-01 relationship 'other-relative tin 'ssn gross-income $0
           supported true)
    (expect hoh-person true))
  (member people daughter
    (given birth-date 2006-01-01 relationship 'child full-time-student true tin 'ssn
           married true own-support true)
    (expect hoh-person false)))

(test "married filing separately is unmarried for it, apart from a spouse, keeping up a child's home"
  (given you/birth-date 1990-05-01 married true files-separately true spouse-apart true)
  (member people kid (given birth-date 2018-01-01 relationship 'foster-child tin 'ssn))
  (expect considered-unmarried false filing-status 'married-separate)
  (given kept-up-home true)
  (expect considered-unmarried true filing-status 'head-of-household))

(test "a qualifying surviving spouse keeps up a home all year for a dependent child"
  (given you/birth-date 1980-01-01 widowed-recently true kept-up-home true)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (member f1099-ints bank (given interest $60,000))
  (member people kid
    (given birth-date 2015-01-01 relationship 'child tin 'ssn household-all-year true))
  (empty f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect filing-status 'qualifying-surviving-spouse
          ; the net investment income tax from $250,000, as on a joint return
          f8960/line14 $250,000
          f1040s2/line12 $380))                      ; 3.8% × $10,000

(test "but not for a foster child, nor one who lived there only part of the year"
  (given you/birth-date 1980-01-01 widowed-recently true kept-up-home true)
  (member people a
    (given birth-date 2015-01-01 relationship 'foster-child tin 'ssn household-all-year true))
  (member people b
    (given birth-date 2016-01-01 relationship 'child tin 'ssn household-all-year false))
  (expect filing-status 'head-of-household))

(test "a married head of household takes the EIC only with a qualifying child"
  (given you/birth-date 1980-01-01 you/tin 'ssn kept-up-home true)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  ; 21 and not a student: a qualifying relative, not a qualifying child
  (member people son
    (given birth-date 2004-06-01 relationship 'child tin 'ssn gross-income $3,000 supported true)
    (expect qualifying-child false dependent true hoh-person true))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect filing-status 'head-of-household
          f1040/line27a $614)                        ; without a child: 7.65% × $8,025
  (given married true files-separately true spouse-apart true)
  (expect filing-status 'head-of-household
          f1040/line27a $0))
