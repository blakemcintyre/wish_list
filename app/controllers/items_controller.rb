class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_lists, only: [:edit, :index]
  before_action :set_item, only: %i(edit update destroy)
  respond_to :html, :json

  def index
    @list = current_user.lists.find(params[:list_id])
    category_scope = @list.categories.undeleted.order(:name)
    @categories = category_scope.is_parent
    @sub_categories = category_scope.has_parent.group_by(&:parent_category_id)
    @grouped_items = @list
      .items
      .undeleted
      .includes(:category)
      .order(:name)
      .group_by(&:category_id)
  end

  def edit
    @lists = current_user.lists.order(:name)
    @categories = @item.list.categories.undeleted.order(:name)
  end

  def update
    @item.update_attributes(item_params)
    respond_to do |format|
      format.json { render json: @item }
      format.html { redirect_to list_items_path(@item.list_id) }
    end
  end

  def create
    @item = Item.create(item_params)

    respond_to do |format|
      if @item.persisted?
        format.json { render json: @item }
      else
        format.json {
          render status: :unprocessable_entity,
          json: { item: @item, errors: @item.errors.full_messages }
        }
      end
    end
  end

  def destroy
    @item.remove
    head :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :category_id, :quantity, :list_id)
  end

  def set_item
    @item = Item.joins(list: [:permissions])
      .where(list_permissions: { user_id: current_user.id })
      .find(params[:id])
  end
end
