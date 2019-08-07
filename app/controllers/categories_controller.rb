class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:update, :destroy]

  def new
    parent_category = Category.find(params[:parent_category_id]) unless params[:parent_category_id].blank?
    @category = Category.new(user: current_user, parent_category: parent_category)
  end

  def create
    @category = Category.new(category_params.merge(user: current_user))

    if @category.save
      redirect_to root_path
    else
      render action: :new
    end
  end

  def update
    @category.update_attributes(category_params)
    respond_to do |format|
      format.json { render json: @category }
    end
  end

  def destroy
    @category.remove
    redirect_to root_path
  end

  private

  def category_params
    params.require(:category).permit(:name, :user, :parent_category_id)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
