module SoPaid
  module Configuration

    mattr_accessor :vendors
    self.vendors = {}

    def configure
      yield self
    end

    def add_payment_vendor(name="cybersource", options={})
      new_vendor = ("SoPaid::" + name.classify).safe_constantize
      raise "Payment Vendor '#{name}' gem/plugin not supported." if new_vendor.blank?
      vo = options.delete(:vendor_options) || {}
      co = options.delete(:config_options) || {}
      vo ||= options

      self.vendors[name] = new_vendor.payment_options(vo, co)
    end


  end
end