// TODO unit test 

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

function getDealData(options) {
  var pieceIdentity = undefined;
  if (options == undefined || options.id == undefined) {
    pieceIdentity = $.trim($(".product-title").val());
  }
  else {
    pieceIdentity = $.trim($("#product-title-" + options.id).val());
  }

  var additionalAttributes = options == undefined || options.additionalAttributes == undefined
                             ? undefined
                             : options.additionalAttributes;
  if (additionalAttributes != undefined
      && additionalAttributes.length > 0) {
    pieceIdentity += " [";
    for (var i = 0; i < additionalAttributes.length; i++) {
      var attributeSelector = options.id == undefined
                              ? ("." + additionalAttributes[i])
                              : ("#" + additionalAttributes[i] + "-" + options.id);
      if ($(attributeSelector).val() != undefined) {
        if (i != 0) {
          pieceIdentity += ",";
        }
        pieceIdentity += $(attributeSelector).val();
      }
    }
    pieceIdentity += "]";
  }

  var collectionName = $.trim($("#collection-name").html())
                       || $.trim($("#collection-name").attr('value'));
  return { collection : collectionName,
           piece      : pieceIdentity,
           email      : getTextFieldVal("haggler-email"),
           offer      : getTextFieldVal("haggler-offer") };
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
                        size:    '32',
                        maxsize: '50',
                        value:   dealModel.email }))
           ),
           tr(
             td('Your offer [US$]:'),
             td(input({ id:      'haggler-offer',
                        type:    'text',
                        size:    '32',
                        maxsize: '50',
                        value:   dealModel.offer }))
           )
         )
      )
    )
  );
});

function dealListener(options) {
  var haggleDialog = $('#haggle-div');
  haggleDialog.html(Jaml.render('make-a-deal', getDealData(options)));
  haggleDialog.dialog({ width:   550,
                        modal:   true,
                        // this depends on the feedback and google cart divs having a zIndex
                        // that is less than this [to avoid superimposing them on top of the
                        // deal dialog]
                        // Unfortunately google does not allow overriding the z-index property
                        // which is 1e+06 and if we set the z-index property of this dialog to
                        // more than a million the text inputs become unresponsive in Chrome
                        // and Safari 
                        //zIndex:  500000,
                        buttons: { 'Send' : function() {
                                              $.ajax({ type: 'POST',
                                                       url: '/cgi-bin/deal.pl',
                                                       data: getDealData(options),
                                                       dataType: 'html',
                                                       success: function(data) {
                                                         haggleDialog.html(data);
                                                         haggleDialog.dialog('option', 'buttons', {});
                                                       },
                                                       error: function(xhr, textStatus, errorThrown) {
                                                         haggleDialog.html(xhr.responseText
                                                                           + Jaml.render('make-a-deal',
                                                                                         getDealData(options)));
                                                       }
                                                     });
                                            }
                                 }
                      }); 
}
