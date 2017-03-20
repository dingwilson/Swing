var app = angular.module("swing", ["firebase"]);

app.controller("swingCtrl", function($scope, $firebaseObject, $http) {
  var ref = firebase.database().ref().child("data");
  // download the data into a local object
  var syncObject = $firebaseObject(ref);
  syncObject.$bindTo($scope, "data");

    $scope.beginSwing = function(){
        $http.get('http://flask-env.czkykzdpwg.us-west-2.elasticbeanstalk.com/joined/' + $scope.data.current, config);
        $scope.nextStep = true;
  }

  var gyro = firebase.database().ref().child("values").child("gyro");
  var syncObject = $firebaseObject(gyro);
  syncObject.$bindTo($scope, "gyro");

  var obj = $firebaseObject(ref);
  var unwatch = obj.$watch(function() {
    $scope.nextStep = false;
  });

});
