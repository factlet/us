; Self-employment: Schedule SE, and self-employment income as earned income.

(test "self-employment tax is 15.3% of 92.35% of the profit, half of it deducted"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member f1040scs consulting (given receipts $40,000))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f1040sse/line4a $36,940
          you/f1040sse/line10 $4,580.56              ; 12.4%
          you/f1040sse/line11 $1,071.26              ; 2.9%
          f1040s2/line4 $5,651.82
          f1040s1/line15 $2,825.91
          f1040/line11a $37,174.09
          ; Form 8995: 20% of the $37,174.09 of qualified business income,
          ; but no more than 20% of the $21,424.09 taxable before it
          f1040/line13a $4,284.818
          f1040/line15 $17,139.272
          ; row middle $17,125: $1,192.50 + 12% × ($17,125 − $11,925)
          f1040/line16 $1,817
          f1040/line24 $7,468.82
          f1040/line37 $7,468.82))

(test "the 12.4% stops where wages and self-employment reach $176,100"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme
    (given wages $150,000 medicare-wages $150,000 withheld $0 ss-wages $150,000))
  (member f1040scs consulting (given receipts $40,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f1040sse/line9 $26,100
          you/f1040sse/line10 $3,236.40              ; 12.4% × $26,100
          you/f1040sse/line12 $4,307.66
          f1040s1/line15 $2,153.83))

(test "under $400 of net earnings, no self-employment tax, nor questions for it"
  (given filing-status 'single you/birth-date 1990-05-01)
  ; No social security wages asked.
  (member w2s acme (given wages $30,000 medicare-wages $30,000 withheld $0))
  (member f1040scs side (given receipts $400))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f1040sse/line4c $369.40
          you/f1040sse/required false
          f1040s2/line4 $0))

(test "statutory employee income is income and earned income, but not self-employment"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member f1040scs route (given receipts $30,000 statutory-employee true))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect f1040s1/line3 $30,000
          you/f1040sse/line2 $0
          f1040s2/line4 $0
          f1040-eic-b/line3 $30,000
          f1040-eic/line1 $30,000))

(test "each spouse figures their own, against their own wages"
  (given filing-status 'married-joint
         you/birth-date 1985-01-01 spouse/birth-date 1987-01-01)
  (member w2s acme
    (given wages $150,000 medicare-wages $150,000 withheld $0 ss-wages $150,000))
  (member f1040scs yours (given receipts $40,000))
  (member f1040scs theirs (given receipts $80,000 spouses true))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect you/f1040sse/line12 $4,307.66              ; past the wage base
          spouse/f1040sse/line9 $176,100             ; none of it used
          spouse/f1040sse/line12 $11,303.64          ; 15.3% × $73,880
          f1040s2/line4 $15,611.30
          f1040s1/line15 $7,805.65))

(test "self-employment is earned income for the EIC and the additional child tax credit"
  (given filing-status 'head-of-household you/birth-date 1990-05-01 you/tin 'ssn)
  (member f1040scs consulting (given receipts $40,000))
  (member dependents kid (given birth-date 2018-01-01 qualifying-child true tin 'ssn))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s)
  ; Worksheet B: the Schedule SE profit less the half deducted.
  (expect f1040-eic/line1 $37,174.09
          ; row middle $37,175: $4,328 − 15.98% × ($37,175 − $23,350)
          f1040/line27a $2,119
          ; less 20% of the $13,549.09 taxable before the QBI deduction
          f1040/line13a $2,709.818
          ; tax $1,083 (row middle $10,825) takes $1,083 of the $2,200 credit
          f1040s8/line17 $1,117
          f1040/line28 $1,117
          f1040/line24 $5,651.82                     ; self-employment tax only
          f1040/line37 $2,415.82))

(test "self-employment is compensation for the IRA deduction"
  (given filing-status 'single you/birth-date 1990-05-01 you/ira-contributions $7,000)
  (member f1040scs consulting (given receipts $40,000))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s dependents)
  (expect f1040s1-ira/line9 $37,174.09              ; less the half deducted
          f1040s1/line20 $7,000))
