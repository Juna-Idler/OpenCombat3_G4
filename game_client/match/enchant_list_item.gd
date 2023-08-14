extends RichTextLabel


func initialize(data : CatalogData.EnchantmentData,param : Array):
	var detail_text := data.text
	for i in data.param_type.size():
		var param_string := Global.card_catalog.param_to_string(data.param_type[i],param[i])
		if not param_string.is_empty():
			var replace_string : String = "{" + data.param_name[i] + "}"
			detail_text = detail_text.replace(replace_string,"{%s}" % param_string)
		
	var title_p_str := Global.card_catalog.params_to_string(data.param_type,param)
	var title := data.name + ("" if title_p_str.is_empty() else "(" + title_p_str + ")" )
	$".".text = title + "\n" + detail_text
