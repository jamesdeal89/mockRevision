# AQA A-Level CS Paper 1 - Q7
def harshad(inputval):
    sum = 0
    for digit in inputval:
        sum += int(digit)
    if int(inputval) % sum == 0:
        return True
    else:
        return False

index = int(input("What harshad number?:"))
number = 1
count = 0
while True:
    if harshad(str(number)):
        count += 1
    if count == index and harshad(str(number)):
        print(number)
        break
    number += 1
