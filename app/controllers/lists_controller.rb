class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_users, only: [:edit, :index]
  before_action :set_item, only: [:update, :destroy]
  respond_to :html, :json

  def index
    @user = find_param_user_from_side_bar_users
    claimed_grouping = Item.claimed_grouping(@user.id, current_user.id)
    scoped = @user.categories.includes(:items).references(:items).order(:name).order("items.name")
    @unclaimed_items_by_category = scoped.merge(Item.where(id: claimed_grouping.fetch(:unclaimed, [])))
    @claimed_items_by_category = scoped.merge(Item.where(id: claimed_grouping.fetch(:claimed, [])))
    @recently_deleted_items = @user.items.includes(:category).recently_deleted
  end

  def edit
    @categories = current_user.categories.undeleted.order(:name)
    @grouped_items = current_user
      .items
      .unacknowledged
      .undeleted
      .includes(:category)
      .order(id: :asc)
      .group_by(&:category_id)
  end

  def update
    @item.update_attributes(item_params)
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
    @item.remove
    head :no_content
  end

  def remove_claimed
    items_ids = Item.claimed(current_user.id).pluck(:id)
    Item.where(id: items_ids).update_all(claim_acknowledged: true)

    redirect_to root_path
  end

  private

  def item_params
    params.require(:item).permit(:name, :category_id, :user, :quantity)
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def set_side_bar_users
    @side_bar_users = User.where.not(id: current_user.id).order(:name)
  end

  def find_param_user_from_side_bar_users
    @side_bar_users.detect { |user| user.id == params[:user_id].to_i }
  end
end
