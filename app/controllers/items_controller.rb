class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_lists, only: [:edit, :index]
  before_action :set_item, only: %i(edit update destroy)

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
    @item.update(item_params)
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(@item, partial: "items/item", locals: { item: @item })
      }
      format.html {
        redirect_to list_items_path(@item.previous_changes.fetch('list_id', [@item.list_id]).first)
      }
    end
  end

  def create
    @item = Item.create(item_params)

    respond_to do |format|
      if @item.persisted?
        format.turbo_stream {
          render turbo_stream: turbo_stream.before(
            "add-item-for-category-#{@item.category_id}",
            partial: "items/item",
            locals: { item: @item }
          )
        }
      else
        format.turbo_stream {
          head :unprocessable_entity
        }
      end
    end
  end

  def destroy
    @item.remove
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@item) }
      format.html { head :no_content }
    end
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
