	function CBCalendar(lang)
	{
		this.dates = new Array();
		this.lang = lang;
		this.loaded = false;
		this.field = null;
		this.d = new Date();
		this.addYear = function (val) { this.d.setFullYear( this.d.getFullYear()+val ); this.show(); }
		this.addMonth = function(val) { 
			var v = this.d.getMonth()+val;
			if (v < 0) v += 12;
			v %= 12;
			this.d.setMonth(v);  
			this.show(); 
		}
		this.show = function()
		{
			$("#cb_calendar_month").text( this.dates[this.lang].months[ this.d.getMonth() ] );
			$("#cb_calendar_months").text( this.dates[this.lang].monthsShort[ this.d.getMonth() ] );
			$("#cb_calendar_year").text( this.d.getFullYear() );
			$("#cb_calendar_yeard").html( this.d.getFullYear() );
			$("#cb_calendar-week").text( this.dates[this.lang].days[ this.d.getDay() ] );
			$("#cb_calendar_date").text( this.d.getDate() );
			$("#cb_close").text( this.dates[this.lang].close );
			for (var i=0;i<7;i++)
				$("#cb_sw"+i).text( this.dates[this.lang].daysMin[ i ] );
			var d1 = new Date(this.d.getFullYear(), this.d.getMonth(), 1);
			var dow1 = d1.getDay();
			if (this.dates[this.lang].weekStart==1) dow1=(dow1==0)?6:(dow1-1);
			var days_html = "<tr>";
			for (var i=0; i<dow1;i++ )
				days_html += '<td class="empty">&nbsp;</td>';
			d1.setDate(33);
		    var days_in_month =  33 - d1.getDate();
			for (var j=1; j<=days_in_month;j++ )
			{
				if ( (i+j-1) % 7 == 0)
					days_html += "</tr><tr>";
				if (j==this.d.getDate())
					days_html += "<td class='this'>"+j+"</td>";
				else
					days_html += "<td>"+j+"</td>";
			}
			days_html += "</tr>";
			$("#cb_calandar_days").html( days_html );
			$("#cb_calandar_days>tr>td").on("click", this.datePressed );
			$("#cbcal_ok").on("click", this.okPressed );
		}
		this.okPressed = function(e) {
			$('#modalCalendar').modal('hide');
		}
		this.datePressed = function(e) {
			cbcal.d.setDate( e.currentTarget.textContent );
			var df = cbcal.formatDate( cbcal.d, cbcal.dates[cbcal.lang].format, cbcal.lang );
			$("#cb_calandar_days>tr>td").removeClass('this');
			$(e.currentTarget).addClass('this');
			cbcal.field.value = df;
			$('#modalCalendar').modal('hide');
		}
		this.open = function(e)
		{
			cbcal.field = $(this).prevAll('input')[0];
			if (cbcal.field != undefined && cbcal.field.value != '' && cbcal.field.value != undefined)
				cbcal.d = cbcal.parseDate( cbcal.field.value, cbcal.dates[cbcal.lang].format, cbcal.lang );
			else
				cbcal.d = new Date();
			if (!cbcal.loaded)
				$( "#calendar-conent" ).load( "/templates/calendar.htm", null, cbcal.showModal );
			else
				cbcal.showModal();
		}
		this.showModal = function()
		{
			cbcal.show();
			$('#modalCalendar').modal('show');
			this.loaded = true;
		}
		this.formatDate = function(date, format, language){
			if (!date)
				return '';
			var flags = {
				d: date.getDate(),
				D: this.dates[language].daysShort[date.getDay()],
				DD: this.dates[language].days[date.getDay()],
				m: date.getMonth() + 1,
				M: this.dates[language].monthsShort[date.getMonth()],
				MM: this.dates[language].months[date.getMonth()],
				yy: date.getFullYear().toString().substring(2),
				yyyy: date.getFullYear()
			};
			flags.dd = (flags.d < 10 ? '0' : '') + flags.d;
			flags.mm = (flags.m < 10 ? '0' : '') + flags.m;
			return format.replace(RegExp(/d{1,4}|M{1,4}|yy(?:yy)?|([HhmsTt])\1?|[LloSZ]|"[^"]*"|\'[^\']*'/g), function ($0) {
	            return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1); });
		}
		this.parseDate = function( strDate, format, lang) {
			var dateParts = strDate.split(".");
			if (strDate.indexOf("/") != -1)
				dateParts = strDate.split("/");
			if (lang=='ru')
				return new Date(dateParts[2], (dateParts[1] - 1), dateParts[0]);
			else
				return new Date(dateParts[2], (dateParts[0] - 1), dateParts[1]);
		}
	}
