json.system_requirements do
  json.array! @loading_service, :id, :name, :operational_system, :storage, :processor, :memory, :video_board
end