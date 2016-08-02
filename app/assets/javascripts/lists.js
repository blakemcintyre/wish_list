$(function() {
  const categoryCancel = function() {
    const category_li = $(this).parent().parent();
    $(".category-edit-section", category_li).hide();
    $(".category-show-section", category_li).show();
  }

  const categoryEdit = function() {
    const category_li = $(this).parent().parent();
    $(".category-show-section", category_li).hide();
    $(".category-edit-section", category_li).show();
    $(".category-edit-input", category_li).focus();
  }

  const categoryUpdate = function() {
    const category_li = $(this).parent().parent();
    $.post("/categories/"+$(".category-id", category_li).val()+".json", { "_method": "PUT", "category": { "name": $(".category-edit-input", category_li).val() }}, function(category) {
      const category_li = $(".category-id[value="+category.id+"]").parent();
      $(".category-text", category_li).html(category.name);
      $(".category-edit-input", category_li).val(category.name);
      $(".category-edit-section", category_li).hide();
      $(".category-show-section", category_li).show();
    });
    // TODO: error handling
  }

  const categoryRemove = function() {
    alert("TODO: handle non-empty lists");
    // if (confirm("Are you sure?")) {
    //   const category_li = $(this).parent().parent();
    //   $.ajax({
    //     url: "/categories/"+$(".category-id", category_li).val(),
    //     type: "DELETE",
    //     success: function(result) {
    //       category_li.remove();
    //     }
    //   })
    }

  const itemCancel = function() {
    const item_li = $(this).parent().parent();
    $(".item-edit-section", item_li).hide();
    $(".item-show-section", item_li).show();
  }

  const itemEdit = function() {
    const item_li = $(this).parent().parent();
    $(".item-show-section", item_li).hide();
    $(".item-edit-section", item_li).show();
    $(".item-edit-input", item_li).focus();
  }

  const itemUpdate = function() {
    const item_li = $(this).parent().parent();
    $.post("/lists/"+$(".item-id", item_li).val()+".json", { "_method": "PUT", "item": { "name": $(".item-edit-input", item_li).val() }}, function(item) {
      const item_li = $(".item-id[value="+item.id+"]").parent();
      $(".item-text", item_li).html(item.name);
      $(".item-edit-input", item_li).val(item.name);
      $(".item-edit-section", item_li).hide();
      $(".item-show-section", item_li).show();
    });
    // TODO: error handling
  }

  const itemRemove = function() {
    // TODO: switch to "undo" style
    if (confirm("Are you sure?")) {
      const item_li = $(this).parent().parent();
      $.ajax({
        url: "/lists/"+$(".item-id", item_li).val(),
        type: "DELETE",
        success: function(result) {
          item_li.remove();
        }
      })
    }
  }

  $(".add-item").keypress(function(event) {
    if (event.which == 13) {
      event.preventDefault();

      const newItem = $(this);
      if (newItem.val() == '') { return; }

      $.post("/lists.json", { 'item': { name: newItem.val(), category_id: newItem.data('category-id') }}, function(item) {
        const tr = $("#item-template tr").clone();
        $(".item-id", tr).val(item.id);
        $(".item-text", tr).html(item.name);
        $(".item-edit-input", tr).val(item.name);
        console.log("item.category_id", item.category_id, `table[data-category-id="${item.category_id}"] tr:last-of-type`);
        $(`table[data-category-id="${item.category_id || ''}"] tr:last-of-type`).last().before(tr);
        $(".item-cancel", tr).click(itemCancel);
        $(".item-edit", tr).click(itemEdit);
        $(".item-update", tr).click(itemUpdate);
        $(".item-remove", tr).click(itemRemove);
        newItem.val('');
      });
    }
  });

  $(".add-category").keypress(function(event) {
    if (event.which !== 13) return;
    event.preventDefault();

    const newCategory = $(this);
    if (newCategory.val() === '') return;

    $.post("/categories.json", { 'category': { 'name': newCategory.val() }}, function(category) {
      console.log("new category", category);
      newCategory.val('');
    });
  });

  $(".category-cancel").click(categoryCancel);
  $(".category-edit").click(categoryEdit);
  $(".category-update").click(categoryUpdate);
  $(".category-remove").click(categoryRemove);
  $(".category-edit-section").hide();
  $(".item-cancel").click(itemCancel);
  $(".item-edit").click(itemEdit);
  $(".item-update").click(itemUpdate);
  $(".item-remove").click(itemRemove);
  $(".item-edit-section").hide();
});

