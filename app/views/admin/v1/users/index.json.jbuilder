json.users do
  json.array! @loading_service, :id, :name, :email, :profile
end