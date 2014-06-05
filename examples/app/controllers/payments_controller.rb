class PaymentsController < ApplicationController

  # Vendor will post to this post url (which can no longer be passed in at run time)
  # set up this route in your cybersource/paypal/vendor's 'profile' panel on 
  # their website. http://yourdomain.com/payments/
  def create
    # process the response how you see fit,
    # verify the transaction signature in the OrderProcessor class
    # you have defined to process the returning post request from vendor,
    # use public methods available to you using SoPaid.vendor,
    # ex: SoPaid.vendor(:cybersource).verify_transaction_signature(params)
    @order_processor = OrderProcessor.new(params)
    @order_processor.process_transaction
    render :nothing=>true, :status=>:ok
  end

  def confirm
    get_cart_order
    # Need to check if payment post is going to fail 
    # because the order can't save or is invalid! So, try to SAVE IT
    # or else it will fail on return from Cybersource POST #notgood
    # and the user won't know what happened
    if @order.save
      # specific payment vendor, ex: cybersource...
      #...or not if you only have one defined in config
      #ex: @payment_vendor = SoPaid.vendor(:cybersource).new(@order, {override_defaults_hash}, {override_config_defaults_hash})
      @payment_vendor = SoPaid.vendor.new(@order)
    else
      flash[:error] = "Please fix all errors with your account and your order. If you are having trouble making a purchase, contact the administrator."
      redirect_back_or_default root_path
    end
  end

  # should show the list of payments/invoices
  def index
    # #payments are paid orders
    @payments = @user.payments
    render :layout=>"accounts"
  end


  # This is the return_url (which can no longer be passed in at run time)
  # set up this route in your cybersource/paypal/vendor's 'profile' panel on 
  # their website. http://yourdomain.com/redirect_from_hop
  def redirect_from_hop
    if session[:pay_post_made]
      if current_user and current_user.orders.order('created_at DESC').first
        order = current_user.orders.order('created_at DESC').first
        if order.paid?
          flash[:success] = "You successfully purchased, " # + fill in what user purchased
        else
          flash[:fail] = "Uh oh, your purchase was not completed. Your credit card was not charged. Your cart will retain the items you original wanted to purchase.<br><br><b>Please verify that you entered your credit card information correctly and try again.</b> If the Problem persists please contact the administrator.".html_safe
        end
      end
      session[:pay_post_made] = nil
    end
    #redirect to index of all payments
    redirect_to payments_path
  end

  private
  def get_cart_order
    @order = current_user.cart
  end
end