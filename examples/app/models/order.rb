class Order < ActiveRecord::Base

  attr_accessible :amount_cents

  monetize :amount_cents

  # so_paid gem Cybersource config
  def cs_transaction_uuid
    "mbs_" + id
  end

  def cs_amount
    amount.format(:symbol=>false)
  end

  alias_method :cs_reference_number, :id


end
