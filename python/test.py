order = 2
disc = {'a':chr(97+order),'b':chr(98+order),'c':chr(99+order),' ':' '}
for i in range(97, 123):
  n = i + order
  if n > 122:
    n -= 26
  disc[chr(i)] = chr(n)

text = 'abc abc z function ord would get the int value of the char nd in case you want to convert back after playing with the number function chr does the trick'
output = ''
for i in text:
  print disc[i]
  output += disc[i]
print output
  

