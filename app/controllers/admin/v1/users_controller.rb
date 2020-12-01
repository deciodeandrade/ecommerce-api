module Admin::V1
  class UsersController < ApiController
    before_action :load_user, only: [:update, :destroy]

    def index
      @loading_service = Admin::ModelLoadingService.new(User.all, searchable_params)
    end

    def create
      @user = User.new
      @user.attributes = user_params
      save_user!
    end

    def update
      @user.attributes = user_params
      save_user!
    end

    def destroy
      @user.destroy
    rescue
      render_error(fields: @user.errors.messages)
    end

    private

    def searchable_params
      params.permit({search: :name}, {order: {}}, :page, :length)
    end

    def load_user
      @user = User.find(params[:id])
    end

    def user_params
      return {} unless params[:user]
      params.require(:user)
          .permit(:name, :email, :profile, :password, :password_confirmation)
    end

    def save_user!
      @user.save!
      render :show
    rescue
      render_error(fields: @user.errors.messages)
    end

  end
end