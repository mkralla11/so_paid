module PayMe
  module PaymentVendor

    def vendor(name=nil)
      if name.present?
        self.vendors[name.to_s]
      elsif self.vendors.size == 1
        # {"cybersource"=>PayMe::Cybersource}
        self.vendors.first.last
      elsif self.vendors.size > 1
        raise "No vendor name specified when calling PayMe.vendor(:vendor_name). vendor_name must be specified when multiple payment vendors are loaded."
      else
        raise "No vendors have been loaded. Please run: rails generate payme:install. This will generate your payme.rb initilizer where you can load payment vendors."
      end
    end 

  end
end