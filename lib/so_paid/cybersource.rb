#require 'HOP'

module SoPaid
  class Cybersource < SoPaid::Hop

  
    @@pv_defaults = {
      :test=>{
        :post_urls=>{
          :webmobile=>"https://testsecureacceptance.cybersource.com/pay",
          :iframe=>"https://testsecureacceptance.cybersource.com/embedded/pay" 
        }
      },
      :live=>{
        :post_urls=>{
          :webmobile=>"https://secureacceptance.cybersource.com/pay",
          :iframe=>"https://secureacceptance.cybersource.com/embedded/pay" 
        }
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
          # used for determining if live, or test mode was used
          # AFTER the response form cybersource has been made
          # and we are verifying the request signature
          :merchant_defined_data100,
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
      :use_post_url=>:iframe
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


    def hop_url(use_post_url=nil)
      # test/live url has already been determined by test_mode or user_email
      @merged_pv_opts[:post_urls][ use_post_url.presence || @config_options[:use_post_url]]
    end


    def self.verify_transaction_signature(params)
      if params[:req_merchant_defined_data100].present? and params[:req_merchant_defined_data100] == "test"
        secret_key = get_secret_key_for(:test)
      else
        secret_key = get_secret_key_for(:live)
      end
      pub_digest = sign_params(params[:signed_field_names], params, secret_key)
      pub_digest.eql?(params[:signature].strip)
    end

    def self.sign_params(field_list, params, secret_key)
      field_list = field_list.split(",") if field_list.is_a? String
      data = []
      field_list.each do |key|
        data << key.to_s + "=" + params[key].to_s
      end
      data = data.join(",")
      encode_hop(data, secret_key)
    end

    def self.get_secret_key_for(targ_env)
      (@@pv_defaults[targ_env] and @@pv_defaults[targ_env][:secret_key]) || @@pv_defaults[:secret_key]
    end

    private

    def set_pv_fields
      @pv_order_params = {}
      if live?
        pv_opts = @pv_options[:live].presence || @pv_options
      else
        pv_opts = @pv_options[:test].presence || @pv_options
      end

      # we just set them above and are done with them
      @pv_options.delete(:live)
      @pv_options.delete(:test)
      # merge pv_order_params on top of pv_options which is
      # the combination of the class defaults and the configuration file defaults
      @merged_pv_opts = merge_defaults(pv_opts, @pv_options)
      @merged_pv_opts[:merchant_defined_data100] = live? ? "live" : "test"
      order_keys = @merged_pv_opts[:signed_field_names] + @merged_pv_opts[:unsigned_field_names]
      
      order_keys.each do |o_key|
        value = @merged_pv_opts[o_key].is_a?(Array) ? @merged_pv_opts[o_key].join(",") : @merged_pv_opts[o_key]
        @pv_order_params[o_key] = value
      end
    end


    def set_order_specific_params
      o_specific = { :amount=>"cs_amount", :reference_number=>"cs_reference_number", :transaction_uuid=>"cs_transaction_uuid" }
      
      o_specific.each_pair do |key, method|
        if @pv_order_params[key].present?
          next
        elsif @order.respond_to? method
          @pv_order_params[key] = @order.send(method.to_sym)
        else
          raise "No key/value pair given for order specific key '#{key.to_s}'. You must manually pass this pair in the opt_hash when calling SoPaid.vendor.new(order_obj, opt_hash, config_hash) or define a method/alias '#{method}' in your order_obj '#{@order.class.to_s}' model/class."
        end
      end

      @pv_order_params[:signed_date_time] = self.class.get_isotime if @pv_order_params[:signed_date_time].blank?
    end


    def set_signature
      @pv_order_params[:signature] = self.class.sign_params(@merged_pv_opts[:signed_field_names], @pv_order_params, @merged_pv_opts[:secret_key])
    end


    def test?
      @config_options[:test_mode] or (@config_options[:test_user_email].present? and @config_options[:test_user_email] == @current_user_email)
    end

    def live?
      !test?
    end

  end
end