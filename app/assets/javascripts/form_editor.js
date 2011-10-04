function add_field_option(link, index, content) {
  var field = get_field(index);
  var container = $(link).closest('.feditor-form');
  var input = container.find('.feditor-form-option-new input');
  var new_id = input.val();
  input.val('');  
  add_field(index, new_id, container.find('.feditor-form-options'), content);
}

function remove_field_option(link) {
  $(link).closest('.feditor-form-option').remove();
}

function add_field(index, new_id, container, content) {
  var field = get_field(index);
  var sidebar = $('.feditor-sidebar input:visible');
  if(field.length == 0 || (!sidebar.valid || sidebar.valid())) {
  	$('.fieldadd').attr('id', '');
  	$('.fieldslist').removeClass('large');
    $('.feditor-sidebar').show();
    var regexp = new RegExp(index, "g");
    $(container).append(content.replace(regexp, new_id));
  }
}

function remove_field(index) {
  $('#feditor-' + index).remove();
  $('#feditor-form-' + index).remove();
  select_field($('.feditor-list .feditor:last').attr('data-field-index'));
  if ($('.feditor-list .feditor').size()==0){
  	$('.feditor-sidebar').hide();	
  	$('.fieldadd').attr('id', 'large');
  	$('.feditor-list').addClass('large');
  }
}

function select_field(index) {
  var field = get_field(index);
  if (field.length == 0) return;
  var last_sidebar = $('.feditor-sidebar input:visible');
  if(last_sidebar.size() == 0 || (!last_sidebar.valid || last_sidebar.valid())) { 
  	$('.feditor-button button').removeClass('active');
  	$('.feditor-button button', field).addClass('active');

  	$('.feditor-form').hide();
  	$('#feditor-form-' + index).show();
  }
}

function get_field(index) {
  return $('#feditor-' + index);
}

function get_form_index(node) {
  return $(node).closest('.feditor-form').attr('data-field-index');
}

function get_field_for_form(node) {
  return get_field(get_form_index(node));
}

function sync_field_properties(clazz, contentf) {
  $('.feditor-form input'+clazz).live('keyup change', function(){
    var val = contentf ? contentf($(this)) : $(this).val();
    $(clazz, get_field_for_form(this)).html(val);
  });
}

function sync_field_check(clazz) {
  $('.feditor-form input'+clazz).live('click', function(){
    $(clazz, get_field_for_form(this)).toggle($(this).is(':checked'));
  });
}

$(function() {
  $('.feditor').live("click", function() {
    var index = $(this).attr('data-field-index');
    select_field(index)
    return false;
  }).click();

  sync_field_properties('.feditor-field-name');
  sync_field_properties('.feditor-field-hint', function(hint){
    return hint.val() ? "Description: " + hint.val() : "";
  });
  
  sync_field_check('.feditor-field-required');

  select_field(0);
});


