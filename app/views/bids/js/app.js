
/*
 * Model of a set of Players to be selected into a team
 */
var TeamModel = {
		
		//this is manually set for testing purposes for now
		arrPlayers: [
	                   {fname:"Vincent", lname:"Kompany", position:"DEF"},
	                   {fname:"Wayne", lname:"Rooney", position:"FWD"},
	                   {fname:"Juan", lname:"Mata", position:"MID"},
	                   {fname:"Dalay", lname:"Blind", position:"DEF"},
	                   {fname:"Eden", lname:"Hazard", position:"FWD"},
	                   {fname:"Riyad", lname:"Mahrez", position:"MID"},
	                   {fname:"Jamie", lname:"Vardy", position:"FWD"},
	                   {fname:"John", lname:"Terry", position:"DEF"},
	                   {fname:"Aaron", lname:"Ramsey", position:"MID"},
	                   {fname:"Mesut", lname:"Ozil", position:"MID"},
	                   {fname:"Chris", lname:"Smalling", position:"DEF"},
	                   {fname:"Petr", lname:"Cech", position:"GK"}
	                 ],
		
		
		
		
		
		//get players from server
		getPlayers: function(){
			//TODO following is just a static array for testing purposes
			//TeamModel.arrPlayers = [];
			
			
		},
		
		//initialize this model
		init: function(){
			TeamModel.getPlayers();
		}
		
};


/*
 * jQuery functions once doc is ready
 */
$(document).ready(function(){
	TeamModel.init();
	$(".player-box").draggable({
		stack: '.player-box',
		appendTo: "body",
	    helper: "clone",
		revert: 'invalid'
	});
	$(".field-row").droppable({
		hoverClass: "highlight",
		//specify what happens in the drop event
		drop: function(event, ui){
			console.log("event obj: ", event);
			console.log("ui dom: ", ui);
			
			if( ($(ui.draggable).hasClass( "player-GK" ))&&($(this).hasClass( "field-row-one" ))
			 || ($(ui.draggable).hasClass( "player-DEF" ))&&($(this).hasClass( "field-row-two" )) 
			 || ($(ui.draggable).hasClass( "player-MID" ))&&($(this).hasClass( "field-row-three" ))
			 || ($(ui.draggable).hasClass( "player-FWD" ))&&($(this).hasClass( "field-row-four" ))
			){
				$(this).append(ui.draggable);
			}
		}
		
	});
	
	
});

/*
 * Angular functions
 */

var PlayerSelApp = angular.module("PlayerSelApp", []);

//bench controller
PlayerSelApp.controller("benchController", function($scope){
	$scope.arrPlayers = TeamModel.arrPlayers;
});

//field controller
PlayerSelApp.controller("fieldController", function($scope){
	
});

