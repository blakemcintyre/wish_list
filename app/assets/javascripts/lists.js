$(function() {
  const categoryCancel = function() {
    const category_li = $(this)
      .parent()
      .parent();
    $('.category-edit-section', category_li).hide();
    $('.category-show-section', category_li).show();
  };

  const categoryEdit = function() {
    const category_li = $(this)
      .parent()
      .parent();
    $('.category-show-section', category_li).hide();
    $('.category-edit-section', category_li).show();
    $('.category-edit-input', category_li).focus();
  };

  const categoryUpdate = function() {
    const category_li = $(this)
      .parent()
      .parent();
    $.post(
      '/lists/' + $('#id').val() + '/categories/' + $('.category-id', category_li).val() + '.json',
      {
        _method: 'PUT',
        category: { name: $('.category-edit-input', category_li).val() }
      },
      function(category) {
        const category_li = $(
          '.category-id[value=' + category.id + ']'
        ).parent();
        $('.category-text', category_li).html(category.name);
        $('.category-edit-input', category_li).val(category.name);
        $('.category-edit-section', category_li).hide();
        $('.category-show-section', category_li).show();
      }
    );
    // TODO: error handling
  };

  const categoryRemove = function() {
    const category_head_tr = $(this)
      .parent()
      .parent();
    const category_id = $('.category-id', category_head_tr).val();
    const itemsCount =
      $('#items-for-category-' + category_id + ' tr').length - 1;
    var message = 'Are you want to delete this category sure?';

    if (itemsCount > 0) {
      message += '\nAll ' + itemsCount + ' item(s) will be delete with it.';
    }

    return confirm(message);
  };

  const itemCancel = function() {
    const item_li = $(this)
      .parent()
      .parent();
    $('.item-edit-section', item_li).hide();
    $('.item-show-section', item_li).show();
  };

  const itemEdit = function() {
    const item_li = $(this)
      .parent()
      .parent();
    $('.item-show-section', item_li).hide();
    $('.item-edit-section', item_li).show();
    $('.item-edit-input', item_li).focus();
  };

  const itemUpdate = function() {
    const listId = $('#id').val();
    const item_li = $(this)
      .parent()
      .parent();
    $.post(
      `/lists/${listId}/items/${$('.item-id', item_li).val()}.json`,
      {
        _method: 'PUT',
        item: {
          name: $('.item-edit-input', item_li).val(),
          quantity: $('.item-edit-quantity', item_li).val()
        }
      },
      function(item) {
        const item_li = $('.item-id[value=' + item.id + ']').parent();
        $('.item-text', item_li).html(item.name);
        $('.item-edit-input', item_li).val(item.name);
        $('.item-quantity', item_li).html(item.quantity);
        $('.item-edit-quantity', item_li).val(item.quantity);
        $('.item-edit-section', item_li).hide();
        $('.item-show-section', item_li).show();
      }
    );
    // TODO: error handling
  };

  const itemRemove = function() {
    // TODO: switch to "undo" style
    if (confirm('Are you sure?')) {
      const listId = $('#id').val();
      const item_li = $(this)
        .parent()
        .parent();
      $.ajax({
        url: `/lists/${listId}/items/${$('.item-id', item_li).val()}`,
        type: 'DELETE',
        success: function(result) {
          item_li.remove();
        }
      });
    }
  };

  const itemCreate = function(event) {
    if (event.which == 13) {
      event.preventDefault();

      const listId = $('#id').val();
      let newItem, quantity;

      if ($(this).hasClass('add-item')) {
        newItem = $(this);
        quantity = $('input', newItem.parent().next());
      } else {
        quantity = $(this);
        newItem = $('input', quantity.parent().prev());
      }

      if (newItem.val() == '') {
        return;
      }

      $.post(
        `/lists/${listId}/items.json`,
        {
          item: {
            list_id: listId,
            name: newItem.val(),
            category_id: newItem.data('category-id'),
            quantity: quantity.val()
          }
        },
        function(item) {
          const tr = $('#item-template tr').clone();
          const categoryId = item.category_id || '';

          $('.item-id', tr).val(item.id);
          $('.item-text', tr).html(item.name);
          $('.item-edit-input', tr).val(item.name);
          $('.item-quantity', tr).html(item.quantity);
          $('.item-edit-quantity', tr).val(item.quantity);
          $('table[data-category-id="' + categoryId + '"] tr:last-of-type')
            .last()
            .before(tr);
          $('.item-cancel', tr).click(itemCancel);
          $('.item-edit', tr).click(itemEdit);
          $('.item-update', tr).click(itemUpdate);
          $('.item-remove', tr).click(itemRemove);
          newItem.val('');
          quantity.val(1);
          newItem.focus();
        }
      );
    }
  };

  $('.add-item').keypress(itemCreate);
  $('.add-quantity').keypress(itemCreate);
  $('.category-cancel').click(categoryCancel);
  $('.category-edit').click(categoryEdit);
  $('.category-update').click(categoryUpdate);
  $('.category-remove').click(categoryRemove);
  $('.category-edit-section').hide();
  $('.item-cancel').click(itemCancel);
  $('.item-edit').click(itemEdit);
  $('.item-update').click(itemUpdate);
  $('.item-remove').click(itemRemove);
  $('.item-edit-section').hide();
});
