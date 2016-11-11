class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:update, :destroy]

  def new
    @category = Category.new(user: current_user)
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
    params.require(:category).permit(:name, :user)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
