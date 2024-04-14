# frozen_string_literal: true

class ListItemGrouper
  def initialize(list, user)
    @list = list
    @user = user
  end

  # Claimed items can be in both unclaimed and claimed, unless claimed by the user then only claimed
  def process
    claimed = initialize_collection_hash
    unclaimed = initialize_collection_hash

    items_query.each do |item|
      parent_id = resolve_parent_id(item)
      append_item(item, claimed, parent_id) if claimed?(item)
      append_item(item, unclaimed, parent_id) if unclaimed?(item)
    end

    [claimed, unclaimed]
  end

  def resolve_parent_id(item)
    item.parent_categories_id || item.categories_id
  end

  def append_item(item, target, parent_id)
    parent_key = [parent_id, item.parent_categories_name || item.categories_name]

    if parent_id == item.categories_id
      target[parent_key][:items] << item
    else
      key = [item.categories_id, item.categories_name]
      target[parent_key][:sub_categories][key] ||= []
      target[parent_key][:sub_categories][key] << item
    end
  end

  def claimed?(item)
    item.user_claimed_quantity.positive? || item.total_claimed_quantity.positive?
  end

  def unclaimed?(item)
    item.user_claimed_quantity.zero? && (item.quantity_remaining.nil? || item.quantity_remaining.positive?)
  end

  def initialize_collection_hash
    Hash.new { |h, k| h[k] = { items: [], sub_categories: {} } }
  end

  # TODO: copy recently_deleted_items

  def items_query
    Item.select(
        <<~SQL
          categories.id AS categories_id,
          categories.name AS categories_name,
          parent_categories_categories.id AS parent_categories_id,
          parent_categories_categories.name AS parent_categories_name,
          items.id,
          items.name,
          items.quantity,
          items.list_id,
          SUM(COALESCE(user_claimed_quantity, 0)) AS user_claimed_quantity,
          SUM(COALESCE(claimed_quantity, 0)) AS total_claimed_quantity,
          SUM(items.quantity - COALESCE(claimed_quantity, 0)) AS quantity_remaining,
          claim_notes
        SQL
      )
      .joins(:category)
      .left_outer_joins(category: :parent_category)
      .joins("LEFT OUTER JOIN (#{claims_query.to_sql}) AS item_claims ON item_claims.item_id = items.id")
      .where(list: @list)
      .merge(Item.undeleted)
      .group('"categories"."id", "parent_categories_categories"."id", "items"."id", claim_notes')
      .order(Arel.sql('COALESCE(parent_categories_categories.name, categories.name) ASC, "items"."name" ASC'))
  end

  def claims_query
    ItemClaim.select(
      <<~SQL
        "item_claims"."item_id",
        COALESCE(SUM("item_claims"."quantity"), 0) AS "claimed_quantity",
        COALESCE(
          SUM(item_claims.quantity) FILTER (WHERE item_claims.user_id = #{@user.id}),
          0
        ) AS user_claimed_quantity,
        ARRAY_AGG("item_claims".notes) AS claim_notes
      SQL
    )
    .joins(:item)
    .where(items: { list_id: @list.id })
    .group(:item_id)
  end
end
