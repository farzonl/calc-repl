# Calc-repl
A calculator reple with multi-type (int, float, & boolean) support, conditional exection, and assignment.

## Demo
coming soon...

## Dependencies
- flex
- bison
### install instructions mac
```
brew install flex bison
```
## Build instructions
```
make
```
## Run instructions
```
./calc
```

## expression examples:
### Assignment
```
a = 1
b = 2.2
c = true
d = false
```
### Integer Expressions
```
a = 1
1 + a * 3 - 2
c = a * 3 + 4
```
### Mixed Expressions
```
a = 1
b = 1.1 + a
c = 1.1 + 1
1 + 1.1
1.1 + 1 / 2
```
### Boolean expressions
```
true
!true
true == !false
a = false
true == a
a = 1==1.0
```
### Conditional expressions
```
a = false
if(a) {f = 1}
if(!a) {f = 1} else { f = 2}
if(!a) { 1 + 2 * 3} else { f = 2 * 4}
```