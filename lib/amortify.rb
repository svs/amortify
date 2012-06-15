module Amortify
  # Calculates amortisation schedules in various scenarios. For the moment we support
  # * Flat
  # * Equated
  # * Bullet (with and without periodic interest)
  # * Custom Principal (and Interest)

  # Each submodule must implement a function called #reducing_schedule which returns the appropriate cashflow

  DIVIDER = {:weekly => 52, :biweekly => 26, :monthly => 12}

  def self.pmt(interest, installments, present_value, future_value, paid_before=1)
    vPow = (1 + interest) ** installments
    actual_interest_rate = (paid_before == 0 ? interest : interest/(1 + interest))
    (vPow * present_value - future_value)/(vPow - 1) * actual_interest_rate
  end

  def self.round_to_nearest(number, i = nil, style = :round)
    return number if i.nil?
    return number unless number.respond_to?(style)
    rounder = (-(Math.log(i) / Math.log(10)).round(0)) if i < 0.01
    n = i < 0.01 ? ((number / i).round(2).send(style) * i) : ((number/i).send(style) * i)
    rounder ? n.round(rounder) : n
  end



  module Flat
    
    # Flat repayment style gives us equal principal and interest amounts in each period
    # for a Rs. 10,000 loan at 15% flat payment over 50 weekly instalments, we should get
    # in each period Rs. 200 as principal and Rs. 30 as interest

    # options is a Hash with the following keys
    # amount
    # number_of_installments
    # interest rate
    # round_interest_to      -> Optional. A Numeric signifying a multiple to round the interest component to.
    # round_principal_to     -> Optional. A Numeric signifying a multiple to round the principal component to.
    # round_total_to         -> Optional. A Numeric signifying a multiple to round the total payment_to
    # rounding_style         -> Optional. Either of :round, :ceil or :floor
    # force_num_installments -> Optional. When true, will not let the schedule extend due to rounding down.
    def self.reducing_schedule(options)
      # someone please give ruby some named arguments!!
      options = {:round_interest_to => 0.01, :round_principal_to => 0.01, :rounding_style => :round, :round_total_to => 0.01}.merge(options)

      amount = options[:amount]; number_of_installments = options[:number_of_installments]; interest_rate = options[:interest_rate]
      round_interest_to = options[:round_interest_to]; round_principal_to = options[:round_principal_to]; round_total_to = options[:round_total_to]; 
      rounding_style = options[:rounding_style]; force_num_installments = options[:force_num_installments]

      # initialize stuff
      @_reducing_schedule  = {}    
      balance              = amount
      total_int_payable    = amount * interest_rate
      total_amount_payable = amount + total_int_payable
      equated_payment      = (Amortify.round_to_nearest (total_amount_payable / number_of_installments), round_total_to,    rounding_style)
      interest_calculation = (Amortify.round_to_nearest (total_int_payable    / number_of_installments), round_interest_to, rounding_style)
      total_int_paid       = 0; total_prin_paid = 0; total_paid = 0
      installment          = 1

      while total_paid < total_amount_payable
        @_reducing_schedule[installment] = {}
        # interest
        int_paid = [interest_calculation, total_int_payable - total_int_paid].min # this ensures we do not overpay interest
        if installment == number_of_installments
          int_paid = [total_int_payable - total_int_paid,0].max
        end
        int_paid = int_paid.round(2)
        total_int_paid += int_paid
        # principal
        if force_num_installments and installment == number_of_installments
          prin_paid = balance
        else
          prin_paid = [equated_payment - int_paid, balance].min.round(2)
        end
        # cleaning up
        amount_left = equated_payment - int_paid - prin_paid
        if amount_left > 0 # something is left over? probably interest
          int_paid += [amount_left, total_int_payable - total_int_paid].min.round(2)
        end

        @_reducing_schedule[installment][:interest_payable]  = int_paid
        @_reducing_schedule[installment][:principal_payable] = prin_paid
        total_paid = (total_paid + prin_paid + int_paid).round(2)
        balance = (balance - prin_paid).round(2)
        installment += 1
      end
      return @_reducing_schedule
    end

  end #Flat


  module Equated

    def self.reducing_schedule(options)
      options = {:round_interest_to => 0.000001, :round_principal_to => 0.000001, :rounding_style => :round, :round_total_to => 0.000001, :force_num_installments => true}.merge(options)

      amount            = options[:amount];            number_of_installments = options[:number_of_installments]; interest_rate         = options[:interest_rate]
      round_interest_to = options[:round_interest_to]; round_principal_to     = options[:round_principal_to];     round_total_to        = options[:round_total_to]; 
      rounding_style    = options[:rounding_style];    force_num_installments = options[:force_num_installments]; installment_frequency = options[:installment_frequency]

      @_reducing_schedule = {}    
      balance            = amount
      i_per_period       = interest_rate/DIVIDER[installment_frequency]
      equated_payment    = Amortify.round_to_nearest(Amortify.pmt(i_per_period, number_of_installments, amount, 0, 0), 
                                                     round_total_to, rounding_style)
      installment        = 1
      while balance > 0
        @_reducing_schedule[installment] = {}
        int_paid = Amortify.round_to_nearest(balance * i_per_period, round_interest_to, rounding_style).round(6)
        # principal
        if force_num_installments and installment == number_of_installments
          prin_paid = balance
        else
          prin_paid = Amortify.round_to_nearest([equated_payment - int_paid, balance].min, round_principal_to, rounding_style)
        end
        balance =   Amortify.round_to_nearest(balance - prin_paid, 0.000001, :round).round(6)
        if balance <= 0.01
          prin_paid = Amortify.round_to_nearest((prin_paid + balance), round_principal_to, rounding_style).round(6)
          balance = 0
        end
        @_reducing_schedule[installment] = {:principal => prin_paid, :interest => int_paid}
        installment += 1
      end
      return @_reducing_schedule
    end
  end #EquatedWeekly

end

