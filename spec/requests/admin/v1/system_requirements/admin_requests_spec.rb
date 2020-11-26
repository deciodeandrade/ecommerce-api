require 'rails_helper'

RSpec.describe "Admin V1 SystemRequirements as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    before(:each) { get url, headers: auth_header(user) }

    it "returns all SystemRequirements" do
      expect(body_json['system_requirements']).to contain_exactly *system_requirements.as_json(only: %i(id name operational_system storage processor memory video_board))
    end

    it "returns success status" do
      expect(response).to have_http_status(:ok)
    end

  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    context "with valid params" do
      let(:system_requirement_params) { {system_requirement: attributes_for(:system_requirement)}.to_json }

      it 'adds a new SystemRequirement' do
        expect do
          post url, headers: auth_header(user), params: system_requirement_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it 'returns last added SystemRequirement' do
        post url, headers: auth_header(user), params: system_requirement_params
        expect_system_requirement = SystemRequirement.last.as_json(only: %i(id name operational_system storage processor memory video_board))
        expect(body_json['system_requirement']).to eq expect_system_requirement
      end

      it "returns success status" do
        post url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil, operational_system: nil, storage: nil, processor: nil, memory: nil, video_board: nil) }.to_json
      end

      before(:each) { post url, headers: auth_header(user), params: system_requirement_invalid_params }

      it 'does not add a new SystemRequirement' do
        expect do
        end.to_not change(SystemRequirement, :count)
      end

      it 'return error messages' do
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /system_requirements" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    context "with valid params" do
      let(:new_name) { 'My new SystemRequirement' }
      let(:system_requirement_params) { {system_requirement: {name: new_name}}.to_json }

      before(:each) { patch url, headers: auth_header(user), params: system_requirement_params }

      it 'updates SystemRequirement' do
        system_requirement.reload
        expect(system_requirement.name).to eq new_name
      end

      it 'returns updated system_requirement' do
        system_requirement.reload
        expect_system_requirement = system_requirement.as_json(only: %i(id name operational_system storage processor memory video_board))
        expect(body_json['system_requirement']).to eq expect_system_requirement
      end

      it "returns success status" do
        expect(response).to have_http_status(:ok)
      end

    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil, operational_system: nil, storage: nil, processor: nil, memory: nil, video_board: nil) }.to_json
      end

      before(:each) { patch url, headers: auth_header(user), params: system_requirement_invalid_params }

      it "does not update SystemRequirement" do
        old_name = system_requirement.name
        system_requirement.reload
        expect(system_requirement.name).to eq old_name
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'return error messages' do
        expect(body_json['errors']['fields']).to have_key('name')
      end

    end
  end

  context "DELETE /system_requirements" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    it 'removes SystemRequirement' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(SystemRequirement, :count).by(-1)
    end

    it 'returns success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end
  end

end