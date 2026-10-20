; Retirement income: IRA distributions, pensions and annuities (Form 1099-R).

(test "a pension and an IRA distribution, each on its own line"
  (given filing-status 'single you/birth-date 1955-06-01 you/tin 'ssn)
  (member f1099-rs pension (given gross $30,000 taxable $28,000 withheld $3,000))
  (member f1099-rs ira (given gross $10,000 taxable $10,000 withheld $1,000 ira true))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line4a $10,000
          f1040/line4b $10,000
          f1040/line5a $30,000
          f1040/line5b $28,000
          f1040/line11a $38,000
          f1040/line15 $14,250                       ; − $17,750 − $6,000 for a senior
          ; row middle $14,275: $1,192.50 + 12% × ($14,275 − $11,925)
          f1040/line16 $1,475
          f1040/line25b $4,000
          f1040/line34 $2,525))

(test "what you roll over within 60 days isn't taxed"
  (given filing-status 'single you/birth-date 1980-01-01)
  (member f1099-rs all (given gross $20,000 taxable $20,000 ira true rolled-over $20,000))
  (member f1099-rs part (given gross $5,000 taxable $5,000 ira true rolled-over $3,000))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line4a $25,000
          f1040/line4b $2,000
          f1040/line9 $2,000))

(test "an early distribution owes 10% more, unless it was rolled over"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $5,000))
  (member f1099-rs plan (given gross $10,000 taxable $10,000 withheld $2,000 early true))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line5b $10,000
          f1040/line15 $44,250
          ; row middle $44,275: $1,192.50 + 12% × ($44,275 − $11,925)
          f1040/line16 $5,075
          f1040s2/line8 $1,000
          f1040/line23 $1,000
          f1040/line24 $6,075
          f1040/line34 $925)
  (member f1099-rs rollover
    (given gross $4,000 taxable $4,000 early true rolled-over $4,000))
  (expect f1040/line5a $14,000
          f1040s2/line8 $1,000))

(test "pensions count toward the social security base amount"
  (given filing-status 'single you/birth-date 1955-06-01 you/tin 'ssn)
  (member ssa1099s you (given net-benefits $20,000))
  (member f1099-rs pension (given gross $25,000 taxable $25,000))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1098-es f1040scs dependents)
  (expect f1040-ssb/line5 $35,000                    ; $10,000 + $25,000
          f1040-ssb/line14 $4,500                    ; half of $9,000
          f1040-ssb/line15 $850                      ; 85% × $1,000
          f1040/line6b $5,350
          f1040/line11a $30,350))
