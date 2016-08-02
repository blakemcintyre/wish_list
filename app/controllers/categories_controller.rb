class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:update, :destroy]

  def create
    @category = Category.create!(category_params.merge(user: current_user))

    respond_to do |format|
      format.json { render json: @category }
    end
  end

  def update
    @category.update_attributes(category_params)
    respond_to do |format|
      format.json { render json: @category }
    end
  end

  def destroy
    @category.destroy!
    header :ok
  end

  private

  def category_params
    params.require(:category).permit(:name, :user)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
