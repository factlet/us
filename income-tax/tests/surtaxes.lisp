; The Additional Medicare Tax (Form 8959) and the net investment income tax
; (Form 8960).

(test "0.9% more on Medicare wages over $200,000, and the employer withholds it"
  (given you/birth-date 1990-05-01)
  ; 1.45% × $250,000 + 0.9% × ($250,000 − $200,000)
  (member w2s acme
    (given wages $250,000 medicare-wages $250,000 withheld $50,000 medicare-withheld $4,075))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8959/line6 $50,000
          f1040s2/line11 $450
          f8959/line22 $450                          ; past the regular $3,625
          f1040/line25c $450))

(test "two jobs under $200,000 each owe it together, with nothing withheld"
  (given you/birth-date 1990-05-01)
  ; Neither W-2 is past $200,000, so neither is asked for box 6.
  (member w2s acme (given wages $150,000 medicare-wages $150,000 withheld $30,000))
  (member w2s globex (given wages $100,000 medicare-wages $100,000 withheld $20,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f1040s2/line11 $450
          f1040/line25c $0))

(test "the threshold is $250,000 on a joint return, $125,000 on a separate one"
  (given married true)
  (member w2s yours (given wages $180,000 medicare-wages $180,000 withheld $0))
  (member w2s theirs (given wages $120,000 medicare-wages $120,000 withheld $0 spouses true))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8959/line6 $50,000 f1040s2/line11 $450)
  (given married true files-separately true)
  (expect f8959/line6 $175,000))

(test "self-employment income owes it past what wages leave of the threshold"
  (given you/birth-date 1990-05-01)
  (member w2s acme
    (given wages $150,000 medicare-wages $150,000 ss-wages $150,000 withheld $0))
  (member f1040scs consulting (given receipts $120,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f8959/line8 $110,820                       ; 92.35% × $120,000
          f8959/line11 $50,000
          f8959/line13 $547.38                       ; 0.9% × $60,820
          f1040s2/line11 $547.38))

(test "3.8% of net investment income, or of AGI over the threshold if less"
  (given you/birth-date 1990-05-01)
  (member w2s acme (given wages $200,000 medicare-wages $200,000 withheld $0))
  (member f1099-ints bank (given interest $60,000))
  (empty f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8960/line12 $60,000
          f8960/line15 $60,000
          f1040s2/line12 $2,280)
  ; A joint return, or a qualifying surviving spouse, starts at $250,000.
  (given married true)
  (expect f8960/line15 $10,000 f1040s2/line12 $380)
  (given married true files-separately true)
  (expect f8960/line15 $135,000 f1040s2/line12 $2,280))

(test "dividends and capital gain distributions are investment income too"
  (given you/birth-date 1990-05-01)
  (member w2s acme
    (given wages $220,000 medicare-wages $220,000 withheld $0 medicare-withheld $3,370))
  (member f1099-ints bank (given interest $30,000))
  (member f1099-divs fund (given ordinary $20,000 qualified $10,000 cap-gain $5,000))
  (empty f1099-bs f1099-gs f1099-rs f1098-es ssa1099s f1040scs people)
  (expect f8960/line8 $55,000
          f1040/line11a $275,000
          f1040s2/line12 $2,090                      ; 3.8% × $55,000
          f1040s2/line11 $180                        ; 0.9% × $20,000
          f1040/line25c $180))
