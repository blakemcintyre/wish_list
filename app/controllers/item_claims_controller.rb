class ItemClaimsController < ApplicationController
  respond_to :json

  def new
    @item = Item.find(params[:item_id])
    @item_claim = current_user.item_claims.new(item_id: params[:item_id])

  rescue ActiveRecord::RecordNotFound
    redirect_to '/', alert: 'Item not found'
  end

  def create
    @item_claim = current_user.item_claims.new(item_claim_params)

    if @item_claim.save
      redirect_to "/lists/#{@item_claim.item.user_id}"
    else
      @item = @item_claim.item
      render action: :new
    end
  end

  def edit
    @item_claim = current_user.item_claims.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to '/', alert: 'Item not found'
  end

  def update
    @item_claim = current_user.item_claims.find(params[:id])

    if @item_claim.update(item_claim_params)
      redirect_to "/lists/#{@item_claim.item.user_id}"
    else
      render action: :edit
    end
  end

  def destroy
    item_claim = current_user.item_claims.find(params[:id])
    source_user_id = item_claim.item.user_id
    item_claim.destroy
    # TODO: error handling

    redirect_to "/lists/#{source_user_id}"
  end

  private

  def item_claim_params
    params.require(:item_claim).permit(:item_id, :notes, :quantity)
  end
end
