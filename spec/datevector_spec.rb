require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe DateVector do

  it "should give correct results for Date monkey-patched functions" do
    d = Date.new(2010,1,1)
    d.next_(:friday).should == Date.new(2010,1,8)
    d.next_(:monday).should == Date.new(2010,1,4)
    d.next_(:monday, 2).should == Date.new(2010,1,11)
  end
  
  it "should return correct dates for weekly dates" do
    dv = DateVector.new(1, :friday, 1, :week, Date.new(2010,1,1), Date.new(2010,12,31)) # every friday
    jan_1_2010           =  Date.new(2010,1,1) # is a friday btw
    first_friday_of_2010 =  jan_1_2010
    d = first_friday_of_2010
    all_fridays_of_2010  =  [d]
    while d <= Date.new(2010,12,31)
      d += 7
      all_fridays_of_2010 << d if d.year == 2010
    end
    dv.get_dates.should == all_fridays_of_2010

    dv.get_dates(Date.new(2010,2,14)).should == all_fridays_of_2010.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,2,14), Date.new(2010,6,24)).should == all_fridays_of_2010.select{|d| d >= Date.new(2010,2,14) and d <= Date.new(2010,6,24)}


    dv = DateVector.new(1, :thursday, 1, :week, Date.new(2010,1,1), Date.new(2010,12,31)) # every thursday
    jan_1_2010           =  Date.new(2010,1,1)
    first_thursday_of_2010 =  jan_1_2010 + 6
    d = first_thursday_of_2010
    all_thursdays_of_2010  =  [d]
    while d <= Date.new(2010,12,31)
      d += 7
      all_thursdays_of_2010 << d if d.year == 2010
    end
    dv.get_dates.should == all_thursdays_of_2010

    dv.get_dates(Date.new(2010,2,14)).should == all_thursdays_of_2010.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,2,14), Date.new(2010,6,24)).should == all_thursdays_of_2010.select{|d| d >= Date.new(2010,2,14) and d <= Date.new(2010,6,24)}

    

  end

  it "should return correct dates for biweekly dates" do
    dv = DateVector.new(1, :friday, 2, :week, Date.new(2010,1,1), Date.new(2010,12,31)) # every second friday
    jan_1_2010           =  Date.new(2010,1,1) # is a friday btw
    first_friday_of_2010 =  jan_1_2010
    d = first_friday_of_2010
    all_fridays_of_2010  =  [d]
    while d <= Date.new(2010,12,31)
      d += 14
      all_fridays_of_2010 << d if d.year == 2010
    end
    dv.get_dates.should == all_fridays_of_2010

    dv.get_dates(Date.new(2010,2,14)).should == all_fridays_of_2010.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,2,14), Date.new(2010,6,24)).should == all_fridays_of_2010.select{|d| d >= Date.new(2010,2,14) and d <= Date.new(2010,6,24)}

    dv = DateVector.new(1, :thursday, 2, :week, Date.new(2010,1,1), Date.new(2010,12,31)) # every thursday
    jan_1_2010           =  Date.new(2010,1,1)
    first_thursday_of_2010 =  jan_1_2010 + 6
    d = first_thursday_of_2010
    all_thursdays_of_2010  =  [d]
    while d <= Date.new(2010,12,31)
      d += 14
      all_thursdays_of_2010 << d if d.year == 2010
    end
    dv.get_dates.should == all_thursdays_of_2010

    dv.get_dates(Date.new(2010,2,14)).should == all_thursdays_of_2010.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,2,14), Date.new(2010,6,24)).should == all_thursdays_of_2010.select{|d| d >= Date.new(2010,2,14) and d <= Date.new(2010,6,24)}
  end

  it "should return correct dates for monthly datevectors" do
    dv = DateVector.new(12, :day, 1, :month, Date.new(2010,1,1), Date.new(2010,12,31)) # 12th of every month
    ev = (0..11).map{|d| Date.new(2010,1,12) >> d}
    dv.get_dates.should == ev
    dv.get_dates(Date.new(2010,2,14)).should == ev.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,3,12), Date.new(2010,6,24)).should == ev.select{|d| d >= Date.new(2010,3,12) and d <= Date.new(2010,6,24)}

    dv = DateVector.new([12,27], :day, 1, :month, Date.new(2010,1,1), Date.new(2010,12,31)) # 12th and 27th of every month
    ev = ((0..11).map{|d| Date.new(2010,1,12) >> d} + (0..11).map{|d| Date.new(2010,1,27) >> d}).sort
    dv.get_dates.should == ev
    dv.get_dates(Date.new(2010,2,14)).should == ev.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,3,12), Date.new(2010,6,24)).should == ev.select{|d| d >= Date.new(2010,3,12) and d <= Date.new(2010,6,24)}
  end

  it "should return correct dates for multi-monthly datevectors" do
    dv = DateVector.new(12, :day, 3, :month, Date.new(2010,1,1), Date.new(2010,12,31)) # 12th of every 3rd month
    ev = (0..3).map{|d| Date.new(2010,1,12) >> d*3}
    dv.get_dates.should == ev
    dv.get_dates(Date.new(2010,2,14)).should == ev.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,3,12), Date.new(2010,6,24)).should == ev.select{|d| d >= Date.new(2010,3,12) and d <= Date.new(2010,6,24)}

    dv = DateVector.new([12,27], :day, 3, :month, Date.new(2010,1,1), Date.new(2010,12,31)) # 12th and 27th of every 3rd month
    ev = ((0..3).map{|d| Date.new(2010,1,12) >> d*3} + (0..3).map{|d| Date.new(2010,1,27) >> d*3}).sort
    dv.get_dates.should == ev
    dv.get_dates(Date.new(2010,2,14)).should == ev.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,3,12), Date.new(2010,6,24)).should == ev.select{|d| d >= Date.new(2010,3,12) and d <= Date.new(2010,6,24)}
  end

  it "should return correct dates for 'every 2nd and 4th friday' kind of datevectors" do
    dv = DateVector.new([2,4], :friday, 1, :month, Date.new(2010,1,1), Date.new(2010,12,31)) # 2nd and 4th friday of every month
    ev = ["2010-01-08","2010-01-22","2010-2-12","2010-2-26","2010-3-12","2010-3-26","2010-4-9","2010-4-23","2010-5-14","2010-5-28",
          "2010-6-11","2010-6-25","2010-7-9","2010-7-23","2010-8-13","2010-8-27","2010-9-10","2010-9-24","2010-10-8","2010-10-22",
          "2010-11-12","2010-11-26","2010-12-10","2010-12-24"].map{|d| Date.parse(d)}
    dv.get_dates.should == ev
    dv.get_dates(Date.new(2010,2,14)).should == ev.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,3,12), Date.new(2010,6,24)).should == ev.select{|d| d >= Date.new(2010,3,12) and d <= Date.new(2010,6,24)}

    dv = DateVector.new([2,4], :saturday, 1, :month, Date.new(2010,1,1), Date.new(2010,12,31)) # 2nd and 4th friday of every month
    ev = (ev.map{|d| d + 1}.reject{|d| d.month == 5} + ["2010-5-8","2010-5-22"].map{|d| Date.parse(d)}).sort
    dv.get_dates.should == ev
    dv.get_dates(Date.new(2010,2,14)).should == ev.select{|d| d >= Date.new(2010,2,14)}
    dv.get_dates(Date.new(2010,3,12), Date.new(2010,6,24)).should == ev.select{|d| d >= Date.new(2010,3,12) and d <= Date.new(2010,6,24)}

    # some more corner cases can certainly be tested here

  end
  

end
