class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_users, only: [:edit, :index]
  before_action :set_item, only: [:reposition, :update, :destroy]
  respond_to :html, :json

  def index
    @user = @side_bar_users.detect { |user| user.id == params[:user_id].to_i }
    @unclaimed_items = @user.items.unclaimed.order(:position)
    @claimed_items = @user.items.claimed.order(:position)
    respond_with @items
  end

  def edit
    @items = current_user.items.undeleted
    respond_with @items
  end

  def update
    @item.update_attributes(name: params[:item][:name])
    respond_to do |format|
      format.json { render json: @item }
    end
  end

  def reposition
    @item.update_attribute(:position, params[:position])
    respond_to do |format|
      format.json { render json: @item }
    end
  end

  def create
    @item = Item.create(item_params.merge(user: current_user))
    # respond_with @item, edit_item_path(@item)
    respond_to do |format|
      format.json { render json: @item }
    end
  end

  def destroy
    @item.update_attributes(deleted_at: Time.zone.now)
    # TODO: error handling
    render text: nil, status: :ok
  end

  private

  def item_params
    params.require(:item).permit(:name, :user)
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def set_side_bar_users
    @side_bar_users = User.where.not(id: current_user.id)
  end
end
