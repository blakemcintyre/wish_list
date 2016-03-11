$(function() {
  var itemCancel = function() {
    var item_li = $(this).parent().parent();
    $(".item-edit-section", item_li).hide();
    $(".item-show-section", item_li).show();
  }

  var itemEdit = function() {
    var item_li = $(this).parent().parent();
    $(".item-show-section", item_li).hide();
    $(".item-edit-section", item_li).show();
    $(".item-edit-input", item_li).focus();
  }

  var itemUpdate = function() {
    var item_li = $(this).parent().parent();
    $.post("/lists/"+$(".item-id", item_li).val()+".json", { "_method": "PUT", "item": { "name": $(".item-edit-input", item_li).val() }}, function(item) {
      var item_li = $(".item-id[value="+item.id+"]").parent();
      $(".item-text", item_li).html(item.name);
      $(".item-edit-input", item_li).val(item.name);
      $(".item-edit-section", item_li).hide();
      $(".item-show-section", item_li).show();
    });
    // TODO: error handling
  }

  var itemRemove = function() {
    if (confirm("Are you sure?")) {
      var item_li = $(this).parent().parent();
      $.ajax({
        url: "/lists/"+$(".item-id", item_li).val(),
        type: "DELETE",
        success: function(result) {
          item_li.remove();
        }
      })
    }
  }

  $("#add-item").keypress(function(event) {
    if (event.which == 13) {
      event.preventDefault();
      var newItem = $("#add-item");
      if (newItem.val() == '') { return; }

      $.post("/lists.json", { 'item': { 'name': newItem.val() }}, function(item) {
        var tr = $("#item-template tr").clone();
        $(".item-id", tr).val(item.id);
        $(".item-text", tr).html(item.name);
        $(".item-edit-input", tr).val(item.name);
        $("#list-items tr:last").after(tr);
        $(".item-cancel", tr).click(itemCancel);
        $(".item-edit", tr).click(itemEdit);
        $(".item-update", tr).click(itemUpdate);
        $(".item-remove", tr).click(itemRemove);
        newItem.val('');
      });
    }
  });

  $(".item-cancel").click(itemCancel);
  $(".item-edit").click(itemEdit);
  $(".item-update").click(itemUpdate);
  $(".item-remove").click(itemRemove);
  $(".item-edit-section").hide();

  $("#list-items tbody").sortable({
    axis: "y",
    cursor: "move",
    delay: 150,
    deactivate: function(event, tr) {
      $.post("/lists/"+$(".item-id", tr.item).val()+"/reposition.json", { "_method": "PUT", "position": $( "#list-items tr" ).index(tr.item)+1 });
      // TODO: error handling
    }
  });

});

