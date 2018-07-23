function take_snapshot(){
    Webcam.snap(function(data_uri) {

        $('.loader').modal('show');

        id = $('[id*="_image"]');

        if (id.length) {
            id.val(data_uri);
        }
        data = { image: data_uri}   
        $.ajax({
            url: '/admin/upload_image',
            type: 'POST',
            data: data,
            success: function(data, textStatus, xhr) {
                         $('.loader').modal('hide');
                         content = `<div class="card-body">
                                         <button class="tst2 btn btn-success">${data.message}</button>
                                    </div>`
                         $('#image_upload-status').append(content)
                         $("#image_capture-next").fadeIn('fast')
                     },
            error: function(data) {
                $('.loader').modal('hide');
                content = `<div class="card-body">
                                    <button class="tst2 btn btn-danger">${data.message}</button>
                            </div>`
                $('#image_upload-status').append(content)

            }
        })

        document.getElementById('results').innerHTML = '<img src="' + data_uri + '"/>';
    });
}
$(document).ready(function() {
    if ($("#my_camera").length) {
        Webcam.set({
            width: 320,
            height: 240,
            image_format: 'jpeg',
            jpeg_quality: 90
        });
        Webcam.attach('#my_camera');
    }
});