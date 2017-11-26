class ItemClaimsController < ApplicationController
  respond_to :json

  def create
    @item_claim = current_user.item_claims.create(item_claim_params)
    # TODO: error handling
    redirect_to "/lists/#{@item_claim.item.user_id}"
  end

  def destroy
    item_claim = current_user.item_claims.find(params[:id])
    source_user = item_claim.item.user
    item_claim.destroy
    # TODO: error handling

    redirect_to "/lists/#{source_user.id}"
  end

  private

  def item_claim_params
    params.require(:item_claim).permit(:item_id, :quantity)
  end
end
