$(document).ready(function () {
	// Add validator
	//$('.validate-form').bootstrap3Validate( abcmfFormsSubmit );

	// Process duration inputs 
	var fc = $('.duration-value');
	fc.each(function(){
		var id = this.id;
		var duration_id = id.substring(2);
		$(this).html($('#'+duration_id).val());
		$('#'+duration_id).change(function() {
			$('#'+id).html( $(this).val());
		});
		return;
	});
});

function addnewrow(tableId)
{
	var table = $('#'+tableId);
	var tbody = table.find("tbody");
	var firstRow = tbody.find("tr:first");
	var template = firstRow.html();
	var lastRow = tbody.find("tr:last");
	lastRow.before("<tr>"+template+"</tr>");
}

function abcmfFormsSubmit(e,data)
{
	e.preventDefault();
	var form = $(this);
}