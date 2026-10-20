; Education credits: Form 8863.

(test "the American opportunity credit: all of $2,000, 25% of the next $2,000, 40% refundable"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn
         you/education-expenses $5,000)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8863/line1 $2,500
          f8863/line8 $1,000
          f1040/line29 $1,000
          f8863/line19 $1,500
          f1040s3/line3 $1,500
          f1040/line22 $2,375))                      ; tax $3,875, less $1,500

(test "the credits phase out from $80,000 to $90,000 of modified AGI"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn
         you/education-expenses $4,000)
  (member w2s acme (given wages $85,000 medicare-wages $85,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8863/line6 0.5                            ; $5,000 ÷ $10,000
          f8863/line7 $1,250
          f8863/line8 $500))

(test "the lifetime learning credit: 20% of up to $10,000 on the return"
  (given filing-status 'married-joint
         you/birth-date 1990-05-01 you/tin 'ssn you/education-expenses $6,000
         you/four-years-done true
         spouse/birth-date 1990-05-01 spouse/tin 'ssn spouse/education-expenses $7,000
         spouse/aotc-four-years true)
  (member w2s acme (given wages $100,000 medicare-wages $100,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8863/line1 $0
          f8863/line10 $13,000
          f8863/line18 $2,000
          f8863/line19 $2,000))

(test "a dependent's expenses, with the child tax credit's limit after them"
  (given filing-status 'head-of-household you/birth-date 1975-01-01 you/tin 'ssn)
  (member w2s acme (given wages $60,000 medicare-wages $60,000 withheld $0))
  (member dependents kid
    (given birth-date 2005-03-01 qualifying-child true tin 'ssn education-expenses $4,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs)
  (expect f8863/line1 $2,500
          f8863/line19 $1,500
          f1040s8/line13 $2,525                      ; tax $4,025, less $1,500
          f1040s8/line14 $500))                      ; for a 20-year-old

(test "none refundable under 24 when supported like a dependent, with a parent alive"
  (given filing-status 'single you/birth-date 2004-06-01 you/tin 'ssn
         you/education-expenses $4,000 full-time-student true supported true)
  (member w2s cafe (given wages $20,000 medicare-wages $20,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8863/young-student true
          f8863/line8 $0
          f8863/line9 $2,500
          f8863/line19 $428)                         ; all the tax there is
  (given parents-deceased true)
  (expect f8863/line8 $1,000
          f1040/line29 $1,000))

(test "none on a separate return, or for someone another taxpayer can claim"
  (given filing-status 'married-separate you/birth-date 1990-05-01 you/tin 'ssn
         you/education-expenses $4,000)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8863/line1 $0 f8863/line19 $0)
  (given filing-status 'single claimed-as-dependent true)
  (expect f8863/line1 $0 f8863/line19 $0))

(test "after four years of the American opportunity credit, the lifetime learning credit"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn
         you/education-expenses $4,000 you/aotc-four-years true)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8863/line1 $0
          f8863/line10 $4,000
          f8863/line19 $800))                        ; 20% × $4,000
