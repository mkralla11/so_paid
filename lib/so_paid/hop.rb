#  CyberSource Hosted Order Page Library
#
#  Inserts fields into the checkout form for posting data to the CyberSource Hosted Order page
#

# require 'openssl'
# include OpenSSL
require 'hmac-sha2'
require 'base64'


module SoPaid
  class Hop
    @@pv_defaults = {

    }

    @@config_defaults = {
      # optional for gem
      :test_mode=>false,
      :test_user_email=>"payment_tester@gmail.com"
    }



    def self.payment_options(pv_options={}, config_options={})
      @@pv_defaults = self.merge_defaults(pv_options, @@pv_defaults)  
      @@config_defaults = self.merge_defaults(config_options, @@config_defaults)

      return self
    end
  

    def initialize(order, pv_options={}, config_options={})
      @pv_order_params = {}.with_indifferent_access
      @pv_options = self.merge_defaults(pv_options, @@pv_defaults)  
      @config_options = self.merge_defaults(config_options, @@config_defaults)

      @order = order
      @current_user_email = @config_options[:current_user_email] || @config_options[:current_user].try(:email) || (@order.user.try(:email) if @order.respond_to?(:user))
      generate_params
      return self
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

    def merge_defaults(opts={}, default_opts={})
        SoPaid::Hop.merge_defaults(opts, default_opts)
    end



    def self.merge_defaults(main_hash, defaults_hash)
        target = main_hash.dup
        (defaults_hash.keys + main_hash.keys).uniq.each do |key|
          if defaults_hash[key].is_a? Hash and main_hash[key].is_a? Hash
            target[key] = merge_defaults(target[key], defaults_hash[key])
            next
          end
          #target[key] = hash[key]
          # if the defaults_hash value is an array, make sure just to
          # append new uniq values, not overwrite default
          target.update(defaults_hash) do |key, tv, dv|
            ntv = tv.is_a?(Array) ? tv.clone : tv
            dv.is_a?(Array) ? (dv.clone << ntv ).flatten.uniq : ntv
          end
        end
        target
     end

        
  end
end