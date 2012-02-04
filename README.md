# DateVector Gem
DateVector gies you the ability to generate lists of dates matching a particular pattern, i.e. every friday, every 3rd friday, every 2nd and 17th of every 2nd month and so on.

## Usage

`DateVector.new` takes 6 arguments. They are

```
every		=> an Integer or array of Integers
what		=> a Symbol. one of :day, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
of_every	=> an Integer
period		=> :week or :month
start_date      => a Date
end_date        => a Date
```

## Examples
```
d1 = Date.today; d2 = d1 + 365
dv1 = DateVector.new(1,:friday, 1, :week, d1, d2)	# every friday
dv2 = DateVector.new(1,:friday, 2, :week, d1, d2)	# every 2nd friday
dv3 = DateVector.new(15,:day, 1, month, d1, d2)		# 15th of every month
dv4 = DateVector.new([7,22],:day, 1, month, d1, d2)	# 7th and 22nd of every month
dv5 = DateVector.new([7,22],:day, 3, month, d1, d2)	# 7th and 22nd of every 3 months
dv6 = DateVector.new([2,4],:friday, 1, :month, d1, d2)	# every 2nd and 4th friday of every month

all_dates = dv1.get_dates        #gets all dates specified
some_dates = dv1(d1+30, d2-30)   # gets dates between dates specified
```




