$(document).ready(function() {
  $('#numberText').placeholder();
  $(":input[type=text]").live('focus', function() {
    $(this).numeric({ decimal: false, negative: false });
  });
});

angular.module('pollitApp', []).controller('PhonesCtrl', ['$scope', function($scope) {
  $scope.phones = gon.can_edit ? gon.phones : [];
  $scope.fixed_phones = gon.can_edit ? [] : gon.phones;
  $scope.only_add = !!gon.can_edit;
  $scope.hub_fields = []
  $scope.hub_phone_field = null
  $scope.numberText = ''


  $(document).ready(function() {
    window.setTimeout(function() {
      $("#numberText").focus().blur();
    }, 200);

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
    var all_phones = _.union($scope.fixed_phones, $scope.phones);
    return _.any(all_phones, function(phone) {
      return phone.number == phoneNumber;
    });
  }

  $scope.addPhone = function() {
    if ((!$scope.phoneExists($scope.numberText)) && $.trim($scope.numberText) != '') {
      $scope.phones.push({number:$scope.numberText});
      $scope.numberText = '';
    }
  };

  $scope.chooseHubAction = function() {
    hubApi = new HubApi(gon.hub_url, '/hub');
    hubApi.openPicker('entity_set').then(function(path, selection) {
      return hubApi.reflect(path).then(function(reflect_result) {
        $scope.$apply(function($scope) {
          $scope.hub_fields = [];
          $scope.hub_entity_set = reflect_result.toJson()
          reflect_result.visitEntity(function(field) {
            $scope.hub_fields.push(field);
          });
        });
      });
    });
  };

  $scope.clearHubAction = function() {
    $scope.hub_entity_set = null;
    $scope.hub_fields = [];
  }

  $scope.removePhone = function(phoneNumber) {
    $scope.phones = _.reject($scope.phones, function(phone) {
      return phone.number == phoneNumber;
    });
    $(".ng-directive #numberText").focus().blur();
  }

  $scope.removeEmptyPhones = function() {
    $scope.phones = _.reject($scope.phones, function(phone) {
      return $.trim(phone.number) == '';
    })
  }

  $scope.saveChanges = function(showNotice, nextUrl) {
    $scope.removeEmptyPhones();
    var phones = _.map($scope.phones, function(phone) { return phone.number });
    $.post(gon.batch_update_poll_respondents_path, {'phones': phones}, function(data, textStatus) {
      if (textStatus == "success") {
        $scope.onSaved();
        if (showNotice) $.status.showNotice(phones_saved_successfully, 6000);
        if (nextUrl) location.href = nextUrl;
      } else {
        $.status.showError(error_saving_phones, 6000);
      }
    });
  };

  $scope.onSaved = function() {
    if ($scope.only_add) {
      var current_phones = $scope.phones;
      $scope.phones = [];
      angular.forEach(current_phones, function(phone) {
        $scope.fixed_phones.push(phone);
      });
    }
  }

  $scope.nextStep = function() {
    $scope.saveChanges(false, gon.poll_path);
  }
}]);
