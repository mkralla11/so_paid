SoPaid.configure do |config|
  config.add_payment_vendor 'cybersource', # Name of your payment vendor
                            :vendor_options=>{ 
                                    # The only options that need to be placed
                                    # in this file are: 
                                    
                                    # secret_key, access_key, profile_id
                                    
                                    # All others will be passed/filled
                                    # by the default-defaults or by the Order object
                                    # you pass in at instantiation time.

                                    # NOTE: 'live' and 'test' hashes ALWAYS
                                    # trump any 'defaults' which are outside
                                    # of both of those hashes
                                    # you do not need to include live or test
                                    # hash if you don't want, and just use the default
                                    # outer hash

                                    # ALSO: merchant_defined_data100
                                    # is reserved for gem to determine
                                    # which 'mode' was originally chosen
                                    # before posting to cybersource
                                    # upon reply verification sig.

                                    :live=>{
                                      :secret_key=>"your_key",
                                      :access_key=>"your_key"
                                      #...any other live options
                                    },
                                    :test=>{
                                      :secret_key=>"your_key",
                                      :access_key=>"your_key"
                                      #...any other test options
                                    },
                                    #...any other DEFAULT options
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
                                    # IMPORTANT: if you want to add
                                    # any :unsigned_field_names, make sure
                                    # you add them to both within the
                                    # :unsigned_field_names array AND
                                    # as a key value pair within this hash,
                                    # used signed_field_names as an example

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
                                      ],

                            # config options
                            # if mode 
                            :config_options=>{
                              :use_post_url=>:iframe #:webmobile
                              # the purpose of the test_user_email
                              # is to trump the test_mode set here
                              # essentially forcing test_mode to true
                              # for that user only
                              :test_user_email=>"payment_tester@gmail.com",
                              :test_mode=>false
                            }
end