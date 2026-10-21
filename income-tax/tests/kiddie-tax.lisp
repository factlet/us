; The kiddie tax: Form 8615, for you as the child.

(test "a child's unearned income over $2,700 is taxed at the parent's rate"
  (given you/birth-date 2013-03-01 claimed-as-dependent true
         parent-filing-status 'married-joint parent-taxable-income $150,000 parent-tax $22,828)
  (member f1099-ints bank (given interest $10,000))
  (empty w2s f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040/line15 $8,650                        ; less the $1,350 standard deduction
          f8615/line1 $10,000
          f8615/line3 $7,300
          f8615/line5 $7,300
          ; $2,385 + $8,772 + 22% × ($157,300 − $96,950)
          f8615/line9 $24,434
          f8615/line11 $1,606                        ; 22% × $7,300
          ; row middle $1,362.50
          f8615/line15 $136
          f8615/line16 $1,742
          ; row middle $8,675, at the child's own rate
          f8615/line17 $868
          f1040/line16 $1,742))

(test "under 18, or 18 or a student under 24 supported like a dependent, with a parent alive"
  (given you/birth-date 2008-01-02 claimed-as-dependent true)
  (member f1099-ints bank (given interest $10,000))
  (empty w2s f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8615/age 17 f8615/applies true)
  ; A birthday counts a day early.
  (given you/birth-date 2008-01-01)
  (expect f8615/age 18 f8615/applies false)
  (given supported true)
  (expect f8615/applies true)
  (given parents-deceased true)
  (expect f8615/applies false)
  (given parents-deceased false you/birth-date 2002-06-01)
  (expect f8615/age 23 f8615/applies false)
  (given you/full-time-student true)
  (expect f8615/applies true)
  (given you/birth-date 2002-01-01)
  (expect f8615/age 24 f8615/applies false))

(test "not for $2,700 of unearned income, nor a child filing jointly"
  (given you/birth-date 2015-01-01 claimed-as-dependent true)
  (member f1099-ints bank (given interest $2,700))
  (empty w2s f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8615/line3 $0 f8615/applies false)
  (given married true)
  (expect f8615/applies false))

(test "qualified dividends keep their rate, less their share of the $2,700 (Line 5 Worksheet #1)"
  (given you/birth-date 2010-01-01 claimed-as-dependent true
         parent-filing-status 'married-joint parent-taxable-income $150,000 parent-tax $22,828)
  (member f1099-divs fund (given ordinary $6,000 qualified $6,000))
  (member f1099-ints bank (given interest $4,000))
  (empty w2s f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8615-ws1/line4 0.6
          f8615-ws1/line8 $4,380                     ; $6,000 − 0.6 × $2,700
          ; 15% × $4,380 + $23,470 on $152,920 of ordinary income
          f8615/line9 $24,127
          f8615/line11 $1,299
          ; the other $1,620 of dividends, all of line 14, at 0%
          f8615/line15 $0
          f8615/line17 $266                          ; row middle $2,662.50
          f1040/line16 $1,299))

(test "taxable income less than unearned income shares the deduction (Line 5 Worksheet #3)"
  ; Not a dependent, so the full standard deduction.
  (given you/birth-date 2010-01-01
         parent-filing-status 'single parent-taxable-income $80,000 parent-tax $12,520)
  (member f1099-divs fund (given ordinary $10,000 qualified $10,000))
  (member f1099-ints bank (given interest $10,000))
  (empty w2s f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8615/line3 $17,300
          f8615/line5 $4,250                         ; $20,000 − $15,750
          ; half the deduction against the dividends: $10,000 − $7,875
          f8615-ws3/line18 $2,125
          ; 15% × $2,125 + $12,982 on $82,125, rounded
          f8615/line9 $13,301
          f8615/line13 $781
          f8615/line17 $0                            ; the child's own: all at 0%
          f1040/line16 $781))

(test "other children's net unearned income shares the tentative tax"
  (given you/birth-date 2013-03-01 claimed-as-dependent true
         parent-filing-status 'married-joint parent-taxable-income $150,000 parent-tax $22,828
         other-children-unearned $7,300)
  (member f1099-ints bank (given interest $10,000))
  (empty w2s f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8615/line8 $164,600
          f8615/line11 $3,212                        ; 22% × $14,600
          f8615/line12b 0.5
          f8615/line13 $1,606
          f1040/line16 $1,742))
