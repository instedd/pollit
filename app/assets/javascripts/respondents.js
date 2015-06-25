$(document).ready(function() {
  $('#numberText').placeholder();
  $(":input[type=text]").live('focus', function() {
    $(this).numeric({ decimal: false, negative: false });
  });
});

angular.module('pollitApp', []).controller('PhonesCtrl', ['$scope', '$http', function($scope, $http) {
  $scope.phones_list = [];
  $scope.new_phones = [];
  $scope.only_add = !!gon.can_edit;
  $scope.hub_fields = [];
  $scope.hub_status = 'pending';

  $scope.connected_hub_fields = gon.poll.hub_respondents_phone_field;
  $scope.connected_hub_path = gon.poll.hub_respondents_path;

  $scope.$watch('hub_phone_field', function(val) {
    $scope.hub_status = (val && _.isEqual(val.path(), $scope.connected_hub_fields) && $scope.hub_path == $scope.connected_hub_path) ? 'connected' : 'pending';
  });

  $(document).ready(function() {
    window.setTimeout(function() {
      $("#numberText").focus().blur();
    }, 200);

    if(gon.poll.hub_respondents_path) {
      $scope.hub_status = 'connected';
      $scope.reflectPath(gon.poll.hub_respondents_path, gon.poll.hub_respondents_phone_field);
    }

    new AjaxUpload($('#import_csv'), {
      action: gon.import_csv_poll_respondents_path,
      name: 'csv',
      onSubmit: function(file, ext){
        if(ext != 'csv') {
          $.status.showError(file_should_be_in_csv_format, 6000)
          return false;
        }
      },
      onComplete: function(file, response){
        var data = eval(response);
        $.each(data, function(i, phone) {
          if (!$scope.phoneExists(phone.number)) {
            $scope.phones.push(phone);
          }
        });
        $scope.$eval();
        $(".ng-directive #numberText").focus().blur();
        $.status.showNotice(file_successfully_uploaded, 6000);
      }
    });
  });

  $scope.phoneExists = function(phoneNumber) {
    return _.any($scope.new_phones, function(phone) {
      return phone.number == phoneNumber;
    });
  }

  $scope.addPhone = function() {
    if ((!$scope.phoneExists($scope.numberText)) && $.trim($scope.numberText) != '') {
      $scope.new_phones.push({number:$scope.numberText});
      $scope.numberText = '';
    }
  };

  $scope.chooseHubAction = function() {
    $scope.hub_status = 'pending';
    hubApi = new HubApi(gon.hub_url, '/hub');
    hubApi.openPicker('entity_set').then(function(path, selection) {
      $scope.reflectPath(path);
    });
  };

  $scope.reflectPath = function(path, selection) {
    hubApi = new HubApi(gon.hub_url, '/hub');
    hubApi.reflect(path).then(function(reflect_result) {
      $scope.$apply(function($scope) {
        $scope.hub_fields = [];
        $scope.hub_path = path;
        $scope.hub_label = reflect_result._data.path.replace(/\//g, ' → ');
        reflect_result.visitEntity(function(field) {
          $scope.hub_fields.push(field);
          if (_.isEqual(field.path(),selection)) {
            $scope.hub_phone_field = field;
          }
        });
      });
    });
  };

  $scope.connectHub = function() {
    $scope.hub_status = 'connecting'
    $http.post(gon.connect_hub_path, {path: $scope.hub_path, phone_field: $scope.hub_phone_field.path()})
      .success(function() {
        $scope.hub_status = 'connected';
        $scope.connected_hub_fields = $scope.hub_phone_field.path()
        $scope.connected_hub_path = $scope.hub_path;
        $.status.showNotice(hub_connected_successfully, 6000)
      })
      .error(function() {
        $scope.hub_status = 'pending'
        $.status.showError(hub_connected_error, 6000)
      });
  };

  $scope.clearHubAction = function() {
    var delete_respondents = gon.can_edit && confirm(confirm_delete_respondents);
    $http.post(gon.clear_hub_path, {delete_respondents: delete_respondents})
      .success(function() {
        $.status.showNotice(hub_disconnected_successfully, 6000)
        $scope.hub_path = null;
        $scope.hub_label = null;
        $scope.hub_fields = [];
        $scope.hub_status = 'pending';
      })
      .error(function() {
        $.status.showError(hub_disconnected_error, 6000)
      });
  };

  $scope.removeEmptyPhones = function() {
    $scope.new_phones = _.reject($scope.new_phones, function(phone) {
      return $.trim(phone.number) == '';
    })
  }

  $scope.saveChanges = function(showNotice, nextUrl) {
    $scope.removeEmptyPhones();
    var phones = _.map($scope.new_phones, function(phone) { return phone.number });
    $http.post(gon.add_phones_poll_respondents_path, {'phones': phones})
      .success(function(data) {
        $scope.new_phones = [];
        $scope.show_add_respondents = false;
        if (showNotice) $.status.showNotice(phones_saved_successfully, 6000);
        $scope.reloadPhones();
      })
      .error(function() {
        $.status.showError(error_saving_phones, 6000);
      });
  };

  $scope.clearChanges = function() {
    $scope.new_phones = [];
  };

  $scope.reloadPhones = function() {
    $.getScript(gon.respondents_path);
  };

}]);
