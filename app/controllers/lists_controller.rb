class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_users, only: [:edit, :index]
  before_action :set_item, only: [:update, :destroy]
  respond_to :html, :json

  def index
    @user = find_param_user_from_side_bar_users
    @items_grouper = ItemsGrouper.new(@user, current_user)
  end

  def edit
    category_scope = current_user.categories.undeleted.order(:name)
    @categories = category_scope.is_parent
    @sub_categories = category_scope.has_parent.group_by(&:parent_category_id)
    @grouped_items = current_user
      .items
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
    ClaimedRemover.new(current_user).process

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
