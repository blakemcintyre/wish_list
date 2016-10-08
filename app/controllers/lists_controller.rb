class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_users, only: [:edit, :index]
  before_action :set_item, only: [:update, :destroy]
  respond_to :html, :json

  def index
    @user = find_param_user_from_side_bar_users
    scoped = @user.categories.includes(:items).references(:items).order(:name).order("items.name")
    @unclaimed_items_by_category = scoped.merge(Item.unclaimed)
    @claimed_items_by_category = scoped.merge(Item.claimed)
    @unclaimed_items = @user.items.unclaimed.order(:name)
  end

  def edit
    @categories = current_user.categories
    @grouped_items = current_user.items.undeleted.includes(:category).order(id: :asc).group_by(&:category_id)
  end

  def update
    @item.update_attributes(name: params[:item][:name])
    respond_to do |format|
      format.json { render json: @item }
    end
  end

  def create
    @item = Item.create(item_params.merge(user: current_user))

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
    params.require(:item).permit(:name, :category_id, :user)
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def set_side_bar_users
    @side_bar_users = User.where.not(id: current_user.id)
  end

  def find_param_user_from_side_bar_users
    @side_bar_users.detect { |user| user.id == params[:user_id].to_i }
  end
end
