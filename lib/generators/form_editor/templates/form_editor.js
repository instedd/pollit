function add_field_option(link, index, content) {
  var field = get_field(index);
  var container = $(link).closest('.fieldform');
  var input = container.find('.newfieldoption input');
  var new_id = input.val();
  input.val('');  
  add_field(index, new_id, container.find('.fieldoptions'), content);
}

function remove_field_option(link) {
  $(link).closest('.fieldoption').remove();
}

function add_field(index, new_id, container, content) {
  var field = get_field(index);
  var sidebar = $('form .fieldsidebar input:visible');
  if(field.length == 0 || (!sidebar.valid || sidebar.valid())) {
  	$('.fieldadd').attr('id', '');
  	$('.fieldslist').removeClass('large');
    $('.fieldsidebar').show();
    var regexp = new RegExp(index, "g");
    $(container).append(content.replace(regexp, new_id));
  }
}

function remove_field(index) {
  $('#field_' + index).remove();
  $('#field_form_' + index).remove();
  select_field($('.fieldspresenter .field:last').attr('data-field-index'));
  if ($('.fieldspresenter .field').size()==0){
	$('.fieldsidebar').hide();	
	$('.fieldadd').attr('id', 'large');
	$('.fieldslist').addClass('large');
  }
}

function select_field(index) {
  var field = get_field(index);
  if (field.length == 0) return;
  var last_sidebar = $('form .fieldsidebar input:visible');
  if(last_sidebar.size() == 0 || (!last_sidebar.valid || last_sidebar.valid())) { 
  	$('.fieldimg').removeClass('selected');
  	$('.fieldimg', field).addClass('selected');

  	$('.fieldform').hide();
  	$('#field_form_' + index).show();
  }
}

function get_field(index) {
  return $('#field_' + index);
}

function get_form_index(node) {
  return $(node).closest('.fieldform').attr('data-field-index');
}

function get_field_for_form(node) {
  return get_field(get_form_index(node));
}

function sync_field_properties(clazz, contentf) {
  $('.fieldform input'+clazz).live('keyup change', function(){
    var val = contentf ? contentf($(this)) : $(this).val();
    $(clazz, get_field_for_form(this)).html(val);
  });
}

function sync_field_check(clazz) {
  $('.fieldform input'+clazz).live('click', function(){
    $(clazz, get_field_for_form(this)).toggle($(this).is(':checked'));
  });
}

$(function() {
  $('.field_type').live("change", function() {
    var val = $(this).val();
    var show = (val == "choose_one" || val == "select_multiple");
    $(this).parent("li").find(".options").toggle(show);
  }).change();  

  $('.field').live("click", function() {
    var index = $(this).attr('data-field-index');
    select_field(index)
  }).click();

  sync_field_properties('.fieldname');
  sync_field_properties('.fieldhint', function(hint){
    return hint.val() ? "Hint: " + hint.val() : "";
  });
  
  sync_field_check('.fieldrequired');

  select_field(0);
});


