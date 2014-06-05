#require 'HOP'

module SoPaid
  class Cybersource < SoPaid::Hop

  
    @@pv_defaults = {
      :live=>{
      },
      :test=>{
      },
      :secret_key=>"",
      :profile_id=>"",
      :access_key=>"",
      :transaction_uuid=>"",
      :locale=>"en-US",
      :transaction_type=>"sale",
      :reference_number=>"",
      :amount=>"",
      :currency=>"USD",
      :signed_date_time=>"",
      :unsigned_field_names=>[],

      :signed_field_names =>
        [
          :profile_id, 
          :access_key, 
          :transaction_uuid, 
          :locale, 
          :transaction_type, 
          :reference_number,
          :amount, 
          :currency, 
          :signed_date_time,
          :unsigned_field_names, 
          :signed_field_names
        ]
    }
    
    @@config_defaults = {
      # optional for gem
      :test_mode=>false,
      :test_user_email=>"payment_tester@gmail.com"
    }




    # refer to http://apps.cybersource.com/library/documentation/dev_guides/Secure_Acceptance_WM/html/wwhelp/wwhimpl/js/html/wwhelp.htm#href=SC_api.12.1.html#1113432
    # for more info on required keys
    # needed signed fields:
    # "access_key,profile_id,transaction_uuid,signed_field_names,unsigned_field_names,signed_date_time,locale,transaction_type,reference_number,amount,currency"
    def generate_params
      return @pv_order_params if @pv_order_params.present?

      set_pv_fields
      set_order_specific_params
      set_signature

      return @pv_order_params
    end


    def hop_url(user_email)
      # test mode true or specific test email gets access to test page
      if test? or @config_options[:test_user_email] == @current_user_email
        test_hop_url
      else
        live_hop_url
      end
    end


    private





    def set_pv_fields
      if live?
        @pv_order_params = @pv_options[:live].presence || @pv_options
      else
        @pv_order_params = @pv_options[:test].presence || @pv_options
      end

      # we just set them above and are done with them
      @pv_options.delete(:live)
      @pv_options.delete(:test)
      # merge pv_order_params on top of pv_options which is
      # the combination of the class defaults and the configuration file defaults
      @pv_order_params = merge_defaults(nil, @pv_order_params, @pv_options)
    end


    def set_order_specific_params
      o_specific = { :amount=>"amount_cents", :reference_number=>"id", :transaction_uuid=>"uniq_app_order_id" }
      
      o_specific.each_pair do |key, method|
        if @pv_order_params[key].present?
          next
        elsif @order.respond_to? method
          @pv_order_params[key] = @order.send(method.to_sym)
        else
          raise "No key/value pair given for order specific key '#{key.to_s}'. You must manually pass this pair in the opt_hash when calling SoPaid.vendor.new(order_obj, opt_hash, config_hash) or define a method/alias '#{method}' in your order_obj '#{@order.class.to_s}' model/class."
        end
      end

      @pv_order_params[:signed_date_time] = get_isotime if @pv_order_params[:signed_date_time].blank?
    end


    def set_signature
      @pv_order_params[:signature] = sign_params
    end


    def sign_params
      data = []
      @pv_options[:signed_field_names].each do |key|
        data << key.to_s + "=" + @pv_order_params[key].to_s
      end
      @pv_options[:signed_field_names] = @pv_options[:signed_field_names].join(",")
      data = data.join(",")

      encode_hop(data, @pv_order_params[:secret_key])
    end


    def test?
      @config_options[:test_mode]
    end

    def live?
      !test?
    end

    def test_hop_url
      "https://testsecureacceptance.cybersource.com/pay"
    end

    def live_hop_url
      "https://secureacceptance.cybersource.com/pay"
    end
  end
end