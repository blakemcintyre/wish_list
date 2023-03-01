class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, except: %i(edit update)

  def index
    @categories = categories_scope.where(lists: { id: params[:list_id ] })
    @categories = @categories.where(categories: { parent_category_id: nil }) if params[:parent_only]

    respond_to do |format|
      format.json { render json: @categories.order(:name) }
    end
  end

  def new
    parent_category = @list.categories.find(params[:parent_category_id]) unless params[:parent_category_id].blank?
    @category = @list.categories.new(list: @list, parent_category: parent_category)
  end

  def create
    @category = @list.categories.build(category_params.merge(list: @list))

    if @category.save
      redirect_to list_items_path(@list)
    else
      render action: :new
    end
  end

  def edit
    @category ||= categories_scope.find(params[:id])
    @lists = current_user.lists.order(:name)
    @parent_categories_in_list = @category.list.categories.where(parent_category_id: nil).where.not(id: @category)
  end

  def update
    @category = categories_scope.find(params[:id])

    if @category.update(category_params)
      @category.items.update_all(list_id: @category.list_id)

      respond_to do |format|
        format.json { render json: @category }
        format.html { redirect_to list_items_path(@category.list_id) }
      end
    else
      respond_to do |format|
        format.json { render json: @category }
        format.html do
          edit
          render action: :edit
        end
      end
    end
  end

  def destroy
    category = @list.categories.find(params[:id])
    category.remove

    redirect_to list_items_path(@list)
  end

  private

  def category_params
    params.require(:category).permit(:name, :list_id, :parent_category_id)
  end

  def set_list
    @list = current_user.lists.find(params[:list_id])
  end

  def categories_scope
    Category.undeleted.joins(list: :permissions).where(list_permissions: { user_id: current_user })
  end
end
