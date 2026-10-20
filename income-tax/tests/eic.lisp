; Credits: the earned income credit (Form 1040 line 27a). The amounts are
; the 2025 EIC Table's, which credits the middle of each $50 row.

(test "the EIC Table's example: single, one child, $2,455"
  (given filing-status 'single you/birth-date 1995-01-01 you/tin 'ssn)
  (member w2s cafe (given wages $2,455 medicare-wages $2,455 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2020-01-01 qualifying-child true tin 'ssn))
  (expect f1040-eic/children 1
          f1040-eic/line2 $842                       ; 34% × $2,475
          f1040-eic/line6 $842
          f1040/line27a $842))

(test "without a child, the credit rises at 7.65% to $649"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line27a $614)                        ; 7.65% × $8,025
  (member w2s side-gig (given wages $1,000 medicare-wages $1,000 withheld $0))
  (expect f1040/line27a $649))                       ; 7.65% × $9,025 is past the maximum

(test "AGI past the phaseout start takes the smaller of the two credits"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $9,000 medicare-wages $9,000 withheld $0))
  (member f1099-ints bank (given interest $3,000))
  (empty f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040-eic/line2 $649
          f1040-eic/line5 $542                       ; $649 − 7.65% × ($12,025 − $10,620)
          f1040-eic/line6 $542
          f1040/line27a $542))

(test "the table's last row stops where the credit runs out"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $50,410 medicare-wages $50,410 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2020-01-01 qualifying-child true tin 'ssn))
  ; Row $50,400–$50,434, middle $50,417: $4,328 − 15.98% × $27,067
  (expect f1040/line27a $3)
  (member w2s side-gig (given wages $24 medicare-wages $24 withheld $0))
  (expect f1040/line27a $0))

(test "on a joint return, the credit without a child lasts to $26,214"
  (given filing-status 'married-joint
         you/birth-date 1990-01-01 you/tin 'ssn
         spouse/birth-date 1990-01-01 spouse/tin 'ssn)
  (member w2s acme (given wages $26,200 medicare-wages $26,200 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  ; Row $26,200–$26,214, middle $26,207: $649 − 7.65% × $8,477
  (expect f1040/line27a $1))

(test "each child moves the credit to the next column, up to three"
  (given filing-status 'married-joint
         you/birth-date 1985-01-01 you/tin 'ssn
         spouse/birth-date 1985-01-01 spouse/tin 'ssn)
  (member w2s acme (given wages $56,740 medicare-wages $56,740 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  ; Row middle $56,725 is $26,255 past the $30,470 phaseout start.
  (member dependents a (given birth-date 2015-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $132)                        ; $4,328 − 15.98% × $26,255
  (member dependents b (given birth-date 2017-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $1,623)                      ; $7,152 − 21.06% × $26,255
  (member dependents c (given birth-date 2019-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $2,517)                      ; $8,046 − 21.06% × $26,255
  (member dependents d (given birth-date 2021-01-01 qualifying-child true tin 'ssn))
  (expect f1040-eic/children 4 f1040/line27a $2,517))

(test "investment income over $11,950 ends the credit, tax-exempt interest included"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $5,000 medicare-wages $5,000 withheld $0))
  (member f1099-ints muni (given interest $0 tax-exempt-interest $11,950))
  (empty f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line2a $11,950
          f1040/line11a $5,000
          f1040-eic/investment-income $11,950
          f1040/line27a $384)                        ; 7.65% × $5,025
  (member f1099-ints bank (given interest $1))
  (expect f1040-eic/investment-income $11,951
          f1040/line27a $0))

(test "without a child, 25 by the end of the year and not yet 65"
  (given filing-status 'single you/tin 'ssn)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  ; Turning 25 counts a day early...
  (given you/birth-date 2001-01-01)
  (expect f1040/line27a $614)
  (given you/birth-date 2001-01-02)
  (expect f1040/line27a $0)
  ; ...but turning 65 doesn't, as it does for the standard deduction.
  (given you/birth-date 1961-01-01)
  (expect you/aged true f1040/line27a $614)
  (given you/birth-date 1960-12-31)
  (expect f1040/line27a $0))

(test "on a joint return, one spouse of working age is enough"
  (given filing-status 'married-joint
         you/birth-date 1950-01-01 you/tin 'ssn
         spouse/birth-date 1990-01-01 spouse/tin 'ssn)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line27a $614)
  ; Questions only single filers are asked.
  (given qualifying-child-of-another true claimed-as-dependent true)
  (expect f1040/line27a $614))

(test "a qualifying child without an SSN isn't counted, but waives the age rule"
  (given filing-status 'single you/birth-date 2004-01-01 you/tin 'ssn)   ; 21
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents mom (given birth-date 1970-01-01 qualifying-child false tin 'ssn))
  (expect f1040/line27a $0)
  (member dependents kid (given birth-date 2024-01-01 qualifying-child true tin 'itin))
  (expect f1040-eic/children 0
          f1040-eic/has-qualifying-child true
          f1040/line27a $614))                       ; the column for no children

(test "a child who lived abroad doesn't count"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents a
    (given birth-date 2015-01-01 qualifying-child true tin 'ssn lived-abroad true)
    (expect ctc-child true eic-child false))
  (member dependents b (given birth-date 2017-01-01 qualifying-child true tin 'ssn))
  (expect f1040-eic/children 1
          f1040/line27a $4,328))                     ; 34% × $20,025 is past the maximum

(test "married filing separately takes it with a child, once separated"
  (given filing-status 'married-separate you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2018-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $0)
  (given separated-spouse true)
  (expect f1040/line27a $4,328))

(test "married filing separately without a child never takes it"
  (given filing-status 'married-separate you/birth-date 1990-05-01 you/tin 'ssn
         separated-spouse true)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line27a $0))

(test "someone else's qualifying child can't take it"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2018-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $4,328)
  (given qualifying-child-of-another true)
  (expect f1040/line27a $0))

(test "without a child, neither a dependent nor someone living abroad can take it"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line27a $614)
  (given home-abroad true)
  (expect f1040/line27a $0)
  (given home-abroad false claimed-as-dependent true)
  (expect f1040/line27a $0))

(test "each filer needs a valid SSN, unlike for the child tax credit"
  (given filing-status 'married-joint
         you/birth-date 1990-01-01 you/tin 'ssn
         spouse/birth-date 1990-01-01 spouse/tin 'itin)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2018-01-01 qualifying-child true tin 'ssn))
  (expect f1040s8/line4 1
          f1040-eic/line6 $4,328
          f1040/line27a $0)
  (given spouse/tin 'nonwork-ssn)
  (expect f1040/line27a $0)
  (given spouse/tin 'ssn)
  (expect f1040/line27a $4,328))

(test "a nonresident alien for part of the year takes it only on a joint return"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $8,000 medicare-wages $8,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line27a $614)
  (given you/nonresident-alien true)
  (expect f1040/line27a $0)
  ; Filing jointly takes choosing to be treated as residents.
  (given filing-status 'married-joint spouse/birth-date 1990-01-01 spouse/tin 'ssn)
  (expect f1040/line27a $614))

(test "filing Form 2555 rules it out"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2018-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $4,328)
  (given files-f2555 true)
  (expect f1040/line27a $0))

(test "no credit while barred after a fraudulent or reckless claim"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member w2s acme (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (member dependents kid (given birth-date 2018-01-01 qualifying-child true tin 'ssn))
  (expect f1040/line27a $4,328)
  (given eic-barred true)
  (expect f1040/line27a $0))
