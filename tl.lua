require 'cairo'

function conky_startup()
	start_path = "";
end


function noclip_draw_image (ir,xc, yc, radius, path) 
	local w, h;
	
	cairo_set_source_rgba(ir,1,1,1,1);

	cairo_arc (ir, xc, yc, radius, 0, 2*math.pi);
	-- cairo_clip (ir);
	cairo_new_path (ir); 


	local image = cairo_image_surface_create_from_png (path);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);


	cairo_scale (ir, 2*radius/w, 2*radius/h);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);

	cairo_set_source_surface (ir, image, xc*(1/(2*radius/w)) - w/2, yc*(1/(2*radius/h)) - h/2);
	cairo_paint (ir);

	cairo_surface_destroy (image);
	cairo_destroy(ir);
end

function draw_image (ir,xc, yc, radius, path) 
	local w, h;
	
	cairo_set_source_rgba(ir,1,1,1,1);

	cairo_arc (ir, xc, yc, radius, 0, 2*math.pi);
	cairo_clip (ir);
	cairo_new_path (ir); 


	local image = cairo_image_surface_create_from_png (path);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);


	cairo_scale (ir, 2*radius/w, 2*radius/h);
	w = cairo_image_surface_get_width (image);
	h = cairo_image_surface_get_height (image);

	cairo_set_source_surface (ir, image, xc*(1/(2*radius/w)) - w/2, yc*(1/(2*radius/h)) - h/2);
	cairo_paint (ir);

	cairo_surface_destroy (image);
	cairo_destroy(ir);
end

function draw_waves(xc,yc,base_radius,num) 
	cairo_set_line_width(cr,1);
	for i = 1,num do
		cairo_arc(cr,xc,yc,base_radius+i*3,-(math.pi/180)*(90 - i*7.5),(math.pi/180)*(60-i*7.5));
		cairo_stroke(cr);
		cairo_arc_negative(cr,xc,yc,base_radius+i*3,-(math.pi/180)*(120+i*7.5),(math.pi/180)*(-270+i*7.5));
		cairo_stroke(cr);
	end
	cairo_stroke(cr);
end

function conky_main() 

	-- check for conky window
	if conky_window == nil then
		return;
	end

	-- prepare drawing surface
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
	cr = cairo_create(cs);
	
	local imagex = 1150;
	local imagey = 70;
	local image_radius = 60;
	local image_path = "face";
	local text = "";
	local extents = cairo_text_extents_t:create();

	local updates = conky_parse("${updates}");


	-- image on right
	local ir = cairo_create(cs);
	draw_image(ir,imagex,imagey,image_radius,image_path);
	
	cairo_set_source_rgba(cr,1,1,1,0.7);
	cairo_set_line_width(cr,3);
	cairo_arc(cr,imagex,imagey,image_radius,0,2*math.pi);
	cairo_stroke(cr);
	cairo_set_line_width(cr,1);
	for i = 1,4 do
		cairo_set_source_rgba(cr,1,1,1,0.7-i*0.10);
		cairo_arc(cr,imagex,imagey,image_radius+i*3,-(math.pi/180)*(70 - i*10),(math.pi/180)*(40-i*10));
		cairo_stroke(cr);
		cairo_arc_negative(cr,imagex,imagey,image_radius+i*3,-(math.pi/180)*(140+i*10),(math.pi/180)*(-250+i*10));
		cairo_stroke(cr);
	end
	

	-- arrow to system panel
	
	cairo_set_line_cap(cr,2);
	cairo_set_source_rgba(cr,1,1,1,0.5);
	cairo_set_line_width(cr,3);
	
	cairo_arc(cr,imagex,imagey+image_radius+3,4,0,2*math.pi);
	cairo_fill(cr);
	
	cairo_move_to(cr,imagex,imagey+image_radius);
	cairo_rel_line_to(cr,0,50);
	cairo_rel_line_to(cr,-200,0);
	cairo_rel_line_to(cr,0,60);
	cairo_stroke(cr);
	
	cairo_arc(cr,imagex-200,imagey+image_radius+110-3,4,0,2*math.pi);
	cairo_fill(cr);

	-- the cpu circle
	

		local ir = cairo_create(cs);
		cairo_set_line_width(cr,2);
		cairo_arc(cr,imagex-200,imagey+image_radius+130,25,0,2*math.pi);
		cairo_stroke(cr);
		cairo_set_source_rgba(cr,1,1,1,0.3);
		cairo_arc(cr,imagex-200,imagey+image_radius+130,25,0,2*math.pi);
		cairo_fill(cr);
		noclip_draw_image(ir,imagex-200,imagey+image_radius+130,16,"cpu");

		cairo_set_font_size(cr,14);
		cairo_set_source_rgba(cr,1,1,1,1);
		local cpu = tonumber(conky_parse("${cpu}"));
		text = "CPU "..cpu.."%";
		cairo_text_extents(cr,text,extents);
		cairo_move_to(cr,imagex-200- extents.width/2, imagey+image_radius+165 + extents.height);
		cairo_show_text(cr,text);
		cairo_stroke(cr);
		cairo_set_source_rgba(cr,1,1,1,0.70);
		if cpu > 25 then
			cairo_set_source_rgba(cr,1,0.3,0.3,1);
		end
		draw_waves(imagex-200,imagey+image_radius+130,25,cpu/11+1);

		-- arrow to top 10 cpu
		cairo_set_source_rgba(cr,1,1,1,0.5);
		local startx = imagex-200;
		local starty = imagey+image_radius+180;
		cairo_arc(cr,startx,starty + 4,4,0,2*math.pi);
		cairo_fill(cr);
		cairo_set_line_width(cr,3);
		cairo_move_to(cr,startx,starty+3);
		cairo_rel_line_to(cr,-200,0);
		cairo_rel_line_to(cr,50,50);
		cairo_stroke(cr);
		cairo_arc(cr,startx-151,starty + 52,4,0,2*math.pi);
		cairo_fill(cr);

		--  top 10 cpu process
		cairo_rotate(cr,-45*(math.pi/180));
		cairo_set_source_rgba(cr,1,1,1,1);
		cairo_move_to(cr,startx-153,starty + 60);
		cairo_set_font_size(cr,11);
		for i = 1,10 do
			local addison = "                 ";
			local name = string.sub(conky_parse("${top name "..i.."}")..addison,1,10);
			local value = conky_parse("${top cpu "..i.."}");
			cairo_move_to(cr,260,830+i*13);
			cairo_show_text(cr,name);
			cairo_move_to(cr,325,830+i*13);
			cairo_show_text(cr,value.."%");
		end


		-- arrow to ram
		cairo_rotate(cr,45*(math.pi/180));
		cairo_set_source_rgba(cr,1,1,1,0.5);
		cairo_move_to(cr,imagex-75,imagey+image_radius+50);
		cairo_rel_line_to(cr,0,60);
		cairo_stroke(cr);
		cairo_arc(cr,imagex-75,imagey+image_radius+110-3,4,0,2*math.pi);
		cairo_fill(cr);

		-- ram
		local ir = cairo_create(cs);
		cairo_set_line_width(cr,2);
		cairo_arc(cr,imagex-75,imagey+image_radius+130,25,0,2*math.pi);
		cairo_stroke(cr);
		cairo_set_source_rgba(cr,1,1,1,0.3);
		cairo_arc(cr,imagex-75,imagey+image_radius+130,25,0,2*math.pi);
		cairo_fill(cr);
		noclip_draw_image(ir,imagex-75,imagey+image_radius+130,16,"ram");

		cairo_set_font_size(cr,14);
		cairo_set_source_rgba(cr,1,1,1,1);
		local ram = tonumber(conky_parse("${memperc}"));
		text = "RAM "..ram.."%";
		cairo_text_extents(cr,text,extents);
		cairo_move_to(cr,imagex-75- extents.width/2, imagey+image_radius+165 + extents.height);
		cairo_show_text(cr,text);
		cairo_stroke(cr);
		cairo_set_source_rgba(cr,1,1,1,0.70);
		if ram > 50 then
			cairo_set_source_rgba(cr,1,0.3,0.3,1);
		end
		draw_waves(imagex-75,imagey+image_radius+130,25,ram/11+1);	

		
		-- arrow to top 10 ram
		cairo_set_source_rgba(cr,1,1,1,0.5);
		local startx = imagex-75;
		local starty = imagey+image_radius+180;
		cairo_arc(cr,startx,starty + 4,4,0,2*math.pi);
		cairo_fill(cr);
		cairo_set_line_width(cr,3);
		cairo_move_to(cr,startx,starty+3);
		cairo_rel_line_to(cr,0,50);
		cairo_rel_line_to(cr,170,0);
		cairo_rel_line_to(cr,-70,70);
		cairo_stroke(cr);
		cairo_arc(cr,startx+100,starty + 123,4,0,2*math.pi);
		cairo_fill(cr);


		--  top 10 ram process
		cairo_rotate(cr,45*(math.pi/180));
		cairo_set_source_rgba(cr,1,1,1,1);
		cairo_set_font_size(cr,11);
		for i = 1,10 do
			local addison = "                 ";
			local name = string.sub(conky_parse("${top_mem name "..i.."}")..addison,1,10);
			local value = (conky_parse("${top_mem mem_res "..i.."}"));
			cairo_move_to(cr,1100,-510+i*13);
			cairo_show_text(cr,name);
			cairo_move_to(cr,1175,-510+i*13);
			cairo_show_text(cr,value);
		end
		cairo_rotate(cr,-45*(math.pi/180));
	

	-- arrow to battery
	
	cairo_set_source_rgba(cr,1,1,1,0.5);
	cairo_move_to(cr,imagex,imagey+image_radius+50);
	cairo_rel_line_to(cr,50,0);
	cairo_rel_line_to(cr,0,60);
	cairo_stroke(cr);
	cairo_arc(cr,imagex+50,imagey+image_radius+110-3,4,0,2*math.pi);
	cairo_fill(cr);	

	--battery
	local ir = cairo_create(cs);
	cairo_set_line_width(cr,2);
	cairo_arc(cr,imagex+50,imagey+image_radius+130,25,0,2*math.pi);
	cairo_stroke(cr);
	cairo_set_source_rgba(cr,1,1,1,0.3);
	cairo_arc(cr,imagex+50,imagey+image_radius+130,25,0,2*math.pi);
	cairo_fill(cr);
	noclip_draw_image(ir,imagex+50,imagey+image_radius+130,16,"battery");

	cairo_set_font_size(cr,14);
	cairo_set_source_rgba(cr,1,1,1,1);
	local battery = tonumber(conky_parse("${battery_percent}"));
	text = "POWER "..battery.."%";
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,imagex+50- extents.width/2, imagey+image_radius+165 + extents.height);
	cairo_show_text(cr,text);
	cairo_stroke(cr);
	cairo_set_source_rgba(cr,1,1,1,0.70);
	if battery < 20 then
		cairo_set_source_rgba(cr,1,0.3,0.3,1);
	end
	draw_waves(imagex+50,imagey+image_radius+130,25,battery/11+1);


	-- time and date
	
	cairo_set_source_rgba(cr,1,1,1,0.08);
	cairo_move_to (cr, 0, 200);
	cairo_curve_to (cr, 300, 200, 500, 350, 470, 0);
	cairo_rel_line_to(cr,-470,0);
	cairo_rel_line_to(cr,0,200);
	cairo_fill_preserve(cr);

	local hour = conky_parse('${time %I}');
	local minute = conky_parse('${time %M}');
	local part = conky_parse('${time %P}');
	local day = conky_parse('${time %d}');
	local month = conky_parse('${time %B}');
	local year = conky_parse('${time %G}');

	cairo_set_source_rgba(cr,1,1,1,1);
	local left={"1","2","3","4","5","6","7","8","9","0"};
	local right={"!","@","#","$","%","^","&","*","(",")"};
	cairo_set_source_rgba(cr,0.9,0.9,0.9,1);
	cairo_set_font_size(cr,130);
	cairo_select_font_face(cr,"CombiNumerals Ltd",0,0);
	local hl = hour/10 - (hour/10)%1;
	if hl == 0 then
		hl = 10;
	end
	local ml = minute/10 - (minute/10)%1;
	if ml == 0 then
		ml = 10;
	end
	local hr = hour%10;
	if hr == 0 then
		hr = 10;
	end
	local mr = minute%10;
	if mr == 0 then
		mr = 10;
	end
	text = left[hl]..right[hr]..left[ml]..right[mr];
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,30,120);
	cairo_show_text(cr,text);
	cairo_select_font_face(cr,"Arial",0,0);
	cairo_move_to(cr,extents.width+45,110);
	cairo_show_text(cr,part);

	cairo_set_source_rgba(cr,0.5,0.7,1,1);
	cairo_set_source_rgba(cr,0.9,0.9,0.9,1);
	cairo_set_font_size (cr, 40);
	cairo_select_font_face (cr, "Royal Acidbath",CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
	text = day.." "..month..", "..year;
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,230 - extents.width/2,180);
	cairo_show_text(cr,text);

	-- arrow to network
	cairo_set_source_rgba(cr,1,1,1,0.5);
	cairo_set_line_width(cr,3);
	cairo_move_to(cr,imagex-78,imagey+20);
	cairo_rel_line_to(cr,-125,0);
	cairo_stroke(cr);
	cairo_arc(cr,imagex-78,imagey+20,4,0,2*math.pi);
	cairo_fill(cr);
	cairo_arc(cr,imagex-78-125,imagey+20,4,0,2*math.pi);
	cairo_fill(cr);

	-- network
	local ir = cairo_create(cs);
	cairo_set_line_width(cr,2);
	cairo_arc(cr,imagex-230,imagey+20,25,0,2*math.pi);
	cairo_stroke(cr);
	cairo_set_source_rgba(cr,1,1,1,0.3);
	cairo_arc(cr,imagex-230,imagey+20,25,0,2*math.pi);
	cairo_fill(cr);
	noclip_draw_image(ir,imagex-230,imagey+20,16,"network");

	cairo_set_font_size(cr,14);
	cairo_select_font_face(cr,"Arial",0,0);
	cairo_set_source_rgba(cr,1,1,1,1);
	local network = conky_parse("${addr eth0}");
	text = network;
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,imagex-230- extents.width/2, imagey+55 + extents.height);
	cairo_show_text(cr,text);
	cairo_stroke(cr);

	-- arrow to upload and download
	cairo_set_source_rgba(cr,1,1,1,0.5);
	cairo_set_line_width(cr,3);
	cairo_move_to(cr,imagex-258,imagey+20);
	cairo_rel_line_to(cr,-70,0);
	cairo_rel_line_to(cr,0,-50);
	cairo_rel_line_to(cr,-250,0)
	cairo_rel_line_to(cr,0,30);
	cairo_stroke(cr);
	cairo_arc(cr,imagex-255,imagey+20,4,0,2*math.pi);
	cairo_fill(cr);
	cairo_arc(cr,imagex-578,imagey,4,0,2*math.pi);
	cairo_fill(cr);
	cairo_move_to(cr,imagex-328,imagey+20);
	cairo_rel_line_to(cr,0,100);
	cairo_rel_line_to(cr,-30,0);
	cairo_stroke(cr);
	cairo_arc(cr,imagex-358,imagey+120,4,0,2*math.pi);
	cairo_fill(cr);

	-- download
	local ir = cairo_create(cs);
	cairo_set_line_width(cr,2);
	cairo_arc(cr,imagex-578,imagey+25,25,0,2*math.pi);
	cairo_stroke(cr);
	cairo_set_source_rgba(cr,1,1,1,0.3);
	cairo_arc(cr,imagex-578,imagey+25,25,0,2*math.pi);
	cairo_fill(cr);
	noclip_draw_image(ir,imagex-578,imagey+25,16,"download");

	cairo_set_font_size(cr,14);
	cairo_select_font_face(cr,"Arial",0,0);
	cairo_set_source_rgba(cr,1,1,1,1);
	local download = conky_parse("${downspeed eth0}");
	text = "DOWNLOAD "..download.."/s";
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,imagex-578- extents.width/2, imagey+57 + extents.height);
	cairo_show_text(cr,text);
	cairo_stroke(cr);

	cairo_set_source_rgba(cr,1,1,1,0.05);
	cairo_move_to(cr,imagex-349,imagey+44);
	cairo_rel_line_to(cr,-200,0);
	cairo_stroke(cr);	

	-- upload
	local ir = cairo_create(cs);
	cairo_set_line_width(cr,2);
	cairo_set_source_rgba(cr,1,1,1,0.5);
	cairo_arc(cr,imagex-383,imagey+120,25,0,2*math.pi);
	cairo_stroke(cr);
	cairo_set_source_rgba(cr,1,1,1,0.3);
	cairo_arc(cr,imagex-383,imagey+120,25,0,2*math.pi);
	cairo_fill(cr);
	noclip_draw_image(ir,imagex-383,imagey+120,16,"upload");

	cairo_set_font_size(cr,14);
	cairo_select_font_face(cr,"Arial",0,0);
	cairo_set_source_rgba(cr,1,1,1,1);
	local upload = conky_parse("${upspeed eth0}");
	text = "UPLOAD "..upload.."/s";
	cairo_text_extents(cr,text,extents);
	cairo_move_to(cr,imagex-383- extents.width/2, imagey+152 + extents.height);
	cairo_show_text(cr,text);
	cairo_stroke(cr);

	cairo_set_source_rgba(cr,1,1,1,0.05);
	cairo_move_to(cr,imagex-414,imagey+142);
	cairo_rel_line_to(cr,-200,0);
	cairo_stroke(cr);	


	

	-- name of config
	cairo_set_source_rgba(cr,1,1,1,0.7);
	cairo_set_line_width(cr,5);
	cairo_move_to(cr,conky_window.text_width-100,conky_window.text_height-2);
	cairo_rel_line_to(cr,100,-100);
	cairo_rel_line_to(cr,0,50);
	cairo_rel_line_to(cr,-120,118);
	cairo_rel_line_to(cr,-50,0);
	cairo_set_source_rgba(cr,1,1,1,0.1)
	cairo_fill_preserve(cr);

	cairo_set_source_rgba(cr,1,1,1,1);
	cairo_rotate(cr,-45*(math.pi/180));
	text = "MyWay";
	cairo_move_to(cr,390,1365);
	cairo_show_text(cr,text);

	-- freeing surface pointers
	cairo_destroy(cr);
	cairo_surface_destroy(cs);
	cr=nil;
end
