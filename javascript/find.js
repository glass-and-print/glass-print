function getTextFieldVal(textFieldId) {
  var result = $("#" + textFieldId).val();
  if (result == undefined) {
    result = "";
  }
  else {
    result = $.trim(result);
  }
  return result;
}

function getFindRequestData() {
  return { collection: $.trim($("#collection-name").html()),
           piece:      $.trim($(".product-title").val()),
           email:      getTextFieldVal("user-email") };
}


Jaml.register('find-request', function(findModel) {
  table({cls: 'haggle-dialog'},
    tr(
      td('You love a poster or a vase',   br(),
         'but it is not available. Just', br(),
         'ask us to find it for you.'),
      td(img({src: '/images/vert-pink-shorter.jpg'})),
      td(table(
           tr(
             td('Collection:'),
             td(findModel.collection)
           ),
           tr(
             td('Piece:'),
             td(findModel.piece)
           ),
           tr(
             td('Your email:'),
             td(input({ id:      'user-email',
                        type:    'text',
                        size:    '20',
                        maxsize: '50',
                        value:   findModel.email }))
           )
         )
      )
    )
  );
});

function findRequestListener() {
  var requestDialog = $("#request-div");
  requestDialog.html(Jaml.render('find-request', getFindRequestData()));
  requestDialog.dialog({ width: 420,
                         modal: true,
                         buttons: { "Send" : function() {
                                               $.ajax({ type: 'POST',
                                                        url: '/cgi-bin/find.pl',
                                                        data: getFindRequestData(),
                                                        dataType: 'html',
                                                        success: function(data) {
                                                          requestDialog.html(data);
                                                          requestDialog.dialog('option', 'buttons', {});
                                                        },
                                                        error: function(xhr, textStatus, errorThrown) {
                                                          requestDialog.html(xhr.responseText
                                                                             + Jaml.render('find-request',
                                                                                           getFindRequestData()));
                                                        }
                                                      });
                                             }
                                  }
                       });
}

