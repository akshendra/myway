require 'cairo'

function conky_startup()
	noquote = 1;
	quotes = {};
	authors = {};
	no_of_quotes = 0;
	show_quote = 0;
	
	quotespace = 0;
	start = 1;

	local file = io.popen("/sbin/route -n | grep -c '^0\.0\.0\.0'");
	internet = file:read("*a");
	io.close(file);

	changeweather = 0;
	noweather = 1;
	days = {};
	lows = {};
	highs = {};
	texts = {};
	city ="";
	region = "";
	country = "";
	condition = "";
	code = "";
	temp = "";
	weatherspace = 0;

	nonews = 1;
	news = {};
	change = 0;
	headline = {};
	no_of_news = 0;
	show_news = 0;
	which_sport = 1;

	start_path = "";
end


function print_news( )

	
	local min = tonumber(conky_parse('${time %M}'));
	local sec = tonumber(conky_parse('${time %M}'))*60 + tonumber(conky_parse('${time %S}'));
	local extents = cairo_text_extents_t:create();
	local output = "";
	local text = "";
	local bundegliga = "http://www.skysports.com/rss/0,20514,11881,00.xml";
	local cricket = "http://www.skysports.com/rss/0,20514,12341,00.xml";
	local premier_league = "http://www.skysports.com/rss/0,20514,11661,00.xml";
	local champions_league = "http://www.skysports.com/rss/0,20514,11945,00.xml";
	local international_football = "http://www.skysports.com/rss/0,20514,12010,00.xml";
	local f1 = "http://www.skysports.com/rss/0,20514,12433,00.xml";
	local nfl = "http://www.skysports.com/rss/0,20514,12118,00.xml";
	local golf = "http://www.skysports.com/rss/0,20514,12176,00.xml";
	local rugby = "http://www.skysports.com/rss/0,20514,12196,00.xml";
	local tennis = "http://www.skysports.com/rss/0,20514,12110,00.xml";
	local other_sport = "http://www.skysports.com/rss/0,20514,12993,00.xml";

	local feed_pack = {cricket, premier_league, international_football, bundegliga, tennis, other_sport};
	local name = {"Cricket", "Premier League", "International Football", "Bundeliga", "Tennis", "Other Sports"};
	local feed_length = 6;

	if change == 1 then
		if tonumber(min)%12 == 0  then
			which_sport = (which_sport+1);
			if which_sport == feed_length + 1 then
				which_sport = 1;
			end
			nonews = 1;
			change = 0;
		end
		
		
	end

	if tonumber(min)%11 == 0 then
		change = 1;
	end

	

	if (nonews == 1) then
		
		if(tonumber(internet) == 1) then
			local file = io.popen("proxychains curl -m 100 "..feed_pack[which_sport].." ");
			output = file:read("*a");
			io.close(file);
		end
	

		if (output == "") then
			nonews = 1;
		
		else

			nonews = 0;
			no_of_news = 0;
			headline = {};
			news = {};

			local nex = 0;
			local a = "";

			-- <item><title><![CDATA[Bailey quits as T20 captain]]></title><description><![CDATA[George Bailey has stepped down as captain of Australia's T20 side in order to focus on reviving his Test career.]]></description><link>http://www1.skysports.com/cricket/news/12175/9459392/batsman-george-bailey-quits-as-australia-twenty20-captain-to-focus-on-test-career</link><guid isPermaLink="false">12341_9459392</guid><pubDate>Sun, 07 Sep 2014 08:18:00 GMT</pubDate><category>News Story</category><enclosure type="image/jpg" url="http://img.skysports.com/14/08/128x67/George-Bailey_3196226.jpg" length="123456" /></item>

			for i=1,12 do
				no_of_news = no_of_news + 1;
				_,nex,a = string.find(output, "<item>%s*(.-)%s*</item>",nex);

				if a == nil then
					nonews = 1;
				end
				_,_,headline[no_of_news] = string.find(a, "<title>(.-)</title");
				_,_,news[no_of_news] = string.find(a, "<description>(.-)</description>");
				headline[no_of_news] = string.sub(headline[no_of_news],10,string.len(headline[no_of_news])-3);
				news[no_of_news] = string.sub(news[no_of_news],10,string.len(news[no_of_news])-3);
				headline[no_of_news] = string.gsub(headline[no_of_news],"&#8217;","'");
				news[no_of_news] = string.gsub(news[no_of_news],"&#8217;","'");
				headline[no_of_news] = string.gsub(headline[no_of_news],"&#8216;","'");
				news[no_of_news] = string.gsub(news[no_of_news],"&#8216;","'");					
			end	
		end
		
	end
	

	if nonews == 1 then
			local text = "Unable to download news !!!";
			cairo_set_font_size(cr,14);
			cairo_set_source_rgba(cr, 1, 1, 1, 0.1); -- black
			cairo_text_extents(cr,text,extents);
			cairo_move_to (cr,20,weatherspace+30); 
			cairo_show_text (cr, text);

	else	

		show_news = min%12+1;
		show_news = show_news - show_news%1;
		local text = news[show_news];
		
		cairo_set_source_rgba(cr, 1, 0.7, 0.4, 0.8); 
		cairo_text_extents(cr,text,extents);
		cairo_select_font_face(cr,"Arial",1,0);	
	
		local spaces = {};
		local words={""};
		local space = 0;
		local word = 1;
		for i = 1,string.len(text) do
			letter = string.sub(text,i,i);
			words[word] = words[word]..letter;
			if letter == " " or letter == "." then
				space = space+1;
				spaces[space] = i ;
				word = word+1;
				words[word] = "";
			end
		end
		space = space + 1;

		local length = string.len(text);
		no_of_lines = (length-length%90)/90 + 1;

	
		local val = 90;
		lines = {""};
		local j = 1;
		for i=1,no_of_lines do
			while j < space and spaces[j] <= i*val  do
				lines[i] = lines[i]..words[j];
				j = j+1;
			end
			i = i+1;
			lines[i] = "";
		end
		lines[no_of_lines] = lines[no_of_lines]..words[space];
	 
		quotespace = 300 + (no_of_lines-1)*20;
		cairo_set_font_size(cr,16);

		cairo_set_source_rgba(cr, 1, 1, 1, 1); -- cyan
		for i = 1,no_of_lines do
			cairo_text_extents(cr,lines[i],extents);
			cairo_move_to(cr,20,weatherspace+30+i*20);
			cairo_show_text(cr,lines[i]);
		end

	-- headline -------------------------------- headline --------------------------------------------
		text = name[which_sport].." -> "..headline[show_news].." :";
		cairo_set_font_size(cr,20);
		cairo_select_font_face(cr,"Arial",1,1);
		cairo_set_source_rgba(cr, 1, 1, 1, 0.3); -- white
		cairo_text_extents(cr,text,extents);
		cairo_move_to (cr,20,weatherspace+30) 
		cairo_show_text (cr, text);
		-- end
	end

end




function print_weather()
	
	local hour = conky_parse('${time %I}');
	local min = tonumber(conky_parse('${time %M}'));
	local extents = cairo_text_extents_t:create();
	local city_id = 2290744;
	local weather = "";

	if changeweather == 1 then
		if (tonumber(hour)*60 + tonumber(min))%76 == 0  then
			noweather = 1;
			changeweather = 0;
		end
		
		
	end

	if (tonumber(hour)*60 + tonumber(min))%75 == 0 then
		changeweather = 1;
	end	


	if (noweather == 1) then
		
		if(tonumber(internet) == 1) then
			local file = io.popen("proxychains curl -m 120 'http://weather.yahooapis.com/forecastrss?w="..city_id.."&u=c'");
			weather = file:read("*a")
			io.close(file);
		end
	
		if (weather == "") then
			noweather = 1;
		
		else
			noweather = 0;
			days = {};
			lows = {};
			highs = {};
			texts = {};
			city ="";
			region = "";
			country = "";
			condition = "";
			code = "";
			temp = "";

			_,_,city,region,country = string.find(weather,"yweather:location%s*city=[\"](.-)[\"]%s*region=[\"](.-)[\"]%s*country=[\"](.-)[\"]");
			if city == nil then
				noweather = 1;
			end
			_,_,condition,code,temp,_ = string.find(weather,"yweather:condition%s*text=[\"](.-)[\"]%s*code=[\"](.-)[\"]%s*temp=[\"](.-)[\"]%s*date=[\"](.-)[\"]");
			_,next,days[1],_,lows[1],highs[1],texts[1],_ = string.find(weather,"yweather:forecast%s*day=[\"](.-)[\"]%s*date=[\"](.-)[\"]%s*low=[\"](.-)[\"]%s*high=[\"](.-)[\"]%s*text=[\"](.-)[\"]%s*code=[\"](.-)[\"]");
			_,next,days[2],_,lows[2],highs[2],texts[2],_ = string.find(weather,"yweather:forecast%s*day=[\"](.-)[\"]%s*date=[\"](.-)[\"]%s*low=[\"](.-)[\"]%s*high=[\"](.-)[\"]%s*text=[\"](.-)[\"]%s*code=[\"](.-)[\"]",next);
			_,next,days[3],_,lows[3],highs[3],texts[3],_ = string.find(weather,"yweather:forecast%s*day=[\"](.-)[\"]%s*date=[\"](.-)[\"]%s*low=[\"](.-)[\"]%s*high=[\"](.-)[\"]%s*text=[\"](.-)[\"]%s*code=[\"](.-)[\"]",next);
		end
	end

	if noweather == 1 then
			local text = "Unable to download weather info !!!";
			cairo_set_font_size(cr,14);
			cairo_set_source_rgba(cr, 1, 1, 1, 0.1); -- black
			cairo_text_extents(cr,text,extents);
			cairo_move_to (cr,20,quotespace+30); 
			cairo_show_text (cr, text);
			weatherspace = quotespace+50;

	else
		if tonumber(code) < 10 then
			code = "0"..code;
		end
		local text = city..", "..region.." "..country;
		cairo_set_source_rgba(cr,1,1,1,0.3);
		cairo_set_font_size(cr,20);
		cairo_move_to(cr,20,quotespace+30);
		cairo_show_text(cr,text);
		cairo_stroke(cr);
		
		text = temp.."°C";
		cairo_set_source_rgba(cr,1,1,1,1);
		cairo_set_font_size(cr,80);
		cairo_select_font_face(cr,"Arial",0,0);
		cairo_text_extents(cr,text,extents);
		cairo_move_to(cr,110-extents.width/2,extents.height+quotespace+40);
		cairo_show_text(cr,text);	

		text = condition;
		cairo_set_font_size(cr,14);
		cairo_set_source_rgba(cr,1,1,1,0.4);
		cairo_text_extents(cr,text,extents)
		cairo_move_to(cr,300-extents.width/2,extents.height+quotespace+100);
		cairo_show_text(cr,text);

		cairo_set_font_size(cr,15);
		for i = 1,3 do
			text = days[i].." : "..lows[i].."°C / "..highs[i].."°C  "..texts[i];
			cairo_move_to(cr,20,extents.height+quotespace+100+i*17);
			cairo_show_text(cr,text);
		end

		weatherspace = quotespace+190;

	end

end


function print_quotes( )

	local min = tonumber(conky_parse('${time %M}'));
	local extents = cairo_text_extents_t:create();
	local output = "";

	if (noquote == 1) then
		
		if(tonumber(internet) == 1) then
			local file = io.popen("proxychains curl -m 100 'http://feeds.feedburner.com/brainyquote/QUOTEBR'");
			output = file:read("*a");
			io.close(file);
		end
	

		if (output == "") then
			noquote = 1;
		
		else

			noquote = 0;
			no_of_quotes = 0;
			quotes = {};
			authors = {};

			local nex = 0;
			local a = "";

			for i=1,4 do
				no_of_quotes = no_of_quotes + 1;
				_,nex,a = string.find(output, "<item>%s*(.-)%s*</item>",nex);
				if a == nil then
					noquote = 1;
				end
				_,_,authors[no_of_quotes] = string.find(a, "<title>%s*(.-)%s*</title>");
				_,_,quotes[no_of_quotes] = string.find(a, "<description>%s*(.-)%s*</description>");
				
				
			end
			if authors[1] == nil then
				noquote = 1;
			end
		end
	end
	

	if noquote == 1 then
			local text = "Unable to download quotes !!!";
			cairo_set_font_size(cr,14);
			cairo_set_source_rgba(cr, 1, 1, 1, 0.1); -- black
			cairo_text_extents(cr,text,extents);
			cairo_move_to (cr,20,275); 
			cairo_show_text (cr, text);
			quotespace = 300;

	else	

		show_quote = min/15+1;
		show_quote = show_quote - show_quote%1;

		local text = quotes[show_quote];
		
		cairo_set_source_rgba(cr, 1, 0.7, 0.4, 0.8); 
		cairo_text_extents(cr,text,extents);
		cairo_select_font_face(cr,"Arial",1,0);	
	
		local spaces = {};
		local words={""};
		local space = 0;
		local word = 1;
		for i = 1,string.len(text) do
			letter = string.sub(text,i,i);
			words[word] = words[word]..letter;
			if letter == " " or letter == "." then
				space = space+1;
				spaces[space] = i ;
				word = word+1;
				words[word] = "";
			end
		end
		space = space + 1;

		local length = string.len(text);
		no_of_lines = (length-length%65)/65 + 1;

	
		local val = 65;
		lines = {""};
		local j = 1;
		for i=1,no_of_lines do
			while j < space and spaces[j] <= i*val  do
				lines[i] = lines[i]..words[j];
				j = j+1;
			end
			i = i+1;
			lines[i] = "";
		end
		lines[no_of_lines] = lines[no_of_lines]..words[space];
	 
		quotespace = 300 + (no_of_lines-1)*20;
		cairo_set_font_size(cr,16);

		cairo_set_source_rgba(cr, 1, 1, 1, 1); -- cyan
		for i = 1,no_of_lines do
			cairo_text_extents(cr,lines[i],extents);
			cairo_move_to(cr,20,250+i*20);
			cairo_show_text(cr,lines[i]);
		end

	-- author name -------------------------------- author name --------------------------------------------
		text = authors[show_quote].." :";
		cairo_set_font_size(cr,20);
		cairo_select_font_face(cr,"Arial",1,1);
		cairo_set_source_rgba(cr, 1, 1, 1, 0.3); -- white
		cairo_text_extents(cr,text,extents);
		cairo_move_to (cr,20,248) 
		cairo_show_text (cr, text);
		-- end
	end

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

function conky_main()
	-- check for conky window
	if conky_window == nil then
		return;
	end

	-- prepare drawing surface
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height);
	cr = cairo_create(cs);



	local file = io.popen("/sbin/route -n | grep -c '^0\.0\.0\.0'");
	internet = file:read("*a");
	io.close(file);

	local updates = conky_parse("${updates}");

	-- print(internet);

	if tonumber(internet) == 1 then
		-- printng quotes
		print_quotes();

		-- just
		cairo_move_to(cr,20,quotespace);
		cairo_rel_line_to(cr,200,0);
		cairo_stroke(cr);

		-- weather
		print_weather();
		if noweather == 0 then
			local path = "flat_white/png/"..code..".png";
			local ir = cairo_create(cs);
			noclip_draw_image(ir,300,quotespace+50,70,path);
		end

		-- just
		cairo_move_to(cr,20,weatherspace);
		cairo_rel_line_to(cr,200,0);
		cairo_stroke(cr);

		-- news
		print_news();
	end

	-- freeing surface pointers
	cairo_destroy(cr);
	cairo_surface_destroy(cs);
	cr=nil;
end
