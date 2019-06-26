	function say(s){	
		if(0==jQuery("#bf-speaker").length){
			jQuery('<div>').attr("id","bf-speaker").css({height:"0px",width:"0px"}).attr("aria-live","polite").attr("aria-atomic","true").attr("aria-relevant","additions text").appendTo('body');
		}
		jQuery("#bf-speaker").text('');
		setTimeout(function(){jQuery("#bf-speaker").text(s);},100);
	}
		
    jQuery(document).on("controls:initialized", function(event, controlsViewModel) {
		
		console.log("%c[508]controls:initialized", "color:red");
		
		//when to draw an input control dialog
        controlsViewModel.draw = function (jsonStructure) {

            var drawControl = function (container, jsonControl) {
                if (jsonControl.visible) {
                    var control = this.findControl({id:jsonControl.id});
                    container.append(control.getElem());
                }
            };

            _.each(jsonStructure, _.bind(drawControl, this, jQuery("#inputControlsContainer")));

			//if(typeof _bf508Enbabled != 'undefined' && _bf508Enbabled == 'y')
			{
				// Single Select Field
				//set readonly to a typeahead field (textbox)
				jQuery(".sSelect-sSearch > .searchLockup > .wrap input").prop('readonly',true);
				//Hide the textbox (move up the list items)
				jQuery(".sSelect-sSearch > .searchLockup > .wrap").css('height','0px');
				jQuery(".sSelect-listContainer").css('height','0px');
				
				
				// Date Field
				jQuery("#inputControls .ui-datepicker-trigger").remove();
				jQuery("#inputControls .button.picker.calTriggerWrapper").remove();				
				jQuery("#inputControls INPUT.date.hasDatepicker").attr("aria-label","Type in date in the format MM/DD/YYYY.");				
				
			}
        };

        controlsViewModel.update = function (state) {			
			if(typeof state != 'undefined' && typeof state["TIMEZONE"] != 'undefined' && typeof state["TIMEZONE"].values != 'undefined'){
				try{
					if (typeof _bfUserTimezone != 'undefined' && _bfUserTimezone != "null" && _bfUserTimezone != ""){
						state["TIMEZONE"].values = _bfUserTimezone;
					}
					else{
						state["TIMEZONE"].values = Intl.DateTimeFormat().resolvedOptions().timeZone;
					}
				}catch(e){
					state["TIMEZONE"].values = "EST";
				}
			}

            _.each(state, function (controlState, controlId) {
                var control = this.findControl({id:controlId});
				if(control.type == "singleSelect"){
					_.each(controlState.values, function(v){
						if(v.value == "~NOTHING~"){
							v.label = "Select One";
							return false;
						}
					});
				}
                control.set({
                    "values": controlState.values,
                    "error" : controlState.error
                });
            }, this);
        };

    });
