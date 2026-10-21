; Business income: Schedule C.

(test "a business's profit is its receipts less its expenses"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member f1040scs consulting
    (given receipts $60,000 advertising $1,000 car $3,000 supplies $2,000 meals $500)
    (expect line28 $6,500 line31 $53,500))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f1040s1/line3 $53,500
          f1040/line8 $53,500
          f1040/line9 $53,500))

(test "cost of goods sold comes off before the expenses"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member f1040scs shop
    (given receipts $100,000 returns $2,000 other-income $500
           opening-inventory $10,000 purchases $50,000 closing-inventory $15,000
           rent-property $12,000 utilities $3,000)
    (expect line42 $45,000
            line5 $53,000                            ; $98,000 − $45,000
            line7 $53,500
            line31 $38,500))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f1040s1/line3 $38,500))

(test "a home office by the simplified method: $5 a square foot, up to 300, up to the profit"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member f1040scs studio (given receipts $20,000 home-office 400)
    (expect line30 $1,500 line31 $18,500))
  (member f1040scs side (given receipts $1,000 home-office 250)
    (expect line30 $1,000 line31 $0))               ; not the $1,250
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f1040s1/line3 $18,500))

(test "a loss offsets other income"
  (given filing-status 'single you/birth-date 1990-05-01)
  (member w2s acme (given wages $50,000 medicare-wages $50,000 withheld $0))
  (member f1040scs startup (given receipts $5,000 other-expenses $8,000))
  (empty f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f1040s1/line3 -$3,000
          f1040/line9 $47,000))

(test "on a joint return, each spouse's businesses add up"
  (given filing-status 'married-joint
         you/birth-date 1985-01-01 spouse/birth-date 1987-01-01)
  (member f1040scs yours (given receipts $30,000))
  (member f1040scs theirs (given receipts $20,000 supplies $5,000 spouses true))
  (empty w2s f1099-ints f1099-divs f1099-bs f1099-gs f1099-rs f1098-es ssa1099s people)
  (expect f1040s1/line3 $45,000))
