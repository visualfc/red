REBOL [
  Title:   "Generates Red/System float! tests"
	Author:  "Peter W A Wood"
	File: 	 %make-float32-auto-test.r
	Version: 0.1.0
	Rights:  "Copyright (C) 2012 Peter W A Wood. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

;; initialisations 
tests: copy ""                          ;; string to hold generated tests
test-number: 0                          ;; number of the generated test
make-dir %auto-tests/
file-out: %auto-tests/float32-auto-test.reds

;; create a block of values to be used in the binary ops tests
test-values: [
            0.0                   
     -2147483.0                   
      2147483.0
           -1.0
            3.0
           -7.0
            5.0
          456.7890
       123456.7
            1.222944E+32
            9.99999E-7
            7.7E18
]

tol: 1e-6   

;; create blocks of operators to be applied
test-binary-ops: [
  +
  -
  *
  /
]

test-comparison-ops: [
  =
  <>
  <
  >
  >=
  <=
]

test-comparison-values: [        ;; these are relative not absolute
  -1E-6
  0.0
  +1E-6
]
   

;; create test file with header
append tests "Red/System [^(0A)"
append tests {  Title:   "Red/System auto-generated float! tests"^(0A)}
append tests {	Author:  "Peter W A Wood"^(0A)}
append tests {  File: 	 %floa32-auto-test.reds^(0A)}
append tests {  License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"^(0A)}
append tests "]^(0A)^(0A)"
append tests "^(0A)^(0A)comment {"
append tests "  This file is generated by make-float32-auto-test.r^(0A)"
append tests "  Do not edit this file directly.^(0A)"
append tests "}^(0A)^(0A)"
append tests join ";make-length:" 
                  [length? read %make-float32-auto-test.r "^(0A)^(0A)"]
append tests "#include %../../../../../quick-test/quick-test.reds^(0A)^(0A)"
append tests {~~~start-file~~~ "Auto-generated tests for float32"^(0A)^(0A)}
append tests {===start-group=== "Auto-generated tests for float32"^(0A)^(0A)}

write file-out tests
tests: copy ""

;; binary operator tests - in global context
foreach op test-binary-ops [
  foreach operand1 test-values [
    foreach operand2 test-values [
      ;; only write a test if REBOL produces a result
      if all [
        attempt [expected: to decimal! do reduce [operand1 op operand2]]
        expected < 3.3E38
        expected > 0.2E-37
      ][
       
        ;; test with literal values
        test-number: test-number + 1
        append tests join {  --test-- "float-auto-} [test-number {"^(0A)}]
        append tests "  --assertf32~= "
        append tests reform [
          "as float32! " expected " ((" "as float32! " operand1 ")"
          op "( as float32! " operand2 ") ) " "as float32! " tol "^(0A)"    
        ]
        
        ;; test with variables
        test-number: test-number + 1
        append tests join {  --test-- "float-auto-} [test-number {"^(0A)}]
        append tests join "      i: " ["as float32! " operand1 "^(0A)"]
        append tests join "      j: " ["as float32! " operand2 "^(0A)"]
        append tests rejoin ["      k:  i " op " j^(0A)"]
        append tests "  --assertf32~= "
        append tests reform ["as float32! " expected " k " "as float32! " tol "^(0A)"]
        ;; write tests to file
        write/append file-out tests
        tests: copy ""
      ]
      recycle
    ]
  ]
]

;; binary operator tests - inside a function

;; write function spec
tests: {
float-auto-test-func: func [
  /local
    i [float32!]
    j [float32!]
    k [float32!]
][
}

write/append file-out tests
tests: copy ""

foreach op test-binary-ops [
  foreach operand1 test-values [
    foreach operand2 test-values [
      ;; only write a test if REBOL produces a result
      if all [
        attempt [expected: to decimal! do reduce [operand1 op operand2]]
        expected < 3.3E38
        expected > 0.2E-37
      ][
        
        ;; test with variables inside the function
        test-number: test-number + 1
        append tests join {    --test-- "float-auto-} [test-number {"^(0A)}]
        append tests join "      i: " ["as float32! " operand1 "^(0A)"]
        append tests join "      j: " ["as float32! " operand2 "^(0A)"]
        append tests rejoin ["      k:  i " op " j^(0A)"]
        append tests "    --assertf32~= "
        append tests reform ["as float32! " expected " k " "as float32! " tol "^(0A)"]
        
        
        ;; write tests to file
        write/append file-out tests
        tests: copy "" 
      ]
      recycle
    ]
  ]
]

;; write closing bracket and function call
append tests "  ]^(0a)"
append tests "float-auto-test-func^(0a)"
write/append file-out tests
tests: copy ""


;; comparison tests
foreach op test-comparison-ops [
  foreach operand1 test-values [
    foreach oper2 test-comparison-values [
      ;; only write a test if REBOL produces a result
      if all [
        attempt [operand2: operand1 + (operand1 * oper2)] 
        oper2 < 3.3E+38
        oper2 > 0.2E-37
        attempt [expected: do reduce [operand1 op operand2]]
      ][
        test-number: test-number + 1
        append tests join {  --test-- "float-auto-} [test-number {"^(0A)}]
        append tests "  --assert "
        append tests reform [
          expected " = (" "(as float32! " operand1 ")" op 
          "(as float32! " operand2 ") )^(0A)"
        ]

        ;; write tests to file
        write/append file-out tests
        tests: copy ""
      ]
    ]
  ]
]


;; write file epilog
append tests "^(0A)===end-group===^(0A)^(0A)"
append tests {~~~end-file~~~^(0A)^(0A)}

write/append file-out tests
      
print ["Number of assertions generated" test-number]

