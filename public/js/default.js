function del_like(id) {
	$.ajax({
		url: '/entry/'+id+'/like',
		type: 'DELETE',
		success: function(result) {
			location.href="/";
		}
	});
}

function del_entry(id) {
	if(window.confirm('本当に削除してよろしいいですか？'))
	{
		$.ajax({
			url: '/entry/'+id,
			type: 'DELETE',
			success: function(result) {
				location.href="/";
			}
		});
	}
}

function del_user(id) {
	if(window.confirm('本当に削除してよろしいいですか？'))
	{
		$.ajax({
			url: '/user',
			type: 'DELETE',
			success: function(result) {
				location.href="/";
			}
		});
	}
}

function toggle_response(id) {
	 $("#res"+id).toggle();
}

$(function(){
	$('.entry-body').autolink();
});
