; Capital gains and losses: Form 8949 and Schedule D.

(test "short-term gains are taxed as ordinary income, long-term ones at their own rates"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $5,000))
  (member f1099-bs a (given proceeds $10,000 cost $8,000 long-term false withheld $240))
  (member f1099-bs b (given proceeds $20,000 cost $12,000 long-term true))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040sd/line7 $2,000
          f1040sd/line15 $8,000
          f1040/line7a $10,000
          f1040/line15 $44,250
          f1040-qdcg/line9 $8,000                    ; all of it at 0%
          ; tax on the $36,250 left: row middle $36,275
          f1040/line16 $4,115
          f1040/line25b $240))

(test "a net loss comes off other income up to $3,000, or $1,500 on a separate return"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (member f1099-bs a (given proceeds $5,000 cost $15,000 long-term true))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040sd/line16 -$10,000
          f1040sd/line21 -$3,000
          f1040/line7a -$3,000
          f1040/line9 $47,000)
  (given filing-status 'married-separate)
  (expect f1040/line7a -$1,500))

(test "last year's losses carry over against this year's gains"
  (given filing-status 'single you/birth-date 1990-05-01
         st-loss-carryover $2,000 lt-loss-carryover $1,000)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (member f1099-bs a (given proceeds $15,000 cost $10,000 long-term false))
  (member f1099-divs fund (given ordinary $0 cap-gain $4,000))
  (empty f1099-ints f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040sd/line7 $3,000                       ; $5,000 − $2,000
          f1040sd/line15 $3,000                      ; $4,000 − $1,000
          f1040/line7a $6,000
          f1040-qdcg/line3 $3,000))

(test "a wash sale's disallowed loss is added back"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (member f1099-bs a (given proceeds $9,000 cost $10,000 adjustment $600 long-term false)
    (expect gain -$400))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040/line7a -$400))

(test "a short-term loss nets against long-term gain before the lower rates"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (member f1099-bs a (given proceeds $5,000 cost $10,000 long-term false))
  (member f1099-bs b (given proceeds $18,000 cost $10,000 long-term true))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f1040sd/line16 $3,000
          f1040-qdcg/line3 $3,000))                  ; not the $8,000 long-term

(test "capital gains are net investment income"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (member f1099-bs a (given proceeds $80,000 cost $30,000 long-term true))
  (empty f1099-ints f1099-divs f1099-gs f1099-rs f1098-es ssa1099s f1040scs dependents)
  (expect f8960/line5a $50,000
          f1040s2/line12 $1,900))                    ; 3.8% × $50,000
