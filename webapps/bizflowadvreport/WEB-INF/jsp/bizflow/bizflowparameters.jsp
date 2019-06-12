<jsp:include page="../modules/inputControls/InputControlTemplates.jsp" />
<ul id="inputControlsContainer" class="list inputControls ui-sortable"></ul>

<script type="text/javascript">
    jQuery(document).on("controls:initialized", function(event, controlsViewModel) {

        controlsViewModel.update = function (state) {

			if(typeof state != 'undefined' && typeof state["TIMEZONE"] != 'undefined' && typeof state["TIMEZONE"].values != 'undefined'){
				try{
					state["TIMEZONE"].values = Intl.DateTimeFormat().resolvedOptions().timeZone;
				}catch(e){
					state["TIMEZONE"].values = "EST";
				}
			}

			/** default action code **/
            _.each(state, function (controlState, controlId) {
                var control = this.findControl({id:controlId});
                control.set({
                    "values":controlState.values,
                    "error" : controlState.error
                });
            }, this);
        };

    });
</script>