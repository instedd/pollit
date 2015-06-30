$(document).ready(function() {
  $('#numberText').placeholder();
  $(":input[type=text]").live('focus', function() {
    $(this).numeric({ decimal: false, negative: false });
  });
});

if (typeof angular !== 'undefined') {
  angular.module('pollitApp', ['ngFileUpload']).controller('PhonesCtrl', ['$scope', '$http', function($scope, $http) {
    var _this = this;

    $scope.phones_list = [];
    $scope.new_phones = [];
    $scope.only_add = !!gon.can_edit;
    $scope.hub_fields = [];
    $scope.hub_status = 'pending';

    $scope.csv_fields = [];
    $scope.csv_status = null;

    $scope.connected_hub_fields = gon.poll.hub_respondents_phone_field;
    $scope.connected_hub_path = gon.poll.hub_respondents_path;

    $scope.$watch('hub_phone_field', function(val) {
      $scope.hub_status = (val && _.isEqual(val.path(), $scope.connected_hub_fields) && $scope.hub_path == $scope.connected_hub_path) ? 'connected' : 'pending';
    });

    $scope.$watch('files', function(files) {
      if (files && files.length > 0) {
        var reader = new FileReader();
        reader.onload = function(event) {
          var csv = event.target.result;
          var data = $.csv.toArrays(csv);
          _this.csv_data = data;

          $scope.$apply(function($scope) {
            $scope.csv_fields = _.map(data[0], function(field, index) { return {name: field, index: index} });
            $scope.csv_phone_field = _.find($scope.csv_fields, function(field) { return field.name.match(/phone/i) }) || $scope.csv_fields[0];
          });
        }
        reader.readAsText(files[0]);
      }
    });

    $scope.$watch('csv_phone_field', function(field) {
      if (!_this.csv_data || !field) return;
      $scope.csv_preview = _.map(_.rest(_.first(_this.csv_data, 5)), function(row) { return row[field.index] });
    });

    $(document).ready(function() {
      window.setTimeout(function() {
        $("#numberText").focus().blur();
      }, 200);

      if(gon.poll.hub_respondents_path) {
        $scope.hub_status = 'connected';
        $scope.reflectPath(gon.poll.hub_respondents_path, gon.poll.hub_respondents_phone_field);
      }
    });

    $scope.submitUpload = function() {
      $scope.csv_status = 'uploading';
      var phones = _.map(_this.csv_data, function(row) { return row[$scope.csv_phone_field.index] });
      $scope.savePhones(phones, true, function() {
        $scope.show_upload_csv = false;
        $scope.csv_phone_field = null;
        $scope.csv_fields = [];
        $scope.csv_status = null;
        _this.csv_data = [];
      });
    };

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

    $scope.saveChanges = function(showNotice) {
      $scope.removeEmptyPhones();
      var phones = _.map($scope.new_phones, function(phone) { return phone.number });
      $scope.savePhones(phones, showNotice, function() {
        $scope.new_phones = [];
        $scope.show_add_respondents = false;
      });
    };

    $scope.savePhones = function(phones, showNotice, onComplete) {
      $http.post(gon.add_phones_poll_respondents_path, {'phones': phones})
        .success(function(data) {
          if (showNotice) $.status.showNotice(phones_saved_successfully, 6000);
          $scope.reloadPhones();
          if (onComplete) onComplete();
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
};
