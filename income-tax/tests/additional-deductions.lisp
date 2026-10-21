; Tips, overtime and car loan interest: Schedule 1-A, Parts II–IV.

(test "tips as an employee are deducted, for a filer with a valid SSN"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s cafe
    (given wages $40,000 medicare-wages $40,000 withheld $0 qualified-tips $8,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s1a/line13 ?)                         ; the tips ask for the SSN
  (given you/tin 'itin)
  (expect f1040s1a/line13 $0)
  (given you/tin 'ssn)
  (expect f1040s1a/line4c $8,000
          f1040s1a/line13 $8,000
          f1040/line13b $8,000
          f1040/line15 $16,250                       ; $40,000 − $15,750 − $8,000
          ; row middle $16,275: $1,192.50 + 12% × ($16,275 − $11,925)
          f1040/line16 $1,715))

(test "both spouses' tips share $25,000, less $100 for each full $1,000 over $300,000"
  (given filing-status 'married-joint you/tin 'ssn spouse/tin 'ssn)
  (member w2s yours
    (given wages $200,000 medicare-wages $200,000 withheld $0 qualified-tips $20,000))
  (member w2s theirs
    (given wages $112,900 medicare-wages $112,900 withheld $0 qualified-tips $10,000
           spouses true))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s1a/line6 $30,000
          f1040s1a/line7 $25,000
          f1040s1a/line10 $12,900
          f1040s1a/line11 12
          f1040s1a/line12 $1,200
          f1040s1a/line13 $23,800)
  ; Only the spouse who received tips needs the SSN.
  (given you/tin 'itin)
  (expect f1040s1a/line4c $10,000
          f1040s1a/line13 $8,800))

(test "overtime premium up to $12,500, or $25,000 on a joint return"
  (given filing-status 'single you/tin 'ssn)
  (member w2s plant
    (given wages $160,500 medicare-wages $160,500 withheld $0 qualified-overtime $14,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s1a/line14a $14,000
          f1040s1a/line15 $12,500
          f1040s1a/line18 $10,500
          f1040s1a/line20 $1,000                     ; 10 × $100
          f1040s1a/line21 $11,500)
  (given filing-status 'married-joint)
  (expect f1040s1a/line15 $14,000
          f1040s1a/line21 $14,000))

(test "married filing separately: no tips or overtime, but car loan interest"
  (given filing-status 'married-separate vehicle-loan true)
  (member w2s cafe
    (given wages $50,000 medicare-wages $50,000 withheld $0
           qualified-tips $5,000 qualified-overtime $2,000))
  (member vehicle-loans truck (given interest $3,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  ; and no SSN asked for
  (expect f1040s1a/line13 $0
          f1040s1a/line21 $0
          f1040s1a/line30 $3,000
          f1040s1a/line38 $3,000))

(test "car loan interest up to $10,000, less $200 for each $1,000 or part over $100,000"
  (given filing-status 'single)
  (member w2s acme (given wages $105,500 medicare-wages $105,500 withheld $0))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040s1a/line23 $0)                        ; no loans asked about
  (given vehicle-loan true)
  (expect f1040s1a/line23 ?)
  (member vehicle-loans truck (given interest $7,000))
  (member vehicle-loans van (given interest $5,000 deducted $1,000))
  (expect f1040s1a/line23 $11,000
          f1040s1a/line24 $10,000
          f1040s1a/line27 $5,500
          f1040s1a/line28 6
          f1040s1a/line29 $1,200
          f1040s1a/line30 $8,800)
  (given filing-status 'married-joint)
  (expect f1040s1a/line30 $10,000))

(test "a business's tips count only up to its profit, and none from a loss"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  ; $400 of profit, so $369.40 of net earnings: no self-employment tax
  (member f1040scs rideshare (given receipts $5,000 car $4,600 qualified-tips $1,800))
  (member f1040scs tutoring (given receipts $1,000 supplies $1,500 qualified-tips $300))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f1040sse/line12 $0
          f1040s1a/line5 $400
          f1040s1a/line13 $400))

(test "and less its share of its owner's deductible self-employment tax"
  (given filing-status 'single you/birth-date 1990-05-01 you/tin 'ssn)
  (member f1040scs consulting (given receipts $40,000))
  (member f1040scs tours (given receipts $50,000 other-expenses $10,000 qualified-tips $38,000))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/business-profit $80,000
          f1040s1/line15 $5,651.82                   ; half of 15.3% × $73,880
          ; half of it for the tours' half of the profit: $40,000 − $2,825.91
          f1040s1a/line5 $37,174.09
          f1040s1a/line7 $25,000
          f1040s1a/line13 $25,000))
