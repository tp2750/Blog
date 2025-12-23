def ranges(numbers):
   diff = None
   for i,j in enumerate(sorted(numbers)):
       if i - j != diff:
           if diff is not None:
               yield first,last
           first = j
           diff = i -j
       last = j
   if diff is not None:
       yield first,last

def list_to_ranges(numbers):
   sorted_numbers = sorted(numbers)
   start = prev = sorted_numbers.pop(0)  # first interval
   for number in sorted_numbers:
       if number == prev + 1:  # belongs to same interval
           prev = number       # update end
           continue
       else:
           yield start, prev      # interval ended
           start = prev = number  # start new
   yield start, prev  # last interval

import random
v1 = [random.choice(range(1,999)) for _ in range(2000)]

timeit.timeit('list(list_to_ranges(v1))',globals=globals(), number=10)
timeit.timeit('list(ranges(v1))',globals=globals(), number=10)


# >>> timeit.timeit('list(list_to_ranges(v1))',globals=globals(), number=1)
# 0.00029139300022507086
# >>> timeit.timeit('list(ranges(v1))',globals=globals(), number=1)
# 0.0003507130004436476
