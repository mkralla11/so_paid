# SoPaid

A no-nonsense, fully configurable Rails credit card/payment vendor gem.

## Installation

Add this line to your application's Gemfile:

    gem 'so_paid'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install so_paid

## Usage

See examples folder for instructions and copy/pastable files. More will be added here when time is available (...rare).

To easily implement a working payment process using this gem, follow the simple steps below:

1. Create your config/initializers/so_paid.rb file to support the default parameters you would like to use:
  *  The required defaults are already populated for you, but if additional cybersource api signed fields are desired, make sure to add the desired field to BOTH the signed_field_names array, and the live/test hash, respectively, otherwise, it will be excluded. (see example)
2. Pick the controller action you would like to use (ex: payments_controller.rb 'confirm' action) to set up the post request to cybersource, and utilize one of these example code snippets (or customize your own):
  ```ruby
    # The args for vendor instantiation are the order object ( or nil ), additional api fields (vendor_options) hash, and the config_options hash.
    
    @payment_vendor = SoPaid.vendor.new(@order, {:payment_token_comments=>@payment.comments}, {})
    
    # Notice I have added an additional api field at run time, which requires me 
    # to either add this specific field to the signed_field_names 
    # array in the initializer, OR add it here as well.
    
    
    @payment_vendor = SoPaid.vendor(:cybersource).new(@order, {}, {:use_post_url=>:iframe})
    
    # Notice I have explicitly passed :cybersource as the vendor I desire to use. 
    # This is not required, as seen in the first example. If you have made only 
    # one vendor available in the initializer, then it conveniently defaults to 
    # that single one. (This feature will be benificial when supporting multitenancy 
    # and potentially multiple desired vendors in one app).
    # Also notice :use_post_url=>:iframe is passed in the config hash, 
    # which in this case switches the post url to the desired 
    # cybersource iframe url, instead of the webmobile url.
    
    
    @payment_vendor = SoPaid.vendor.new(nil, {:payment_token_comments=>CartItem.description(@user.cart_items), :amount=>@template.number_with_precision(@cart_total,2), :reference_number=>r_num, :transaction_uuid=>"sun_"+ r_num, :merchant_defined_data99=>@user.id.to_s}, {:current_user=>@user})
    
    # Here is an extremely explicit example. As a developer, sometimes we have to 
    # deal with legacy programs, and this gem supports those dirty cases. In this 
    # legacy application's example snippet, no order object is actually created before 
    # the order, even though cybersource desires a unique order identification number, 
    # known as the transaction_uuid. So, nil is pass as the order object, and the needed 
    # api fields that are normally 'pulled' from this object are explicitly passed in to 
    # the vendor_options to accommodate these required fields. Also, the current_user is 
    # passed into the config_options hash in order to determine whether or not that user 
    # has the test_user_email, dynamically sets the 'mode' to 'test.' (normally, the user 
    # is acquired by the order (user.order), because orders normally belong to users, 
    # but in this case, there was no order object to begin with).
  ```

3.  create your view for the chosen action above, ex: views/payments/confirm.html.erb:
  ```ruby
  <form action="<%=@payment_vendor.hop_url%>" method="post" id="pv-form">
    <% @payment_vendor.generate_params.each_pair do |key, value| %>
      <input type="hidden" name="<%=key%>" value="<%=value%>" >
    <%end%>
  </form>

  ```

4.  Lastly, choose the action that cybersource will make a post request to in your application and utilize this snippet to validate the signature of the request:
  ```ruby
  SoPaid.vendor(:cybersource).verify_transaction_signature(params)
  ```





## Currently supported payment vendors:

1. cybersource
  *  request field info and doc:
      *  http://apps.cybersource.com/library/documentation/dev_guides/Secure_Acceptance_WM/Secure_Acceptance_WM.pdf
  *  Field Mapping Info (helpful when upgrading from Legacy Hop to Secure Acceptance):
      *  http://www.cybersource.com/products_and_services/payment_security/secure_acceptance/installbase/resources/SecureAcceptance_API_Discovery.htm  
2. no more yet...


## Call To Lead<sup>TM</sup>

  Want to make this gem more awesome? Even though everything works, maybe you have some good ideas that you want incorporated, whether it be performance-wise, or extension-wise. Hense, the following list is for you to easily view and will be ammended for large ideas.

### The List<sup>TM</sup>:
  1. Support for paypal.
  2. Support for stripe (wrapping the gem that already exists).


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

