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

function getFindRequestData(options) {
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
      if (i != 0) {
        pieceIdentity += ",";
      }
      var attributeSelector = options['id'] == undefined
                              ? ("." + additionalAttributes[i])
                              : ("#" + additionalAttributes[i] + "-" + options['id']);
      if ($(attributeSelector).val() != undefined) {
        pieceIdentity += $(attributeSelector).val();
      }
    }
    pieceIdentity += "]";
  }

  var collectionName = $.trim($("#collection-name").html())
                       || $.trim($("#collection-name").attr('value'));

  return { collection : collectionName,
           piece      : pieceIdentity,
           email      : getTextFieldVal("user-email") };
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
                        size:    '37',
                        maxsize: '50',
                        value:   findModel.email }))
           )
         )
      )
    )
  );
});

function findRequestListener(options) {
  var requestDialog = $("#request-div");
  requestDialog.html(Jaml.render('find-request', getFindRequestData(options)));
  requestDialog.dialog({ width: 520,
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
                                                                                           getFindRequestData(options)));
                                                        }
                                                      });
                                             }
                                  }
                       });
}

