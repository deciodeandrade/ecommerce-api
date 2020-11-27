require 'rails_helper'

RSpec.describe "Admin V1 Coupons as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /coupons" do
    let(:url) { "/admin/v1/coupons" }
    let!(:coupons) { create_list(:coupon, 5) }

    before(:each) { get url, headers: auth_header(user) }

    it "returns all Coupons" do
      expect(body_json['coupons']).to contain_exactly *coupons.as_json(only: %i(id code status discount_value due_date))
    end

    it "returns success status" do
      expect(response).to have_http_status(:ok)
    end

  end

  context "POST /coupons" do
    let(:url) { "/admin/v1/coupons" }

    context "with valid params" do
      let(:coupon_params) { {coupon: attributes_for(:coupon)}.to_json }

      it 'adds a new Coupon' do
        expect do
          post url, headers: auth_header(user), params: coupon_params
        end.to change(Coupon, :count).by(1)
      end

      it 'returns last added Coupon' do
        post url, headers: auth_header(user), params: coupon_params
        coupon_requirement = Coupon.last.as_json(only: %i(id code status discount_value due_date))
        expect(body_json['coupon']).to eq coupon_requirement
      end

      it "returns success status" do
        post url, headers: auth_header(user), params: coupon_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:coupon_invalid_params) do
        { coupon: attributes_for(:coupon, code: nil, status: nil, discount_value: nil, due_date: nil) }.to_json
      end

      before(:each) { post url, headers: auth_header(user), params: coupon_invalid_params }

      it 'does not add a new Coupon' do
        expect do
        end.to_not change(Coupon, :count)
      end

      it 'return error messages' do
        expect(body_json['errors']['fields']).to have_key('code')
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /coupons" do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    context "with valid params" do
      let(:new_code) { 'My new Coupon' }
      let(:coupon_params) { {coupon: {code: new_code}}.to_json }

      before(:each) { patch url, headers: auth_header(user), params: coupon_params }

      it 'updates Coupon' do
        coupon.reload
        expect(coupon.code).to eq new_code
      end

      it 'returns updated coupon' do
        coupon.reload
        expect_coupon = coupon.as_json(only: %i(id code status discount_value due_date))
        expect(body_json['coupon']).to eq expect_coupon
      end

      it "returns success status" do
        expect(response).to have_http_status(:ok)
      end

    end

    context "with invalid params" do
      let(:coupon_invalid_params) do
        { coupon: attributes_for(:coupon, code: nil, status: nil, discount_value: nil, due_date: nil) }.to_json
      end

      before(:each) { patch url, headers: auth_header(user), params: coupon_invalid_params }

      it "does not update Coupon" do
        old_code = coupon.code
        coupon.reload
        expect(coupon.code).to eq old_code
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'return error messages' do
        expect(body_json['errors']['fields']).to have_key('code')
      end

    end
  end

  context "DELETE /coupons" do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    it 'removes Coupon' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Coupon, :count).by(-1)
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