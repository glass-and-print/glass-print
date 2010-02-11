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

function getDealData(additionalAttrClass) {
  return { collection: $.trim($("#collection-name").html()),
           piece:      $.trim($(".product-title").val())
                       + (additionalAttrClass == undefined
                          ? ""
                          : (" [" + $("." + additionalAttrClass).val() + "]")),
           email:      getTextFieldVal("haggler-email"),
           offer:      getTextFieldVal("haggler-offer") };
}

// FIXME -- if jaml.js does not appear before deal.js
//          in the html source 'includes' this blows up
//          with 'Jaml is not defined'
Jaml.register('make-a-deal', function(dealModel) {
  table({cls: 'haggle-dialog'},
    tr(
      td('Make a deal with Glass & Print.', br(),
         'It\'s easy!',                     br(),
         'Choose the poster or vase you',   br(),
         'love and name your price.',       br(),
         'Send us your offer and we will',  br(),
         'email you back within a day.'),
      td(img({src: '/images/vert-pink.jpg'})),
      td(table(
           tr(
             td('Collection:'),
             td(dealModel.collection)
           ),
           tr(
             td('Piece:'),
             td(dealModel.piece)
           ),
           tr(
             td('Your email:'),
             td(input({ id:      'haggler-email',
                        type:    'text',
                        size:    '20',
                        maxsize: '50',
                        value:   dealModel.email }))
           ),
           tr(
             td('Your offer [US$]:'),
             td(input({ id:      'haggler-offer',
                        type:    'text',
                        size:    '20',
                        maxsize: '50',
                        value:   dealModel.offer}))
           )
         )
      )
    )
  );
});

function dealListener(additionalAttrClass) {
  var haggleDialog = $("#haggle-div");
  haggleDialog.html(Jaml.render('make-a-deal', getDealData(additionalAttrClass)));
  haggleDialog.dialog({ width: 480,
                        modal: true,
                        zIndex: 1000000,
                        buttons: { "Send" : function() {
                                              $.ajax({ type: 'POST',
                                                       url: '/cgi-bin/deal.pl',
                                                       data: getDealData(additionalAttrClass),
                                                       dataType: 'html',
                                                       success: function(data) {
                                                         haggleDialog.html(data);
                                                         haggleDialog.dialog('option', 'buttons', {});
                                                       },
                                                       error: function(xhr, textStatus, errorThrown) {
                                                         haggleDialog.html(xhr.responseText
                                                                           + Jaml.render('make-a-deal',
                                                                                         getDealData(additionalAttrClass)));
                                                       }
                                                     });
                                            }
                                 }
                      }); 
}
