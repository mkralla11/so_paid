#  CyberSource Hosted Order Page Library
#
#  Inserts fields into the checkout form for posting data to the CyberSource Hosted Order page
#

# require 'openssl'
# include OpenSSL
require 'hmac-sha2'
require 'base64'


module PayMe
  class Hop
    @@pv_defaults = {

    }

    @@config_defaults = {
      # optional for gem
      :test_mode=>false,
      :test_user_email=>"payment_tester@gmail.com"
    }



    def self.payment_options(pv_options={}, config_options={})
      @@pv_defaults = self.merge_defaults([:live, :test], pv_options, @@pv_defaults)  
      @@config_defaults = self.merge_defaults(nil, config_options, @@config_defaults)

      return self
    end
  

    def initialize(order, pv_options={}, config_options={})
      @pv_order_params = {}.with_indifferent_access
      @pv_options = self.merge_defaults([:live, :test], pv_options, @@pv_defaults)  
      @config_options = self.merge_defaults(nil, config_options, @@config_defaults)

      @order = order
      @current_user_email = @config_options[:current_user_email] || @config_options[:current_user].try(:email) || (@order.user.try(:email) if @order.respond_to?(:user))
    end



    def get_isotime
      Time.now.utc.iso8601
    end

    def encode_hop(data, key)
      mac = HMAC::SHA256.new(key)
      mac.update data
      Base64.encode64(mac.digest).gsub "\n", ''
    end

    def verify_signature(data,signature)
       pub_digest = encode_hop(data, secret_key)
       pub_digest.eql?(signature)
    end
    
    def verify_transaction_signature(message)
      verify_signature(message[:signed_field_names], message[:signature])
    end

    def merge_defaults(modes=[], opts={}, default_opts={})
        PayMe::Hop.merge_defaults(modes, opts, default_opts)
    end


    def self.merge_defaults(modes=[], opts={}, default_opts={})
      modes ||= []
      new_opts = opts.clone.with_indifferent_access
      new_default_opts = default_opts.clone.with_indifferent_access
      modes.each do |mode|
        new_default_opts[mode] ||= {}
        new_opts_mode = new_opts[mode].is_a?(Hash) ? new_opts[mode] : {}
        new_opts_mode.each_pair do |key, value|
          if value.is_a?(Array)
            new_default_opts[mode][key] = ((new_default_opts[mode][key] || []) + value).uniq
          else
            new_default_opts[mode][key] = value
          end
        end
        new_opts.delete(mode)
      end

      # if mode was not provided via configuration file,
      # this defaults to the opposite/non-provided mode,
      # or uses the defaults set up in this file
      new_opts.each_pair do |key, value|
        if value.is_a?(Array)
          new_default_opts[key] = ((new_default_opts[key] || []) + value).uniq
        else
          new_default_opts[key] = value
        end
      end

      return new_default_opts
    end

    
    # def get_microtime
    #   t = Time.now
    #   sprintf("%d%03d", t.to_i, t.usec / 1000)
    # end
    
    # def encode_hop(data, key)
    #   Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, key, data)).chomp.gsub(/\n/,'')
    # end


    # def insert_signature3(amount="0.00",currency="usd",orderPage_transactionType='sale')
    #   profile_id = get_profile_id
    #   timestamp = get_microtime
    #   data = profile_id + amount + currency + timestamp + orderPage_transactionType
    #   pub = get_secret_key
    #   serial_number = get_serial_number
    #   pub_digest = encode_hop(data,pub)
      
    #   sig = "<input type='hidden' name='orderPage_transactionType' value='#{orderPage_transactionType}'>\n"
    #   sig <<  "<input type='hidden' name='amount' value='#{amount}'>\n"
    #   sig << "<input type='hidden' name='currency' value='#{currency}'>\n"
    #   sig << "<input type='hidden' name='orderPage_timestamp' value='#{timestamp}'>\n"
    #   sig << "<input type='hidden' name='merchantID' value='#{profile_id}'>\n"
    #   sig << "<input type='hidden' name='orderPage_signaturePublic' value='#{pub_digest}'>\n"
    #   sig << "<input type='hidden' name='orderPage_version' value='4'>\n"
    #   sig << "<input type='hidden' name='orderPage_serialNumber' value='#{serial_number}'>\n"
    #   sig
    # end
    


    # def insert_map_signature(assoc_array)
    #   assoc_array['mechantID'] = get_profile_id
    #   assoc_array['orderPage_timestamp'] = get_microtime
    #   assoc_array['orderPage_version'] = "4"
    #   assoc_array['orderPage_serialNumber'] = getSerialNumber
      
    #   fields = []
    #   values = ''
    #   inputs = ''
    #   assoc_array.each do |key,value|
    #     fields << key
    #     values << value
    #     inputs << '<input type="hidden" name="'+key+'" value="'+value+'">'+"\n"
    #   end
      
    #   pub = get_secret_key
    #   pub_digest = hop_hash(values,pub)
    #   inputs << '<input type="hidden" name="orderPage_signaturePublic" value="'+pub_digest+'">'+"\n"
    #   inputs << '<input type="hidden" name="orderPage_signedFields" value="'+fields+'">'+"\n"
    #   inputs
    # end

    # def insert_signature(amount="0.00",currency="usd")
    #   merchant_id = get_merchant_id
    #   timestamp = get_microtime
    #   data = merchant_id + amt + curr + timestamp
    #   serial_number = get_serial_number
    #   pub_digest = hop_hash(data, get_shared_secret)
      
    #   sig =  "<input type='hidden' name='amount' value='#{amount}'>\n"
    #   sig << "<input type='hidden' name='currency' value='#{currency}'>\n"
    #   sig << "<input type='hidden' name='orderPage_timestamp' value='#{timestamp}'>\n"
    #   sig << "<input type='hidden' name='merchantID' value='#{merchant_id}'>\n"
    #   sig << "<input type='hidden' name='orderPage_signaturePublic' value='#{sig_hash}'>\n"
    #   sig << "<input type='hidden' name='orderPage_version' value='4'>\n"
    #   sig << "<input type='hidden' name='orderPage_serialNumber' value='#{serial_number}'>\n"
    #   sig
    # end


    # def insert_subscription_signature(subscription_amount="0.00",
    #                                       subscription_start_date="00000000",
    #                                       subscription_frequency=nil,
    #                                       subscription_number_of_payments="0",
    #                                       subscription_automatic_renew="true"
    #                                       )
    #   if subscription_frequency.nil? then return end
      
    #   data = subscription_amount + subscription_start_date + subscription_frequency + subscription_number_of_payments + subscription_automatic_renew
    #   pub = get_shared_secret
    #   pub_digest = hop_hash(data, pub)
    #   sign = '<input type="hidden" name="recurringSubscriptionInfo_amount" value="' + subscriptionAmount + '">' + "\n"
    #   sig << '<input type="hidden" name="recurringSubscriptionInfo_numberOfPayments" value="' + subscriptionNumberOfPayments + '">' + "\n"
    #   sig << '<input type="hidden" name="recurringSubscriptionInfo_frequency" value="' + subscriptionFrequency + '">' + "\n"
    #   sig << '<input type="hidden" name="recurringSubscriptionInfo_automaticRenew" value="' + subscriptionAutomaticRenew + '">' + "\n"
    #   sig << '<input type="hidden" name="recurringSubscriptionInfo_startDate" value="' + subscriptionStartDate + '">' + "\n"
    #   sig << '<input type="hidden" name="recurringSubscriptionInfo_signaturePublic" value="' + pub_digest + '">' + "\n"
    #   sig
    # end
    
    # def insert_subscription_id_signature(subscription_id)
    #   if subscription_id.nil? then return end
      
    #   pub_digest = hop_hash(subscription_id, get_shared_secret)
    #   str = '<input type="hidden" name="paySubscriptionCreateReply_subscriptionID" value="' + subscription_id + '">' + "\n"
    #   str << '<input type="hidden" name="paySubscriptionCreateReply_subscriptionIDPublicSignature" value="' + pub_digest + '">' + "\n"
    #   str
    # end

        
  end
end