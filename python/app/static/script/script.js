$(document).ready(function(){

	$("#sentButton").click(function(){ // click event
		alert('bla');
		$.ajax({
			url: '/cesar',
			data: {'cifra':$('#textInput')},
			type: 'POST',
			success: function(response) {
				console.log('Sent Request')
			},
			error: function(error) {
				console.log(error)
			}
		});
	})

	$( "#target" ).click(function() {
	  //alert('bla');
		$.ajax({
			url: "/cesar",
			data: '{"cifra":"textInput"}',
			type: "POST",
			contentType: "application/json",
            dataType: "json"
		});
		//alert('end');
	});
})

//data: {'cifra':$('#textInput')},