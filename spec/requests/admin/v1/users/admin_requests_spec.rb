require 'rails_helper'

RSpec.describe "Admin V1 Users as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /users" do
    let(:url) { "/admin/v1/users" }
    let!(:users) { create_list(:user, 5) }

    before(:each) { get url, headers: auth_header(user) }

    it "returns all Users" do
      expect(body_json['users']).to contain_exactly *users.as_json(only: %i(id name email profile)), user.as_json(only: %i(id name email profile))
    end# contain_exactly *users.as_json(only: %i(id name email password password_confirmation profile)), user.as_json(only: %i(id name email password password_confirmation profile))

    it "returns success status" do
      expect(response).to have_http_status(:ok)
    end

  end

  context "POST /users" do
    let(:url) { "/admin/v1/users" }

    context "with valid params" do
      let(:user_params) { {user: attributes_for(:user)}.to_json }

      it 'adds a new User' do
        expect do
          post url, headers: auth_header(user), params: user_params
        end.to change(User, :count).by(2)
      end

      it 'returns last added User' do
        post url, headers: auth_header(user), params: user_params
        user_requirement = User.last.as_json(only: %i(id name email profile))
        expect(body_json['user']).to eq user_requirement
      end

      it "returns success status" do
        post url, headers: auth_header(user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil, email: nil, profile: nil) }.to_json
      end

      before(:each) { post url, headers: auth_header(user), params: user_invalid_params }

      it 'does not add a new User' do
        expect do
        end.to_not change(User, :count)
      end

      it 'return error messages' do
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /users" do
    let(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    context "with valid params" do
      let(:new_name) { 'My new User' }
      let(:user_params) { {user: {name: new_name}}.to_json }

      before(:each) { patch url, headers: auth_header(user), params: user_params }

      it 'updates User' do
        user.reload
        expect(user.name).to eq new_name
      end

      it 'returns updated user' do
        user.reload
        expect_user = user.as_json(only: %i(id name email profile))
        expect(body_json['user']).to eq expect_user
      end

      it "returns success status" do
        expect(response).to have_http_status(:ok)
      end

    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil, email: nil, profile: nil) }.to_json
      end

      before(:each) { patch url, headers: auth_header(user), params: user_invalid_params }

      it "does not update User" do
        old_name = user.name
        user.reload
        expect(user.name).to eq old_name
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'return error messages' do
        expect(body_json['errors']['fields']).to have_key('name')
      end

    end
  end

  context "DELETE /users" do
    let!(:user2) { create(:user) }
    let(:url) { "/admin/v1/users/#{user2.id}" }

    it 'removes User' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(User, :count).by(0)
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