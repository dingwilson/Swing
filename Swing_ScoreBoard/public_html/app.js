var app = angular.module("swing", ["firebase"]);

app.controller("swingCtrl", function($scope, $firebaseArray, $firebaseObject, $http) {
  var current = firebase.database().ref().child("data");
  // download the data into a local object
  var syncObject = $firebaseObject(current);
  syncObject.$bindTo($scope, "data");

  var allplayers = firebase.database().ref().child("record");
  var list = $firebaseObject(allplayers);
  list.$bindTo($scope,"record");

  var obj = $firebaseObject(current);
  var unwatch = obj.$watch(function() {
    console.log('Data changed'); 
    if ($scope.record['first']['score'] < parseInt($scope.data.score, 10)) {
      $scope.record['third'] = $scope.record['second'];
      $scope.record['second'] = $scope.record['first'];
      $scope.record['first'] = $scope.data; 
      $scope.data = {};
    }
    else if ($scope.record['second']['score'] < parseInt($scope.data.score, 10)) {
      $scope.record['third'] = $scope.record['second'];
      $scope.record['second'] = $scope.data;
      $scope.data = {};

    }
    else if ($scope.record['third']['score'] < parseInt($scope.data.score, 10)) {
      $http.get('http://flask-env.czkykzdpwg.us-west-2.elasticbeanstalk.com/out/' + $scope.record['third'].current, config);
      $scope.record['third'] = $scope.data;
      $scope.data = {};
    }
  });

});
