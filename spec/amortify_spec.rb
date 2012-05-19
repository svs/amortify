require File.join( File.dirname(__FILE__), '..', "spec_helper" )
require 'csv'

# Reads a given csv file and turns it into an array of the form returned by #reducing_schedule
def file_to_expectation(file_name)
  a = CSV.parse(File.read("spec/#{file_name}.csv"))
  i = 1
  h = a.map do |x| 
    _a = [i,{:principal => x[0].to_f, :interest => x[1].to_f}]
    i += 1
    _a
  end
  Hash[*h.flatten]
end

describe Amortify do
  describe "round to_nearest" do
    it "should round correctly" do
      Amortify.round_to_nearest(61.53846153846154, 0.000001, :ceil).should == 61.538462
      Amortify.round_to_nearest(176.802611, 0.000001, :ceil).should == 176.802611
      Amortify.round_to_nearest(26.99692307692308, 1, :floor).should == 26
    end
  end

  describe Amortify::Flat do
    describe "normal operation" do
      before :all do
        @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50)
        @expectation = Hash.send('[]',*((1..50).map{|i| [i, {:principal_payable => 20, :interest_payable => 3.2}]}.flatten))
      end
      
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end
    
    describe "rounding interest up" do
      before :all do
        @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :ceil, :round_interest_to => 1)
        @expectation = Hash.send('[]',*((1..40).map{|i| [i, {:principal_payable => 19.2, :interest_payable => 4}]} + ((41..50).map{|i| [i, {:principal_payable => 23.2, :interest_payable => 0}]})).flatten)
      end

      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

    describe "rounding interest down" do
      before :all do
        @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :floor, :round_interest_to => 1)
        @expectation = Hash.send('[]',*((1..49).map{|i| [i, {:principal_payable => 20.2, :interest_payable => 3}]} + ((50..50).map{|i| [i, {:principal_payable => 10.2, :interest_payable => 13}]})).flatten)
      end

      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

    describe "rounding total up" do
      before :all do
        @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :ceil, :round_total_to => 1)
        @expectation = Hash.send('[]',*((1..48).map{|i| [i, {:principal_payable => 20.8, :interest_payable => 3.2}]} + 
                                        [49, {:principal_payable => 1.6, :interest_payable => 6.4}]).flatten)
      end
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end
      
    describe "rounding total down" do
      describe "without forcing number of installments" do
        before :all do
          @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :floor, :round_total_to => 1)
          @expectation = Hash.send('[]',*((1..50).map{|i| [i, {:principal_payable => 19.8, :interest_payable => 3.2}]} + 
                                        [51, {:principal_payable => 10, :interest_payable => 0}]).flatten)
        end
        it "should return correct cashflow" do
          @result.should == @expectation
        end
      end
      describe "with forcing number of installments" do
        before :all do
          @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :floor, :round_total_to => 1, :force_num_installments => true)
          @expectation = Hash.send('[]',*((1..49).map{|i| [i, {:principal_payable => 19.8, :interest_payable => 3.2}]} + 
                                        [50, {:principal_payable => 29.8, :interest_payable => 3.2}]).flatten)
        end
        it "should return correct cashflow" do
          @result.should == @expectation
        end
      end
    end      

    describe "rounding total up and interest up" do
      before :all do
        @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :ceil, :round_total_to => 1, :round_interest_to => 1)
        @expectation = Hash.send('[]',*((1..40).map{|i| [i, {:principal_payable => 20, :interest_payable => 4}]} + 
                                       (41..48).map{|i| [i, {:principal_payable => 24, :interest_payable => 0}]} + 
                                                       [49, {:principal_payable => 8,  :interest_payable => 0}]).flatten)
      end
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

    describe "rounding total down and interest down" do
      before :all do
        @result = Amortify::Flat.reducing_schedule(:amount => 1000, :interest_rate => 0.16, :number_of_installments => 50, :rounding_style => :ceil, :round_total_to => 1, :round_interest_to => 1)
        @expectation = Hash.send('[]',*((1..40).map{|i| [i, {:principal_payable => 20, :interest_payable => 4}]} + 
                                       (41..48).map{|i| [i, {:principal_payable => 24, :interest_payable => 0}]} + 
                                                       [49, {:principal_payable => 8,  :interest_payable => 0}]).flatten)
      end
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

  end # Flat

  describe Amortify::Equated do
    describe "normal operation" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :installment_frequency => :weekly)
        @expectation = file_to_expectation("equated_normal")
      end
      
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end
    
    describe "rounding interest up" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :ceil, :round_interest_to => 1, :installment_frequency => :weekly, :force_num_installments => false)
        @expectation = file_to_expectation("equated_normal_interest_round_to_1")
        #(1..50).each do |i|
          #puts "#{@expectation[i][:principal]} - #{@result[i][:principal]} = #{@expectation[i][:principal] - @result[i][:principal]}"
        #end
      end

      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

    describe "rounding interest up with force num installments" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :ceil, :round_interest_to => 1, :installment_frequency => :weekly)
        @expectation = file_to_expectation("equated_normal_interest_round_to_1")
      end

      it "should return correct cashflow" do
        @result[0..-2].should == @expectation[0..-3]
      end
    end


    describe "rounding interest down" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :floor, :round_interest_to => 1, :installment_frequency => :weekly)
        @expectation = file_to_expectation("equated_normal_interest_round_down_to_1")
      end

      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

    describe "rounding total up" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :ceil, :round_total_to => 1, :installment_frequency => :weekly)
        @expectation = file_to_expectation("equated_normal_total_round_up_to_1")
      end
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end
      
    describe "rounding total down" do
      describe "with forcing number of installments" do
        before :all do
          @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :floor, :round_total_to => 5, :force_num_installments => true, :installment_frequency => :weekly)
          @expectation = file_to_expectation("equated_normal_round_total_down_force")
        end
        it "should return correct cashflow" do
          @result.should == @expectation
        end
      end
      describe "without forcing number of installments" do
        before :all do
          @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :floor, :round_total_to => 5, :installment_frequency => :weekly, :force_num_installments => false)
          @expectation = file_to_expectation("equated_normal_round_total_down_no_force")
        end
        it "should return correct cashflow" do
          @result.should == @expectation
        end
      end
    end      

    describe "rounding total up and interest up" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :ceil, :round_total_to => 1, :round_interest_to => 1, :installment_frequency => :weekly)
        @expectation = file_to_expectation("equated_normal_round_total_and_int_up")
      end
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end

    describe "rounding total down and interest down" do
      before :all do
        @result = Amortify::Equated.reducing_schedule(:amount => 10000, :interest_rate => 0.32, :number_of_installments => 50, :rounding_style => :floor, :round_total_to => 1, :round_interest_to => 1, :installment_frequency => :weekly)
        @expectation = file_to_expectation("equated_normal_round_total_and_int_down")        
      end
      it "should return correct cashflow" do
        @result.should == @expectation
      end
    end
    
  end
end
