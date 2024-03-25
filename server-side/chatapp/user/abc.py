import random

def flipcoin2():
    result=random.randint(0,1)
    if result % 2==0:
        print("Head")
    else:
        print('Tail')

flipcoin2()