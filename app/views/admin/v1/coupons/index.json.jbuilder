json.coupons do
  json.array! @loading_service.records, :id, :code, :status, :discount_value, :due_date
end