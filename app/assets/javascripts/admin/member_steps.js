$(document).on("turbolinks:load", function() {

    $("#paystack-button").click(function(event) {

        payWithPaystack();
    })

    function payWithPaystack(){
        
        var handler = PaystackPop.setup({
            key: gon.publicKey,
            email: gon.email,
            amount: gon.amount,
            // ref: ''+Math.floor((Math.random() * 1000000000) + 1), // generates a pseudo-unique reference. Please replace with a reference you generated. Or remove the line entirely so our API will generate one for you
            firstname: gon.firstName,
            lastname: gon.lastName,
            // label: "Optional string that replaces customer email"
            metadata: {
                custom_fields: [
                    {
                        display_name: "Mobile Number",
                        variable_name: "mobile_number",
                        value: gon.value
                    }
                ]
        },
        callback: function(response){
            // alert('success. transaction ref is ' + response.reference);
            var data = {reference_code: response.reference}
            $.ajax({
                url: '/admin/paystack_subscribe',
                type: 'POST',
                data: data,
                success: function(data, textStatus, xhr) {
                             content = `<div class="card-body">
                                             <button class="tst2 btn btn-warning">Payment and Membership Successful!</button>
                                        </div>`
                             $('#paystack-success').append(content)
                             $("#payment-next").fadeIn('fast')
                         },
                error: function() {
                        alert("Ajax error!")
                      }
            })
        },
        onClose: function(){
            alert('window closed');
        }
        });
        handler.openIframe();
  }
        
 });
