; The credit for child and dependent care expenses: Form 2441, Schedule 3,
; and the child tax credit's Credit Limit Worksheet A after it.

(test "20% of up to $3,000 for one child, and the child tax credit takes what tax is left"
  (given filing-status 'married-joint
         you/birth-date 1985-01-01 you/tin 'ssn spouse/birth-date 1987-01-01 spouse/tin 'ssn)
  (member w2s yours (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member w2s theirs (given wages $20,000 medicare-wages $20,000 withheld $0 spouses true))
  (member people kid
    (given birth-date 2020-01-01 relationship 'child tin 'ssn care-expenses $4,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f2441/line3 $3,000
          f2441/line6 $3,000
          f2441/line8 20%                            ; from AGI of $43,000 on
          f2441/line11 $600
          f1040s3/line8 $600
          ; row middle $18,525: tax $1,853, less the $600
          f1040s8/line13 $1,253
          f1040/line19 $1,253
          f1040/line22 $0))

(test "35% less 1% for each $2,000 over $15,000; two children, up to $6,000"
  (given filing-status 'head-of-household you/birth-date 1990-01-01 you/tin 'ssn)
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member people a
    (given birth-date 2019-01-01 relationship 'child tin 'ssn care-expenses $3,500))
  (member people b
    (given birth-date 2021-01-01 relationship 'child tin 'ssn care-expenses $3,500))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f2441/line3 $6,000
          f2441/line8 27%                            ; 35% − 8%
          f2441/line9a $1,620
          ; limited by the tax: 10% of row middle $6,375
          f2441/line11 $638
          ; which leaves none for the child tax credit, but $3,400 of it refundable
          f1040s8/line14 $0
          f1040s8/line27 $3,400))

(test "no more than the lower earner's earned income; a student spouse counts $250 a month"
  (given filing-status 'married-joint
         you/birth-date 1985-01-01 spouse/birth-date 1987-01-01 spouse/care-deemed-months 9)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member people kid
    (given birth-date 2020-01-01 relationship 'child tin 'ssn care-expenses $3,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect spouse/earned-income $2,250
          f2441/line6 $2,250
          f2441/line11 $495))                        ; 22% × $2,250

(test "employer dependent care benefits are excluded up to $5,000, and use up the expense limit"
  (given filing-status 'head-of-household you/birth-date 1990-01-01)
  (member w2s acme
    (given wages $50,000 medicare-wages $50,000 withheld $0 dependent-care $5,000))
  (member people a
    (given birth-date 2019-01-01 relationship 'child tin 'ssn care-expenses $4,000))
  (member people b
    (given birth-date 2021-01-01 relationship 'child tin 'ssn care-expenses $4,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f2441/line25 $5,000
          f2441/line26 $0
          f2441/line29 $1,000                        ; $6,000 − $5,000
          f2441/line31 $1,000
          f2441/line11 $200))

(test "benefits past the expenses are taxable wages"
  (given filing-status 'single you/birth-date 1990-01-01)
  (member w2s acme
    (given wages $40,000 medicare-wages $40,000 withheld $0 dependent-care $5,000))
  (member people kid
    (given birth-date 2020-01-01 relationship 'child tin 'ssn care-expenses $3,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f2441/line26 $2,000
          f1040/line1e $2,000
          f1040/line1z $42,000
          f2441/line11 $0))

(test "married filing separately takes it only when considered unmarried"
  (given filing-status 'married-separate you/birth-date 1990-01-01)
  (member w2s acme (given wages $40,000 medicare-wages $40,000 withheld $0))
  (member people kid
    (given birth-date 2020-01-01 relationship 'child tin 'ssn care-expenses $2,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f2441/line11 $0)
  (given considered-unmarried true)
  (expect f2441/line11 $440))                        ; 22% × $2,000

(test "a child counts only before turning 13, unless disabled"
  (given filing-status 'single you/birth-date 1990-01-01)
  (member people a (given birth-date 2012-01-01 relationship 'child tin 'ssn)
    (expect care-person false))                      ; 13 all year
  (member people b (given birth-date 2012-01-02 relationship 'child tin 'ssn)
    (expect care-person true))                       ; 12 on January 1
  (member people c
    (given birth-date 2005-01-01 relationship 'sibling tin 'ssn disabled true
           gross-income $0 supported true)
    (expect care-person true))
  (expect f2441/persons 2))
